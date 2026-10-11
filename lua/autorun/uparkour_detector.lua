UPar = UPar or {}

local UNIT_VECTOR = Vector(0, 0, 1)
local ZERO_VECTOR = Vector(0, 0, 0)
local ZERO_ANGLE = Angle(0, 0, 0)

local upar_obstacle_ragdoll = CreateConVar('upar_obstacle_ragdoll', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, '是否将布娃娃视为障碍物')
local upar_obstacle_character = CreateConVar('upar_obstacle_character', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, '是否将NPC/玩家/NextBot视为障碍物')

local upar_obstacle_require_frozen = CreateConVar(
    'upar_obstacle_require_frozen', '0',
    { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)

local DEBUG_COLOR = {
    WHITE  = Color(255, 255, 255, 50),
    PURPLE = Color(128, 0, 255, 50),
    CYAN   = Color(0, 255, 255, 50),
    GREEN  = Color(0, 255, 0, 50)
}

UPar.DetectorMAGIC = {
    LANDING_LIFT       = 1,     -- final landing vertical lift, capped by height down travel
    VAULT_LANDING_FORWARD = 5,  -- final vault landing forward offset, capped by reverse sweep travel
    WALKABLE_NORMAL_Z  = 0.707, -- 可站立面法线 Z
    OBS_REACH          = 2.5,   -- 粗检测距离, × 玩家宽度
    HEIGHT_FORWARD     = 0.5,   -- 高度检测前移, × 玩家宽度
    HEIGHT_BACKOFF     = 2,     -- 高度探针从障碍命中点向玩家方向偏移, Source 单位
    HEIGHT_START       = 0.3,   -- 高度扫描起点, × 玩家身高
    HEIGHT_END         = 1.3,   -- 高度扫描终点, × 玩家身高
    HEIGHT_STEP        = 0.5,   -- 高度步进, × 蹲姿高度
    PULSE_FORWARD      = 2,   -- 水平通行距离, × 玩家宽度
    PULSE_DOWN_MIN     = 0.3,   -- 下探最小距离, × 玩家身高
    PULSE_DOWN_TARGET  = 0.6,   -- 下探目标距离, × 玩家身高
    GROUND_PROBE_DEPTH = 0.5,   -- 离地探测深度, × 玩家身高
    PULSE_PASS_HEIGHT  = 0.5,   -- 水平通行探针高度, × 蹲姿高度
    DEBUG_TTL          = 3,     -- 调试图形持续时间
    DEBUG_POINT_RADIUS = 3,     -- 调试命中点半径
}

local function IsDev()
    local convar = GetConVar('developer')
    return convar ~= nil and convar:GetInt() > 0
end


local function IsFrozenEntity(entity)
    if entity:IsWorld() or entity:GetMoveType() == MOVETYPE_NONE then return true end

    local phys = entity:GetPhysicsObject()
    return not IsValid(phys) or not phys:IsMoveable() or not phys:IsMotionEnabled()
end

function UPar.IsObstacleEntity(entity)
    if not IsValid(entity) then return true end
    if upar_obstacle_require_frozen:GetBool() and not IsFrozenEntity(entity) then return false end

    local override = UPar.ObstacleEntityClassFilter[entity:GetClass()]
    if override ~= nil then return override end

    if entity:IsRagdoll() then
        return upar_obstacle_ragdoll:GetBool()
    end

    if entity:IsPlayer() or entity:IsNPC() or entity:IsNextBot() then
        return upar_obstacle_character:GetBool()
    end

    return true
end

local function NormalizeXY(vector)
    vector = Vector(vector)
    vector[3] = 0
    vector:Normalize()
    return vector
end

local function HeightDetector(
    ply,
    obstacleHitPos,
    probeEndPos,
    startHeight,
    endHeight,
    step
)
    -- 每个候选高度先做水平通行检查，再在终点用蹲姿碰撞盒向下探
    local duckMins, duckMaxs = ply:GetHullDuck()
    local probes = {}
    local direction = startHeight < endHeight and 1 or -1
    local height = startHeight

    while true do
        local passProbe = util.TraceHull({
            filter = ply,
            mask = MASK_PLAYERSOLID,
            start = obstacleHitPos + Vector(0, 0, height),
            endpos = probeEndPos + Vector(0, 0, height),
            mins = duckMins,
            maxs = duckMaxs,
            collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
        })

        debugoverlay.SweptBox(passProbe.StartPos, passProbe.HitPos, duckMins, duckMaxs, ZERO_ANGLE,
            UPar.DetectorMAGIC.DEBUG_TTL, DEBUG_COLOR.CYAN)
        probes[#probes + 1] = passProbe

        if passProbe.StartSolid then
            return nil, probes
        end

        if not passProbe.Hit then
            local downStart = probeEndPos + Vector(0, 0, height)
            local downProbe = util.TraceHull({
                filter = ply,
                mask = MASK_PLAYERSOLID,
                start = downStart,
                endpos = downStart - Vector(0, 0, step),
                mins = duckMins,
                maxs = duckMaxs,
                collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
            })

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

local function ObstacleDetector(ply, position, probeVector)
    -- 用玩家完整碰撞盒向前粗检测障碍物
    local mins, maxs = ply:GetCollisionBounds()

    local traceResult = util.TraceHull({
        filter = ply,
        mask = MASK_PLAYERSOLID,
        start = position,
        endpos = position + probeVector,
        mins = mins,
        maxs = maxs,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    })

    debugoverlay.SweptBox(traceResult.StartPos, traceResult.HitPos, mins, maxs, ZERO_ANGLE,
        UPar.DetectorMAGIC.DEBUG_TTL, DEBUG_COLOR.WHITE)
    debugoverlay.Text(traceResult.HitPos, 'Obstacle', UPar.DetectorMAGIC.DEBUG_TTL, false)
    if traceResult.Hit and not traceResult.StartSolid then
        debugoverlay.Sphere(traceResult.HitPos, UPar.DetectorMAGIC.DEBUG_POINT_RADIUS,
            UPar.DetectorMAGIC.DEBUG_TTL, true)
    end


    if traceResult.StartSolid then return end
    if not traceResult.Hit or traceResult.HitNormal[3] >= UPar.DetectorMAGIC.WALKABLE_NORMAL_Z then return end
    if SERVER and IsValid(traceResult.Entity) and traceResult.Entity:IsPlayerHolding() then return end
    if not UPar.IsObstacleEntity(traceResult.Entity) then return end

    return traceResult
end

local function CanStandAt(ply, position, mins, maxs)
    -- 用完整站立盒检查该位置能否站起来
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

function UPar.ClassifyObstacleType(ply, probeDirection)
    -- 粗检测后串联高度、通行、下探和反向站立盒，判断台型或脉冲型
    local dir = NormalizeXY(probeDirection)
    local mins, maxs = ply:GetCollisionBounds()
    local duckMins, duckMaxs = ply:GetHullDuck()
    local standMins, standMaxs = ply:GetHull()
    local playerWidth = math.max(maxs.x - mins.x, maxs.y - mins.y)
    local playerHeight = maxs.z - mins.z
    local duckHeight = duckMaxs.z - duckMins.z

    local obstacle = ObstacleDetector(ply, ply:GetPos(), dir * playerWidth * UPar.DetectorMAGIC.OBS_REACH)
    if not obstacle then return end

    local obstacleNormal = NormalizeXY(obstacle.HitNormal)

    local obstacleDistance = (obstacle.HitPos - ply:GetPos()):Length2D()
    local backoff = math.min(UPar.DetectorMAGIC.HEIGHT_BACKOFF, obstacleDistance)
    local heightProbeStart = obstacle.HitPos - dir * backoff
    local heightPosition = obstacle.HitPos + dir * playerWidth * UPar.DetectorMAGIC.HEIGHT_FORWARD
    local step = duckHeight * UPar.DetectorMAGIC.HEIGHT_STEP
    local heightTrace, heightProbes = HeightDetector(
        ply,
        heightProbeStart,
        heightPosition,
        playerHeight * UPar.DetectorMAGIC.HEIGHT_START,
        playerHeight * UPar.DetectorMAGIC.HEIGHT_END,
        step
    )
    if not heightTrace then return end

    local landing = heightTrace.HitPos
    local landingLift = math.min(UPar.DetectorMAGIC.LANDING_LIFT, heightTrace.StartPos.z - landing.z)
    local finalLanding = landing + Vector(0, 0, landingLift)
    local height = landing.z - ply:GetPos().z
    local halfMins = Vector(duckMins.x, duckMins.y, 0)
    local halfMaxs = Vector(duckMaxs.x, duckMaxs.y, duckHeight * UPar.DetectorMAGIC.PULSE_PASS_HEIGHT)
    local passStart = landing + Vector(0, 0, duckHeight * UPar.DetectorMAGIC.PULSE_PASS_HEIGHT)
    local passTrace = util.TraceHull({
        filter = ply,
        mask = MASK_PLAYERSOLID,
        start = passStart,
        endpos = passStart + dir * playerWidth * UPar.DetectorMAGIC.PULSE_FORWARD,
        mins = halfMins,
        maxs = halfMaxs,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    })
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
        }
    end

    local reverseTrace = util.TraceHull({
        filter = ply,
        mask = MASK_PLAYERSOLID,
        start = dropTrace.HitPos,
        endpos = dropTrace.HitPos - dir * reverseLength,
        mins = standMins,
        maxs = standMaxs,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    })
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
    }
