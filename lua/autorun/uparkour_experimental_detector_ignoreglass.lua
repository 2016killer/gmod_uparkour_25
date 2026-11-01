
UPar = UPar or {}

local ZERO_ANGLE = Angle(0, 0, 0)
local DEBUG_COLOR = {
    WHITE = Color(255, 255, 255, 50),
    PURPLE = Color(128, 0, 255, 50),
    CYAN = Color(0, 255, 255, 50),
    GREEN = Color(0, 255, 0, 50),
}

UPar.DetectorIgnoreGlassMAGIC = {
    MAX_IGNORED_GLASSES = 10, -- 最大忽略玻璃数量
    GLASS_DAMAGE_TRACE_OFFSET = 5, -- 伤害 Trace 向玻璃内部偏移
}

local upar_throughglass_volume_limit = CreateConVar(
    'upar_throughglass_volume_limit', '0',
    { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_throughglass_health_limit = CreateConVar(
    'upar_throughglass_health_limit', '0',
    { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)

local function IsDev()
    local convar = GetConVar('developer')
    return convar ~= nil and convar:GetInt() > 0
end

local function NormalizeXY(vector)
    vector = Vector(vector)
    vector[3] = 0
    vector:Normalize()
    return vector
end

local function IsGlass(entity)
    if not IsValid(entity) or entity:IsWorld() then return false end

    local class = entity:GetClass()
    local isGlass = entity:GetMaterialType() == MAT_GLASS
        or entity:GetCollisionGroup() == COLLISION_GROUP_BREAKABLE_GLASS

    if class == 'func_breakable_surf' then
        local surfaceType = tonumber(entity:GetInternalVariable('m_nSurfaceType'))
        if surfaceType == 1 then return false end
        isGlass = true
    end

    if not isGlass then return false end

    local health = entity:Health()
    local maxHealth = entity:GetMaxHealth()
    local phys = entity:GetPhysicsObject()
    local volume = IsValid(phys) and phys:GetVolume() or 0
    if volume <= 0 then
        local size = entity:OBBMaxs() - entity:OBBMins()
        volume = math.abs(size.x * size.y * size.z)
    end

    local volumeLimit = upar_throughglass_volume_limit:GetFloat()
    local healthLimit = upar_throughglass_health_limit:GetFloat()

    if IsDev() then
        print('[UPar] IsGlass', entity, class, 'health=' .. tostring(health),
            'maxHealth=' .. tostring(maxHealth), 'volume=' .. tostring(volume),
            'volumeLimit=' .. tostring(volumeLimit), 'healthLimit=' .. tostring(healthLimit))
    end

    if class ~= 'func_breakable_surf' and maxHealth <= 2 then return false end
    if volumeLimit > 0 and volume >= volumeLimit then return false end
    if healthLimit > 0 and health >= healthLimit then return false end

    return true
end

local function TraceHullIgnoreGlass(trace, glasses, debugflag)
    local function FindGlassEntry(entity)
        for _, glass in ipairs(glasses) do
            if glass.ent == entity then return glass end
        end
    end

    local function CaptureGlassDamageTrace(result)
        if result.Entity:GetClass() ~= 'func_breakable_surf' then return end

        local damageTrace = {}
        for key, value in pairs(result) do
            damageTrace[key] = value
        end
        damageTrace.HitPos = result.HitPos
            + result.Normal * UPar.DetectorIgnoreGlassMAGIC.GLASS_DAMAGE_TRACE_OFFSET
        return damageTrace
    end

    for _, glass in ipairs(glasses) do
        if not table.HasValue(trace.filter, glass.ent) then
            trace.filter[#trace.filter + 1] = glass.ent
        end
    end

    while true do
        local result = util.TraceHull(trace)
        if result.StartSolid then
            if IsDev() then
                print('[UPar] TraceHullIgnoreGlass', debugflag, 'StartSolid', result.Entity,
                    IsValid(result.Entity) and result.Entity:GetClass() or 'Invalid')
            end
            return result
        end

        if not result.Hit then
            if IsDev() then
                print('[UPar] TraceHullIgnoreGlass', debugflag, 'NoHit')
            end
            return result
        end

        if not IsGlass(result.Entity) then
            if IsDev() then
                print('[UPar] TraceHullIgnoreGlass', debugflag, 'Returning result', result.Entity,
                    IsValid(result.Entity) and result.Entity:GetClass() or 'Invalid')
            end
            return result
        end

        local glass = FindGlassEntry(result.Entity)
        if not glass then
            if #glasses >= UPar.DetectorIgnoreGlassMAGIC.MAX_IGNORED_GLASSES then
                if IsDev() then
                    print('[UPar] TraceHullIgnoreGlass', debugflag, 'Max ignored glass count reached',
                        result.Entity, result.Entity:GetClass())
                end
                return result
            end
            glass = {
                ent = result.Entity,
            }
            glasses[#glasses + 1] = glass
        end
        if not glass.damageTrace then
            glass.damageTrace = CaptureGlassDamageTrace(result)
        end
        if IsDev() then
            print('[UPar] TraceHullIgnoreGlass', debugflag, 'Ignoring glass', result.Entity,
                result.Entity:GetClass())
        end
        trace.filter[#trace.filter + 1] = result.Entity
    end
end


local function HeightDetectorIgnoreGlass(
    ply,
    obstacleHitPos,
    probeEndPos,
    startHeight,
    endHeight,
    step,
    glasses
)
    local duckMins, duckMaxs = ply:GetHullDuck()
    local probes = {}
    local direction = startHeight < endHeight and 1 or -1
    local height = startHeight
    local filter = { ply }
    local probeIndex = 0

    while true do
        probeIndex = probeIndex + 1
        local passProbe = TraceHullIgnoreGlass({
            filter = filter,
            mask = MASK_PLAYERSOLID,
            start = obstacleHitPos + Vector(0, 0, height),
            endpos = probeEndPos + Vector(0, 0, height),
            mins = duckMins,
            maxs = duckMaxs,
            collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
        }, glasses, string.format('HeightDetectorIgnoreGlass.passProbe[%d]', probeIndex))

        debugoverlay.SweptBox(passProbe.StartPos, passProbe.HitPos, duckMins, duckMaxs, ZERO_ANGLE,
            UPar.DetectorMAGIC.DEBUG_TTL, DEBUG_COLOR.CYAN)
        probes[#probes + 1] = passProbe

        if passProbe.StartSolid then
            return nil, probes
        end

        if not passProbe.Hit then
            local downStart = probeEndPos + Vector(0, 0, height)
            local downProbe = TraceHullIgnoreGlass({
                filter = filter,
                mask = MASK_PLAYERSOLID,
                start = downStart,
                endpos = downStart - Vector(0, 0, step),
                mins = duckMins,
                maxs = duckMaxs,
                collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
            }, glasses, string.format('HeightDetectorIgnoreGlass.downProbe[%d]', probeIndex))

            debugoverlay.SweptBox(downProbe.StartPos, downProbe.HitPos, duckMins, duckMaxs, ZERO_ANGLE,
                UPar.DetectorMAGIC.DEBUG_TTL, DEBUG_COLOR.CYAN)
            probes[#probes + 1] = downProbe

            if downProbe.StartSolid then
                return nil, probes
            end

            if downProbe.Hit
                and downProbe.HitNormal.z >= UPar.DetectorMAGIC.WALKABLE_NORMAL_Z then
                debugoverlay.Sphere(downProbe.HitPos, UPar.DetectorMAGIC.DEBUG_POINT_RADIUS,
                    UPar.DetectorMAGIC.DEBUG_TTL, true, DEBUG_COLOR.CYAN)
                return downProbe, probes
            end
        end

        if height == endHeight then break end

        height = height + direction * step
        if (direction > 0 and height > endHeight)
            or (direction < 0 and height < endHeight) then
            height = endHeight
        end
    end

    return nil, probes
end

local function ObstacleDetectorIgnoreGlass(ply, position, probeVector, glasses)
    local mins, maxs = ply:GetCollisionBounds()

    local traceResult = TraceHullIgnoreGlass({
        filter = { ply },
        mask = MASK_PLAYERSOLID,
        start = position,
        endpos = position + probeVector,
        mins = mins,
        maxs = maxs,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    }, glasses, 'ObstacleDetectorIgnoreGlass')

    debugoverlay.SweptBox(traceResult.StartPos, traceResult.HitPos, mins, maxs, ZERO_ANGLE,
        UPar.DetectorMAGIC.DEBUG_TTL, DEBUG_COLOR.WHITE)
    debugoverlay.Text(traceResult.HitPos, 'Obstacle', UPar.DetectorMAGIC.DEBUG_TTL, false)
    if traceResult.Hit and not traceResult.StartSolid then
        debugoverlay.Sphere(traceResult.HitPos, UPar.DetectorMAGIC.DEBUG_POINT_RADIUS,
            UPar.DetectorMAGIC.DEBUG_TTL, true)
    end

    if traceResult.StartSolid then return end
    if not traceResult.Hit
        or traceResult.HitNormal[3] >= UPar.DetectorMAGIC.WALKABLE_NORMAL_Z then return end
    if SERVER and IsValid(traceResult.Entity) and traceResult.Entity:IsPlayerHolding() then return end
    if not UPar.IsObstacleEntity(traceResult.Entity) then return end

    return traceResult
end

local function CanStandAt(ply, position, mins, maxs)
    local probe = util.TraceHull({
        filter = ply,
        mask = MASK_PLAYERSOLID,
        start = position,
        endpos = position,
        mins = mins,
        maxs = maxs,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    })
    debugoverlay.SweptBox(position, position, mins, maxs, ZERO_ANGLE,
        UPar.DetectorMAGIC.DEBUG_TTL, DEBUG_COLOR.GREEN)
    return not probe.StartSolid
end

function UPar.ClassifyObstacleTypeIgnoreGlass(ply, probeDirection)
    local dir = NormalizeXY(probeDirection)
    local mins, maxs = ply:GetCollisionBounds()
    local duckMins, duckMaxs = ply:GetHullDuck()
    local standMins, standMaxs = ply:GetHull()
    local playerWidth = math.max(maxs.x - mins.x, maxs.y - mins.y)
    local playerHeight = maxs.z - mins.z
    local duckHeight = duckMaxs.z - duckMins.z

    local glasses = {}
    local obstacle = ObstacleDetectorIgnoreGlass(
        ply,
        ply:GetPos(),
        dir * playerWidth * UPar.DetectorMAGIC.OBS_REACH,
        glasses
    )
    if not obstacle then return end

    local obstacleNormal = NormalizeXY(obstacle.HitNormal)

    local obstacleDistance = (obstacle.HitPos - ply:GetPos()):Length2D()
    local backoff = math.min(UPar.DetectorMAGIC.HEIGHT_BACKOFF, obstacleDistance)
    local heightProbeStart = obstacle.HitPos - dir * backoff
    local heightPosition = obstacle.HitPos + dir * playerWidth * UPar.DetectorMAGIC.HEIGHT_FORWARD
    local step = duckHeight * UPar.DetectorMAGIC.HEIGHT_STEP
    local heightTrace, heightProbes = HeightDetectorIgnoreGlass(
        ply,
        heightProbeStart,
        heightPosition,
        playerHeight * UPar.DetectorMAGIC.HEIGHT_START,
        playerHeight * UPar.DetectorMAGIC.HEIGHT_END,
        step,
        glasses
    )
    if not heightTrace then return end

    local blockClimbGlasses = {}
    for _, glass in ipairs(glasses) do
        blockClimbGlasses[#blockClimbGlasses + 1] = glass
    end
    local passGlassStart = #glasses

    local landing = heightTrace.HitPos
    local landingLift = math.min(UPar.DetectorMAGIC.LANDING_LIFT, heightTrace.StartPos.z - landing.z)
    local finalLanding = landing + Vector(0, 0, landingLift)
    local height = landing.z - ply:GetPos().z
    local halfMins = Vector(duckMins.x, duckMins.y, 0)
    local halfMaxs = Vector(duckMaxs.x, duckMaxs.y, duckHeight * UPar.DetectorMAGIC.PULSE_PASS_HEIGHT)
    local passStart = landing + Vector(0, 0, duckHeight * UPar.DetectorMAGIC.PULSE_PASS_HEIGHT)
    local passTrace = TraceHullIgnoreGlass({
        filter = { ply },
        mask = MASK_PLAYERSOLID,
        start = passStart,
        endpos = passStart + dir * playerWidth * UPar.DetectorMAGIC.PULSE_FORWARD,
        mins = halfMins,
        maxs = halfMaxs,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    }, glasses, 'ClassifyObstacleTypeIgnoreGlass.passTrace')
    local blockVaultGlasses = {}
    for i = passGlassStart + 1, #glasses do
        blockVaultGlasses[#blockVaultGlasses + 1] = glasses[i]
    end
    debugoverlay.SweptBox(passTrace.StartPos, passTrace.HitPos, halfMins, halfMaxs, ZERO_ANGLE,
        UPar.DetectorMAGIC.DEBUG_TTL, DEBUG_COLOR.PURPLE)

    local canStand = CanStandAt(ply, landing, standMins, standMaxs)
    local playerPos = ply:GetPos()
    local groundDepth = playerHeight * UPar.DetectorMAGIC.GROUND_PROBE_DEPTH
    local groundMins = Vector(mins.x, mins.y, -groundDepth)
    local groundMaxs = Vector(maxs.x, maxs.y, 0)
    local groundProbe = util.TraceHull({
        filter = ply,
        mask = MASK_PLAYERSOLID,
        start = playerPos,
        endpos = playerPos,
        mins = groundMins,
        maxs = groundMaxs,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    })
    local groundClose = groundProbe.StartSolid
    debugoverlay.Box(playerPos, groundMins, groundMaxs, UPar.DetectorMAGIC.DEBUG_TTL,
        groundClose and DEBUG_COLOR.GREEN or DEBUG_COLOR.WHITE)

    if passTrace.StartSolid then
        return 'platform', UPar.Platform{
            obstacle = obstacle,
            height = height,
            landing = finalLanding,
            canStand = canStand,
            groundClose = groundClose,
            obstacleNormal = obstacleNormal,
            blockClimbGlasses = blockClimbGlasses,
            blockVaultGlasses = blockVaultGlasses,
        }
    end

    local targetZ = landing.z - playerHeight * UPar.DetectorMAGIC.PULSE_DOWN_TARGET
    if not groundClose then
        targetZ = math.max(targetZ, playerPos.z)
    end

    local dropTarget = Vector(
        passTrace.HitPos.x,
        passTrace.HitPos.y,
        targetZ
    )
    local dropTrace = util.TraceHull({
        filter = ply,
        mask = MASK_PLAYERSOLID,
        start = passTrace.HitPos,
        endpos = dropTarget,
        mins = halfMins,
        maxs = halfMaxs,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    })
    debugoverlay.SweptBox(dropTrace.StartPos, dropTrace.HitPos, halfMins, halfMaxs, ZERO_ANGLE,
        UPar.DetectorMAGIC.DEBUG_TTL, DEBUG_COLOR.CYAN)

    local dropTravel = landing.z - dropTrace.HitPos.z
    if dropTrace.StartSolid or dropTravel < playerHeight * UPar.DetectorMAGIC.PULSE_DOWN_MIN then
        return 'platform', UPar.Platform{
            obstacle = obstacle,
            height = height,
            landing = finalLanding,
            canStand = canStand,
            groundClose = groundClose,
            dropTravel = dropTravel,
            obstacleNormal = obstacleNormal,
            blockClimbGlasses = blockClimbGlasses,
            blockVaultGlasses = blockVaultGlasses,
        }
    end

    local reverseLength = (dropTrace.HitPos - obstacle.HitPos):Dot(dir)
    if reverseLength <= 0 then
        return 'platform', UPar.Platform{
            obstacle = obstacle,
            height = height,
            landing = finalLanding,
            canStand = canStand,
            groundClose = groundClose,
            dropTravel = dropTravel,
            obstacleNormal = obstacleNormal,
            blockClimbGlasses = blockClimbGlasses,
            blockVaultGlasses = blockVaultGlasses,
        }
    end

    local reverseGlassStart = #glasses
    local reverseTrace = TraceHullIgnoreGlass({
        filter = { ply },
        mask = MASK_PLAYERSOLID,
        start = dropTrace.HitPos,
        endpos = dropTrace.HitPos - dir * reverseLength,
        mins = standMins,
        maxs = standMaxs,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    }, glasses, 'ClassifyObstacleTypeIgnoreGlass.reverseTrace')
    for i = reverseGlassStart + 1, #glasses do
        blockVaultGlasses[#blockVaultGlasses + 1] = glasses[i]
    end
    debugoverlay.SweptBox(reverseTrace.StartPos, reverseTrace.HitPos, standMins, standMaxs, ZERO_ANGLE,
        UPar.DetectorMAGIC.DEBUG_TTL, DEBUG_COLOR.GREEN)

    if reverseTrace.StartSolid or not reverseTrace.Hit then
        return 'platform', UPar.Platform{
            obstacle = obstacle,
            height = height,
            landing = finalLanding,
            canStand = canStand,
            groundClose = groundClose,
            dropTravel = dropTravel,
            obstacleNormal = obstacleNormal,
            blockClimbGlasses = blockClimbGlasses,
            blockVaultGlasses = blockVaultGlasses,
        }
    end

    local reverseTravel = (reverseTrace.StartPos - reverseTrace.HitPos):Dot(dir)
    local finalVaultLanding = reverseTrace.HitPos
        + dir * math.min(UPar.DetectorMAGIC.VAULT_LANDING_FORWARD, reverseTravel)

    debugoverlay.Sphere(finalVaultLanding, UPar.DetectorMAGIC.DEBUG_POINT_RADIUS,
        UPar.DetectorMAGIC.DEBUG_TTL, true, DEBUG_COLOR.GREEN)

    return 'pulse', UPar.Pulse{
        obstacle = obstacle,
        height = height,
        landing = finalLanding,
        vaultLanding = finalVaultLanding,
        thickness = (reverseTrace.HitPos - obstacle.HitPos):Dot(dir),
        dropTravel = dropTravel,
        groundClose = groundClose,
        canStand = canStand,
        obstacleNormal = obstacleNormal,
        blockClimbGlasses = blockClimbGlasses,
        blockVaultGlasses = blockVaultGlasses,
    }
end
