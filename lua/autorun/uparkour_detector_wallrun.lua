UPar = UPar or {}

UPar.WallrunMAGIC = {
    HEAD_CHECK_DISTANCE = 10, -- 垂直墙跑头顶检测长度, Source 单位
    GROUND_CHECK_DISTANCE = 5, -- 跳起瞬间确认是否贴近地面, Source 单位
    HORIZONTAL_UP_HEIGHT = 36, -- 水平墙跑起升高度, Source 单位
    SIDE_REACH  = 1.0, -- 左右探针距离, × 玩家宽度
    FRONT_REACH = 1.0, -- 前方探针距离, × 玩家宽度
    HEIGHT_MID  = 0.5, -- 中探针高度, × 玩家身高
    HEIGHT_HIGH = 0.75,-- 高探针高度, × 玩家身高
    NORMAL_Z    = 0.2, -- 水平法线最大 Z
    NORMAL_DOT  = 0.7, -- 法线方向一致性
    WIDTH_OFFSET = 0.5,-- 宽度采样偏移, × 玩家宽度
    WIDTH_REACH = 2.0, -- 宽度探针距离, × 玩家宽度
    RAY_DEBUG_RADIUS = 1,-- 射线调试盒半径
    DEBUG_TTL = 3,      -- 调试图形持续时间
    DEBUG_POINT_RADIUS = 3,-- 调试命中点半径
}

local DEBUG_COLOR = {
    LEFT  = Color(0, 255, 0, 50),
    RIGHT = Color(255, 0, 0, 50),
    FRONT = Color(0, 255, 255, 50),
    WALL_LOST = Color(255, 0, 0, 50),
    WALL_OK = Color(0, 255, 0, 50),
    HEAD = Color(255, 128, 0, 50),
}

local ZERO_ANGLE = Angle(0, 0, 0)

local function NormalizeXY(vector)
    vector = Vector(vector)
    vector[3] = 0
    vector:Normalize()
    return vector
end

local function IsWallrunProbe(probe)
    if not probe.Hit or probe.StartSolid then return false end
    if math.abs(probe.HitNormal.z) > UPar.WallrunMAGIC.NORMAL_Z then return false end
    if SERVER and IsValid(probe.Entity) and probe.Entity:IsPlayerHolding() then return false end
    return UPar.IsObstacleEntity(probe.Entity)
end

local function ProbeWall(ply, position, direction, length, height, color)
    local start = position + Vector(0, 0, height)
    local probe = util.TraceLine({
        filter = ply,
        mask = MASK_PLAYERSOLID,
        start = start,
        endpos = start + direction * length,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    })
    local radius = UPar.WallrunMAGIC.RAY_DEBUG_RADIUS
    debugoverlay.SweptBox(
        probe.StartPos,
        probe.HitPos,
        Vector(-radius, -radius, -radius),
        Vector(radius, radius, radius),
        ZERO_ANGLE,
        UPar.WallrunMAGIC.DEBUG_TTL,
        color
    )
    if probe.Hit then
        debugoverlay.Sphere(probe.HitPos, UPar.WallrunMAGIC.DEBUG_POINT_RADIUS,
            UPar.WallrunMAGIC.DEBUG_TTL, true, color)
    end
    return probe
end