end


if SERVER then
    concommand.Add('upar_detector_obstacle_test', function(ply)
        if not IsValid(ply) then 
            print('[UPar] 没有可用玩家') 
            return 
        end

        local pos = ply:GetPos()
        local probeDirection = NormalizeXY(ply:GetAimVector()) * 100
        local traceResult = ObstacleDetector(ply, pos, probeDirection)
    end)

    concommand.Add('upar_detector_height_test', function(ply, _, args)
        if not IsValid(ply) then
            print('[UPar] 没有可用玩家')
            return
        end

        local startHeight = 32
        local endHeight = 128
        local step = 18
        local dir = NormalizeXY(ply:GetAimVector())
        local obstacleHitPos = ply:GetPos() + dir * 100
        local probeEndPos = obstacleHitPos + dir * 50

        local probe, probes = HeightDetector(
            ply,
            obstacleHitPos,
            probeEndPos,
            startHeight,
            endHeight,
            step
        )
        if not probe then
            print('[UPar] 未找到可站立面')
            return
        end

        local height = probe.HitPos.z - ply:GetPos().z
        print(string.format('[UPar] height=%.2f, count=%d, step=%.d', height, #probes, step))
    end)

    concommand.Add('upar_detector_type_test', function(ply)
        if not IsValid(ply) then
            print('[UPar] 没有可用玩家')
            return
        end

        local dir = NormalizeXY(ply:GetAimVector())
        local kind, result = UPar.ClassifyObstacleType(ply, dir)
        if not kind then
            print('[UPar] 未识别为台型或脉冲型')
            return
        end

        local thickness = result.thickness and string.format('%.2f', result.thickness) or 'nil'
        print(string.format(
            '[UPar] type=%s height=%.2f drop=%.2f thickness=%s canStand=%s',
            kind, result.height, result.dropTravel or -1, thickness, tostring(result.canStand)
        ))
    end)
end