local function ProbeSide(ply, position, direction, length, playerHeight, color)
    local probes = {}
    local normal = Vector(0, 0, 0)
    local count = 0
    for _, ratio in ipairs({ UPar.WallrunMAGIC.HEIGHT_MID, UPar.WallrunMAGIC.HEIGHT_HIGH }) do
        local probe = ProbeWall(ply, position, direction, length, playerHeight * ratio, color)
        probes[#probes + 1] = probe
        if IsWallrunProbe(probe) then
            count = count + 1
            normal = normal + probe.HitNormal
        end
    end
    if normal:LengthSqr() > 0 then
        normal:Normalize()
    end
    return count, normal, probes
end

local function DetectHorizontalWallrun(ply, position, forward, right, playerWidth, playerHeight)
    local sideLength = playerWidth * UPar.WallrunMAGIC.SIDE_REACH
    local leftCount, leftNormal, leftProbes =
        ProbeSide(ply, position, -right, sideLength, playerHeight, DEBUG_COLOR.LEFT)
    local rightCount, rightNormal, rightProbes =
        ProbeSide(ply, position, right, sideLength, playerHeight, DEBUG_COLOR.RIGHT)

    if leftCount >= #leftProbes and rightCount >= #rightProbes then
        return nil, leftCount, rightCount
    end

    local side, away, normal
    if leftCount >= #leftProbes then
        side, away, normal = 'left', right, leftNormal
    elseif rightCount >= #rightProbes then
        side, away, normal = 'right', -right, rightNormal
    end
    if not normal or normal:Dot(away) < UPar.WallrunMAGIC.NORMAL_DOT then
        return nil, leftCount, rightCount
    end

    local along = Vector(-normal.y, normal.x, 0)
    if along:Dot(forward) < 0 then
        along = -along
    end
    local probeDirection = NormalizeXY(-normal)
    local widthHits = 0
    local color = side == 'left' and DEBUG_COLOR.LEFT or DEBUG_COLOR.RIGHT
    local probes = {
        ProbeWall(
            ply,
            position + along * playerWidth * UPar.WallrunMAGIC.WIDTH_OFFSET,
            probeDirection,
            playerWidth * UPar.WallrunMAGIC.WIDTH_REACH,
            playerHeight * UPar.WallrunMAGIC.HEIGHT_MID,
            color
        ),
        ProbeWall(
            ply,
            position - along * playerWidth * UPar.WallrunMAGIC.WIDTH_OFFSET,
            probeDirection,
            playerWidth * UPar.WallrunMAGIC.WIDTH_REACH,
            playerHeight * UPar.WallrunMAGIC.HEIGHT_MID,
            color
        ),
    }
    for _, probe in ipairs(probes) do
        if IsWallrunProbe(probe)
            and probe.HitNormal:Dot(normal) >= UPar.WallrunMAGIC.NORMAL_DOT then
            widthHits = widthHits + 1
        end
    end
    if widthHits < #probes then
        return nil, leftCount, rightCount
    end

    return UPar.HorizontalWallrun{
        side = side,
        normal = normal,
        along = along,
        leftCount = leftCount,
        rightCount = rightCount,
        widthHits = widthHits,
        hasLift = UPar.IsWallrunGroundClose(ply),
    }, leftCount, rightCount
end

local function DetectVerticalWallrun(ply, position, forward, playerWidth, playerHeight)
    local probes = {}
    local normal = Vector(0, 0, 0)
    local contactPos
    local count = 0

    for _, ratio in ipairs({ UPar.WallrunMAGIC.HEIGHT_MID, UPar.WallrunMAGIC.HEIGHT_HIGH }) do
        local probe = ProbeWall(
            ply, position, forward, playerWidth * UPar.WallrunMAGIC.FRONT_REACH,
            playerHeight * ratio, DEBUG_COLOR.FRONT
        )
        probes[#probes + 1] = probe
        if IsWallrunProbe(probe) then
            count = count + 1
            normal = normal + probe.HitNormal
            contactPos = contactPos or probe.HitPos
        end
    end

    if count < #probes or normal:LengthSqr() == 0 then
        return nil, count
    end

    normal:Normalize()

    local up = Vector(0, 0, 1)
    local along = up - normal * up:Dot(normal)
    along:Normalize()

    local widthDir = Vector(-normal.y, normal.x, 0)
    widthDir:Normalize()

    local widthHits = 0
    local widthProbes = {
        ProbeWall(
            ply,
            position + widthDir * playerWidth * UPar.WallrunMAGIC.WIDTH_OFFSET,
            forward,
            playerWidth * UPar.WallrunMAGIC.WIDTH_REACH,
            playerHeight * UPar.WallrunMAGIC.HEIGHT_MID,
            DEBUG_COLOR.FRONT
        ),
        ProbeWall(
            ply,
            position - widthDir * playerWidth * UPar.WallrunMAGIC.WIDTH_OFFSET,
            forward,
            playerWidth * UPar.WallrunMAGIC.WIDTH_REACH,
            playerHeight * UPar.WallrunMAGIC.HEIGHT_MID,
            DEBUG_COLOR.FRONT
        ),
    }
    for _, probe in ipairs(widthProbes) do
        if IsWallrunProbe(probe)
            and probe.HitNormal:Dot(normal) >= UPar.WallrunMAGIC.NORMAL_DOT then
            widthHits = widthHits + 1
        end
    end
    if widthHits < #widthProbes then
        return nil, count
    end

    return UPar.VerticalWallrun{
        normal = normal,
        along = along,
        contactPos = contactPos,
        frontCount = count,
        widthHits = widthHits,
    }, count
end

function UPar.DetectWallrun(ply)
    -- 分别检测左右墙和前方墙，返回候选几何
    local position = ply:GetPos()
    local yaw = Angle(0, ply:EyeAngles().y, 0)
    local forward = NormalizeXY(yaw:Forward())
    local right = NormalizeXY(yaw:Right())
    local mins, maxs = ply:GetCollisionBounds()
    local playerWidth = math.max(maxs.x - mins.x, maxs.y - mins.y)
    local playerHeight = maxs.z - mins.z

    local horizontal, leftCount, rightCount =
        DetectHorizontalWallrun(ply, position, forward, right, playerWidth, playerHeight)
    local vertical, frontCount =
        DetectVerticalWallrun(ply, position, forward, playerWidth, playerHeight)

    return vertical, horizontal, {
        leftCount = leftCount,
        rightCount = rightCount,
        frontCount = frontCount,
    }
end

function UPar.IsWallrunWallLost(ply, data)
    local mins, maxs = ply:GetCollisionBounds()
    local playerWidth = math.max(maxs.x - mins.x, maxs.y - mins.y)
    local start = ply:GetPos() + Vector(0, 0, (maxs.z - mins.z) * 0.5)
    local endpos = start - data.normal * playerWidth * UPar.WallrunMAGIC.FRONT_REACH
    local trace = util.TraceLine({
        filter = ply,
        mask = MASK_PLAYERSOLID,
        start = start,
        endpos = endpos,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    })

    local lost = not trace.Hit
        or trace.StartSolid
        or not UPar.IsObstacleEntity(trace.Entity)
        or trace.HitNormal:Dot(data.normal) < UPar.WallrunMAGIC.NORMAL_DOT

    debugoverlay.Line(start, trace.HitPos or endpos, UPar.WallrunMAGIC.DEBUG_TTL,
        lost and DEBUG_COLOR.WALL_LOST or DEBUG_COLOR.WALL_OK, true)
    return lost
end

function UPar.IsWallrunHeadBlocked(ply, data)
    local mins, maxs = ply:GetCollisionBounds()
    local startPos = ply:GetPos() + Vector(0, 0, maxs.z)
    local endPos = startPos + data.along * UPar.WallrunMAGIC.HEAD_CHECK_DISTANCE
    local trace = util.TraceLine({
        filter = ply,
        mask = MASK_PLAYERSOLID,
        start = startPos,
        endpos = endPos,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    })
    local blocked = trace.Hit or trace.StartSolid
    debugoverlay.Line(startPos, trace.HitPos or endPos, UPar.WallrunMAGIC.DEBUG_TTL,
        blocked and DEBUG_COLOR.WALL_LOST or DEBUG_COLOR.HEAD, true)
    return blocked
end

function UPar.IsHorizontalWallrunWallLost(ply, data)
    local mins, maxs = ply:GetCollisionBounds()
    local playerWidth = math.max(maxs.x - mins.x, maxs.y - mins.y)
    local start = ply:GetPos() + Vector(0, 0, (maxs.z - mins.z) * 0.5)
    local endpos = start - data.normal * playerWidth * UPar.WallrunMAGIC.FRONT_REACH
    local trace = util.TraceLine({
        filter = ply,
        mask = MASK_PLAYERSOLID,
        start = start,
        endpos = endpos,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    })

    local lost = not trace.Hit
        or trace.StartSolid
        or not UPar.IsObstacleEntity(trace.Entity)
        or trace.HitNormal:Dot(data.normal) < UPar.WallrunMAGIC.NORMAL_DOT

    debugoverlay.Line(start, trace.HitPos or endpos, UPar.WallrunMAGIC.DEBUG_TTL,
        lost and DEBUG_COLOR.WALL_LOST or DEBUG_COLOR.WALL_OK, true)
    return lost
end

function UPar.IsHorizontalWallrunForwardBlocked(ply, data)
    local mins, maxs = ply:GetCollisionBounds()
    local playerWidth = math.max(maxs.x - mins.x, maxs.y - mins.y)
    local start = ply:GetPos() + Vector(0, 0, (maxs.z - mins.z) * 0.5)
    local endpos = start + data.along * playerWidth * UPar.WallrunMAGIC.FRONT_REACH
    local trace = util.TraceLine({
        filter = ply,
        mask = MASK_PLAYERSOLID,
        start = start,
        endpos = endpos,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    })
    local blocked = trace.Hit or trace.StartSolid

    debugoverlay.Line(start, trace.HitPos or endpos, UPar.WallrunMAGIC.DEBUG_TTL,
        blocked and DEBUG_COLOR.WALL_LOST or DEBUG_COLOR.WALL_OK, true)
    return blocked
end

function UPar.IsWallrunGroundClose(ply)
    local mins, maxs = ply:GetCollisionBounds()
    local startPos = ply:GetPos()
    local endPos = startPos - Vector(0, 0, UPar.WallrunMAGIC.GROUND_CHECK_DISTANCE)
    local trace = util.TraceHull({
        filter = ply,
        mask = MASK_PLAYERSOLID,
        start = startPos,
        endpos = endPos,
        mins = Vector(mins.x, mins.y, 0),
        maxs = Vector(maxs.x, maxs.y, 1),
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    })
    return trace.Hit or trace.StartSolid
end

if SERVER then
    concommand.Add('upar_detector_wallrun_test', function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        if not IsValid(ply) then
            print('[UPar] 没有可用玩家')
            return
        end

        local vertical, horizontal, counts = UPar.DetectWallrun(ply)
        if not vertical and not horizontal then
            print(string.format(
                '[UPar] no wallrun left=%d right=%d front=%d',
                counts.leftCount, counts.rightCount, counts.frontCount
            ))
            return
        end

        local function PrintResult(kind, result)
            local widthHits = result.widthHits or 0
            local normal = result.normal or vector_origin
            local along = result.along or vector_origin
            print(string.format(
                '[UPar] wallrun=%s side=%s left=%d right=%d front=%d width=%d normal=(%.3f, %.3f, %.3f) along=(%.3f, %.3f, %.3f)',
                kind, tostring(result.side), result.leftCount or 0, result.rightCount or 0,
                result.frontCount or 0, widthHits,
                normal.x, normal.y, normal.z, along.x, along.y, along.z
            ))
        end

        if vertical then PrintResult('vertical', vertical) end
        if horizontal then PrintResult('horizontal', horizontal) end
    end)
end
