UPar = UPar or {}

UPar.ActionMAGIC = {
    VERTICAL_WALLRUN_SEGMENT_END_SPEED_SCALE = 0.7,
    VERTICAL_WALLRUN_SEGMENT_HEIGHT = 48,
    VERTICAL_WALLRUN_HOVER_SPEED = 20,
    VERTICAL_WALLRUN_HOVER_DISTANCE = 48,
    VERTICAL_WALLRUN_HOVER_BUFFER_STEPS = 3,
    VERTICAL_WALLRUN_HOVER_BUFFER_STEP = 6,
    VERTICAL_WALLRUN_JUMP_ANGLE = 45,
    VERTICAL_WALLRUN_JUMP_SPEED_MULTIPLIER = 0.75,
    VERTICAL_WALLRUN_DIE_DOWN_SPEED = 500,
    HORIZONTAL_WALLRUN_STEP_INTERVAL = 0.2,
    HORIZONTAL_WALLRUN_DIE_DOWN_SPEED = 500,
    HORIZONTAL_WALLRUN_JUMP_ANGLE = 45,
    HORIZONTAL_WALLRUN_JUMP_SPEED_MULTIPLIER = 0.75,
    WALLRUN_LAST_ANGLE_MIN = 80,

    PULSE_APEX_THICK = 10,
    PULSE_APEX_THIN = 5,
    PULSE_APEX_DOUBLE = 10,
    PULSE_THICKNESS_THRESHOLD = 50, -- Source 单位

    HIGHCLIMB_DELAY = 0.1,

    DOUBLEVAULT_CLIMB_EXIT_SCALE = 0.2,
    DIRECTION_CHECK_MIN_SPEED = 200,
    DIE_DOWN_SPEED = 600,
    VAULT_DIE_DOWN_SPEED = 300,
}

local DETECT_PARKOUR = 1
local DETECT_WALLRUN = 2
local DETECT_ALL = DETECT_PARKOUR + DETECT_WALLRUN

local upar_enabled = CreateConVar(
    'upar_enabled', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)

local upar_continuous_detect = CreateConVar(
    'upar_continuous_detect', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)

local upar_continuous_detect_interval = CreateConVar(
    'upar_continuous_detect_interval', '3', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)

local upar_facing_angle_delta = CreateConVar(
    'upar_facing_angle_delta', '40', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)

local upar_speed_angle_delta = CreateConVar(
    'upar_speed_angle_delta', '120', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)

local upar_speed_use_velocity = CreateConVar(
    'upar_speed_use_velocity', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_speed_climb = CreateConVar(
    'upar_speed_climb', '200', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_speed_vault = CreateConVar(
    'upar_speed_vault', '200', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_speed_doublevault_state_1 = CreateConVar(
    'upar_speed_doublevault_state_1', '200',
    { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_speed_doublevault_state_2 = CreateConVar(
    'upar_speed_doublevault_state_2', '200',
    { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_speed_vertical_wallrun = CreateConVar(
    'upar_speed_vertical_wallrun', '300',
    { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_speed_horizontal_wallrun = CreateConVar(
    'upar_speed_horizontal_wallrun', '300',
    { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_speed_vertical_wallrun_jump = CreateConVar(
    'upar_speed_vertical_wallrun_jump', '300',
    { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_speed_horizontal_wallrun_jump = CreateConVar(
    'upar_speed_horizontal_wallrun_jump', '300',
    { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_wallrun_horizontal_angle = CreateConVar(
    'upar_wallrun_horizontal_angle', '5',
    { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_wallrun_vertical_angle = CreateConVar(
    'upar_wallrun_vertical_angle', '40',
    { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_horizontal_wallrun_duration = CreateConVar(
    'upar_horizontal_wallrun_duration', '1',
    { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_vertical_wallrun_height_ratio = CreateConVar(
    'upar_vertical_wallrun_height_ratio', '1.4',
    { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)

local upar_key_vault_require_shift = CreateConVar(
    'upar_key_vault_require_shift', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_key_doublevault_require_shift = CreateConVar(
    'upar_key_doublevault_require_shift', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_key_block_backstrafe = CreateConVar(
    'upar_key_block_backstrafe', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_crouch_block = CreateConVar(
    'upar_crouch_block', '0', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)

local upar_lowclimb_enabled = CreateConVar(
    'upar_lowclimb_enabled', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_highclimb_enabled = CreateConVar(
    'upar_highclimb_enabled', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_vault_enabled = CreateConVar(
    'upar_vault_enabled', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_doublevault_enabled = CreateConVar(
    'upar_doublevault_enabled', '1', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_vertical_wallrun_enabled = CreateConVar(
    'upar_vertical_wallrun_enabled', '1',
    { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_horizontal_wallrun_enabled = CreateConVar(
    'upar_horizontal_wallrun_enabled', '1',
    { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_lowclimb_min_height = CreateConVar(
    'upar_lowclimb_min_height', '0.4', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_lowclimb_max_height = CreateConVar(
    'upar_lowclimb_max_height', '0.86', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_highclimb_min_height = CreateConVar(
    'upar_highclimb_min_height', '0.87', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_highclimb_max_height = CreateConVar(
    'upar_highclimb_max_height', '1.2', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_lowclimb_trigger_ratio = CreateConVar(
    'upar_lowclimb_trigger_ratio', '0.278', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_highclimb_trigger_ratio = CreateConVar(
    'upar_highclimb_trigger_ratio', '0.278', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_vault_trigger_ratio = CreateConVar(
    'upar_vault_trigger_ratio', '0.48', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_doublevault_trigger_ratio = CreateConVar(
    'upar_doublevault_trigger_ratio', '0.278', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_trigger_speed_comp_factor = CreateConVar(
    'upar_trigger_speed_comp_factor', '3', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_lowclimb_trigger_speed_comp = CreateConVar(
    'upar_lowclimb_trigger_speed_comp', '0.5', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_highclimb_trigger_speed_comp = CreateConVar(
    'upar_highclimb_trigger_speed_comp', '0.5', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_vault_trigger_speed_comp = CreateConVar(
    'upar_vault_trigger_speed_comp', '1.5', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)
local upar_doublevault_trigger_speed_comp = CreateConVar(
    'upar_doublevault_trigger_speed_comp', '0.5', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)

if not SERVER then return end

local function IsDev()
    local convar = GetConVar('developer')
    return convar ~= nil and convar:GetInt() > 0
end

local function GetFlatViewDirection(ply)
    local direction = ply:EyeAngles():Forward()
    direction[3] = 0
    direction:Normalize()
    return direction
end

local function AllowAction(ply, action, kind, data, cmd)
    local context = {
        action = action,
        kind = kind,
        data = data,
        cmd = cmd
    }

    return hook.Run('UParActionCondition', ply, context) ~= false
end

local function ApplyActionNodes(ply, action, kind, data, cmd, nodes)
    if not nodes then return end

    local context = {
        action = action,
        kind = kind,
        data = data,
        cmd = cmd,
    }

    local result = hook.Run('UParActionNodes', ply, context, nodes)
    if istable(result) then return result end
    return nodes
end

local function GetTriggerRatio(effect)
    if effect == 'low_climb' then return upar_lowclimb_trigger_ratio:GetFloat() end
    if effect == 'high_climb' then return upar_highclimb_trigger_ratio:GetFloat() end
    if effect == 'vault' then return upar_vault_trigger_ratio:GetFloat() end
    return upar_doublevault_trigger_ratio:GetFloat()
end

local function GetTriggerSpeedComp(effect)
    if effect == 'low_climb' then return upar_lowclimb_trigger_speed_comp:GetFloat() end
    if effect == 'high_climb' then return upar_highclimb_trigger_speed_comp:GetFloat() end
    if effect == 'vault' then return upar_vault_trigger_speed_comp:GetFloat() end
    return upar_doublevault_trigger_speed_comp:GetFloat()
end

local function WithinTriggerDistance(ply, data, effect)
    local mins, maxs = ply:GetCollisionBounds()
    local playerHeight = maxs.z - mins.z
    local playerWidth = math.max(maxs.x - mins.x, maxs.y - mins.y)
    local distance = playerHeight * GetTriggerRatio(effect)

    local toObstacle = data.obstacle.HitPos - ply:GetPos()
    toObstacle.z = 0
    local obstacleDistance = toObstacle:Length()
    if obstacleDistance > 0 then
        local direction = toObstacle / obstacleDistance
        local speedToward = math.max(0, ply:GetVelocity():Dot(direction))
        local rawComp = speedToward * FrameTime() * math.max(0, upar_trigger_speed_comp_factor:GetFloat())
        local maxComp = playerWidth * math.max(0, GetTriggerSpeedComp(effect))
        local speedComp = math.min(rawComp, maxComp)

        if IsDev() then 
            print(string.format('[UPar] obsDist=%f, triggerDistBase=%f, speedComp=%f', obstacleDistance, distance, speedComp))
        end

        distance = distance + speedComp
    end

    return obstacleDistance <= distance
end

local function BuildClimbMove(ply, data, direction, effect)
    local startPos = ply:GetPos()
    local endPos = data.landing
    local dir = (endPos - startPos):GetNormal()
    local speed = ply:GetWalkSpeed()
    local speedOverride = upar_speed_climb:GetFloat()
    if speedOverride > 0 then speed = speedOverride end
    if upar_speed_use_velocity:GetBool() then
        speed = math.max(ply:GetVelocity():Dot(dir), speed)
    end
    local addKeys = data.canStand and 0 or IN_DUCK
    local removeKeys = bit.bor(IN_DUCK, IN_JUMP)
    return {
        UPar.Node{
            pos = startPos,
            speed = speed,
            movetype = MOVETYPE_NOCLIP,
            flag = effect .. '_start',
            payload = {
                landing = data.landing,
                normal = data.obstacleNormal,
            },
            addKeys = addKeys,
            removeKeys = removeKeys,
            delay = effect == 'high_climb' and UPar.ActionMAGIC.HIGHCLIMB_DELAY or 0,
        },
        UPar.Node{
            pos = endPos,
            speed = 0,
            flag = effect .. '_end',
            addKeys = addKeys,
            removeKeys = removeKeys,
        },
    }
end

local function BuildVaultMove(ply, data, direction, effect)
    local startPos = ply:GetPos()
    local endPos = data.vaultLanding
    local dir = (endPos - startPos):GetNormal()
    local speed = ply:GetWalkSpeed()
    local speedOverride = upar_speed_vault:GetFloat()
    if speedOverride > 0 then speed = speedOverride end
    if upar_speed_use_velocity:GetBool() then
        speed = math.max(ply:GetVelocity():Dot(dir), speed)
    end
    local removeKeys = bit.bor(IN_DUCK, IN_JUMP)

    local thickness = data.thickness or math.huge
    local apexOffset = thickness < UPar.ActionMAGIC.PULSE_THICKNESS_THRESHOLD
        and UPar.ActionMAGIC.PULSE_APEX_THIN
        or UPar.ActionMAGIC.PULSE_APEX_THICK

    local apex = Vector(
        data.landing.x,
        data.landing.y,
        data.vaultLanding.z + apexOffset
    )
    local exitvel = direction * speed

    return {
        UPar.Node{
            pos = startPos,
            speed = speed,
            movetype = MOVETYPE_NOCLIP,
            flag = effect .. '_start',
            payload = {
                landing = data.landing,
                vaultLanding = data.vaultLanding,
                normal = data.obstacleNormal,
            },
            removeKeys = removeKeys,
        },
        UPar.Node{
            pos = apex,
            speed = speed,
            removeKeys = removeKeys,
        },
        UPar.Node{
            pos = endPos,
            speed = speed,
            movetype = MOVETYPE_WALK,
            flag = 'vault_end',
            -- exitvel = exitvel,
            removeKeys = removeKeys,
        },
    }
end

local function BuildDoubleVaultMove(ply, data, direction, effect)
    local startPos = ply:GetPos()
    local climbPoint = Vector(data.landing.x, data.landing.y, data.vaultLanding.z)
    local apex = Vector(
        (climbPoint.x + data.vaultLanding.x) * 0.5,
        (climbPoint.y + data.vaultLanding.y) * 0.5,
        data.vaultLanding.z + UPar.ActionMAGIC.PULSE_APEX_DOUBLE
    )
    local endPos = data.vaultLanding

    local dir_state1 = (climbPoint - startPos):GetNormal()
    local dir_state2 = (endPos - climbPoint):GetNormal()

    local speed_state1 = ply:GetWalkSpeed()
    local speed_state1_override = upar_speed_doublevault_state_1:GetFloat()
    if speed_state1_override > 0 then speed_state1 = speed_state1_override end
    if upar_speed_use_velocity:GetBool() then
        speed_state1 = math.max(ply:GetVelocity():Dot(dir_state1), speed_state1)
    end

    local speed_state2 = ply:GetWalkSpeed()
    local speed_state2_override = upar_speed_doublevault_state_2:GetFloat()
    if speed_state2_override > 0 then speed_state2 = speed_state2_override end
    if upar_speed_use_velocity:GetBool() then
        speed_state2 = math.max(ply:GetVelocity():Dot(dir_state2), speed_state2)
    end
    local climbExitSpeed = speed_state1 * UPar.ActionMAGIC.DOUBLEVAULT_CLIMB_EXIT_SCALE
    local removeKeys = bit.bor(IN_DUCK, IN_JUMP)


    local exitvel = direction * speed_state2

    return {
        UPar.Node{
            pos = startPos,
            speed = speed_state1,
            movetype = MOVETYPE_NOCLIP,
            flag = 'double_vault_state1',
            payload = {
                landing = data.landing,
                normal = data.obstacleNormal,
            },
            removeKeys = removeKeys,
            delay = UPar.ActionMAGIC.HIGHCLIMB_DELAY,
        },
        UPar.Node{
            pos = climbPoint,
            speed = climbExitSpeed,
            flag = 'double_vault_state2',
            payload = {
                vaultLanding = data.vaultLanding,
                normal = data.obstacleNormal,
            },
            removeKeys = removeKeys,
        },
        UPar.Node{
            pos = apex,
            speed = speed_state2,
            removeKeys = removeKeys,
        },
        UPar.Node{
            pos = endPos,
            speed = speed_state2,
            flag = 'double_vault_end',
            exitvel = exitvel,
            removeKeys = removeKeys,
        },
    }
end

local function BuildVerticalWallrunMove(ply, data)
    local startPos = ply:GetPos()
    local up = data.along
    local speed = 0.5 * (ply:GetWalkSpeed() + ply:GetRunSpeed())
    local speedOverride = upar_speed_vertical_wallrun:GetFloat()
    if speedOverride > 0 then speed = speedOverride end
    local segmentStartSpeed = speed
    local segmentEndSpeed = segmentStartSpeed
        * UPar.ActionMAGIC.VERTICAL_WALLRUN_SEGMENT_END_SPEED_SCALE
    local mins, maxs = ply:GetCollisionBounds()
    local totalHeight = (maxs.z - mins.z) * upar_vertical_wallrun_height_ratio:GetFloat()
    local segmentHeight = UPar.ActionMAGIC.VERTICAL_WALLRUN_SEGMENT_HEIGHT
    local segments = totalHeight / segmentHeight
    local segmentCount = math.ceil(segments)
    local nodes = {
        UPar.Node{
            pos = startPos,
            speed = segmentStartSpeed,
            movetype = MOVETYPE_WALK,
            flag = 'vertical_wallrun_start',
            payload = {
                normal = data.normal,
                along = data.along,
                contactPos = data.contactPos,
            },
        },
    }

    for i = 1, segmentCount do
        local to = startPos + up * math.min(i * segmentHeight, totalHeight)

        nodes[#nodes + 1] = UPar.Node{
            pos = to,
            speed = segmentEndSpeed,
            flag = 'vertical_wallrun_step',
        }

        if i < segmentCount then
            nodes[#nodes + 1] = UPar.Node{
                pos = to,
                speed = segmentStartSpeed,
            }
        end
    end

    local hoverStart = startPos + up * totalHeight
    local hoverPos = hoverStart
    local hoverSteps = UPar.ActionMAGIC.VERTICAL_WALLRUN_HOVER_BUFFER_STEPS
    for i = 1, hoverSteps do
        local t = i / hoverSteps
        local speed = segmentEndSpeed
            + (UPar.ActionMAGIC.VERTICAL_WALLRUN_HOVER_SPEED - segmentEndSpeed) * t
        hoverPos = hoverPos + up * UPar.ActionMAGIC.VERTICAL_WALLRUN_HOVER_BUFFER_STEP
        nodes[#nodes + 1] = UPar.Node{
            pos = hoverPos,
            speed = speed,
        }
    end
    nodes[#nodes + 1] = UPar.Node{
        pos = hoverPos - up * UPar.ActionMAGIC.VERTICAL_WALLRUN_HOVER_DISTANCE,
        speed = UPar.ActionMAGIC.VERTICAL_WALLRUN_HOVER_SPEED,
        flag = 'vertical_wallrun_end',
    }

    return nodes
end

local function BuildHorizontalWallrunMove(ply, data)
    local startPos = ply:GetPos()
    local direction = data.along
    local speed = 0.5 * (ply:GetWalkSpeed() + ply:GetRunSpeed())
    local speedOverride = upar_speed_horizontal_wallrun:GetFloat()
    if speedOverride > 0 then speed = speedOverride end
    if upar_speed_use_velocity:GetBool() then
        speed = math.max(ply:GetVelocity():Dot(direction), speed)
    end

    local duration = upar_horizontal_wallrun_duration:GetFloat()
    local totalLength = speed * duration
    local segmentCount = duration / UPar.ActionMAGIC.HORIZONTAL_WALLRUN_STEP_INTERVAL
    local loopCount = math.ceil(segmentCount)
    local segmentLength = totalLength / segmentCount
    local nodes = {
        UPar.Node{
            pos = startPos,
            speed = speed,
            movetype = MOVETYPE_WALK,
            flag = 'horizontal_wallrun_start',
            payload = {
                normal = data.normal,
                along = direction,
                side = data.side,
                contactPos = data.contactPos,
            },
        },
    }

    for i = 1, loopCount do
        local to = startPos + direction * math.min(i * segmentLength, totalLength)
        if data.hasLift then
            to = to + Vector(0, 0, UPar.WallrunMAGIC.HORIZONTAL_UP_HEIGHT)
        end
        local isLast = i == loopCount
        nodes[#nodes + 1] = UPar.Node{
            pos = to,
            speed = speed,
            flag = isLast and 'horizontal_wallrun_end' or 'horizontal_wallrun_step',
        }
    end

    return nodes
end

local function GetActionState(ply)
    local move = IsValid(ply) and ply.upar_motion
    if not move then return 'idle' end
    if move.action == 'wallrun' then return 'wallrun' end
    return 'parkour'
end

local function PublishMove(ply, nodes, action, motionMode)
    if not IsValid(ply) or not ply:Alive() or not nodes or #nodes < 2 then return end

    local move = UPar.Move(ply, nodes, motionMode)
    move.action = action
    if IsDev() then
        print(string.format('[UPar] action=%s nodes=%d', action, #nodes))
    end
    return move
end

local function GetWallRunNodes(ply, cmd)
    if not upar_vertical_wallrun_enabled:GetBool()
        and not upar_horizontal_wallrun_enabled:GetBool() then
        return
    end
    if ply:Crouching() then return end
    local forwardHeld = cmd and cmd:KeyDown(IN_FORWARD) or ply:KeyDown(IN_FORWARD)
    if not forwardHeld then return end

    local vertical, horizontal = UPar.DetectWallrun(ply)
    local viewDirection = GetFlatViewDirection(ply)

    local verticalSpeed = ply:GetVelocity().z
    local verticalCondition = vertical
        and upar_vertical_wallrun_enabled:GetBool()
        and verticalSpeed >= -math.abs(UPar.ActionMAGIC.VERTICAL_WALLRUN_DIE_DOWN_SPEED)
    if verticalCondition then
        local facingDot = viewDirection:Dot(-vertical.normal)
        verticalCondition = facingDot >= math.cos(math.rad(upar_wallrun_vertical_angle:GetFloat()))
    end

    local horizontalCondition = horizontal
        and upar_horizontal_wallrun_enabled:GetBool()
        and verticalSpeed >= -math.abs(UPar.ActionMAGIC.HORIZONTAL_WALLRUN_DIE_DOWN_SPEED)
    if horizontalCondition then
        local inwardAngle = math.deg(math.atan2(
            viewDirection:Dot(-horizontal.normal),
            viewDirection:Dot(horizontal.along)
        ))
        horizontalCondition = inwardAngle >= upar_wallrun_horizontal_angle:GetFloat()
    end

    local kind
    local data
    if verticalCondition and AllowAction(ply, 'vertical_wallrun', 'vertical', vertical, cmd) then
        kind, data = 'vertical', vertical
    elseif horizontalCondition
        and AllowAction(ply, 'horizontal_wallrun', 'horizontal', horizontal, cmd) then
        kind, data = 'horizontal', horizontal
    end

    if not kind then return end

    local normal = Vector(data.normal.x, data.normal.y, 0)
    normal:Normalize()

    local lastNormal = ply.upar_wallrun_last_normal
    if lastNormal and UPar.IsWallrunGroundClose(ply) then
        ply.upar_wallrun_last_normal = nil
        lastNormal = nil
    end

    if lastNormal then
        local dot = math.Clamp(normal:Dot(lastNormal), -1, 1)
        local angle = math.deg(math.acos(dot))
        if IsDev() then
            print(string.format(
                '[UPar] wallrun=%s angle=%.2f dot=%.4f',
                kind,
                angle,
                dot
            ))
        end
        if angle < UPar.ActionMAGIC.WALLRUN_LAST_ANGLE_MIN then return end
    elseif IsDev() then
        print(string.format('[UPar] wallrun=%s angle=first', kind))
    end

    local nodes
    if kind == 'vertical' then
        nodes = BuildVerticalWallrunMove(ply, data)
    else
        nodes = BuildHorizontalWallrunMove(ply, data)
    end

    if not nodes then return end
    local actionName = kind == 'vertical' and 'vertical_wallrun' or 'horizontal_wallrun'
    nodes = ApplyActionNodes(ply, actionName, kind, data, cmd, nodes)
    if not nodes or #nodes < 2 then return end

    ply.upar_wallrun_last_normal = normal
    return nodes, 'wallrun', data
end

local function GetParkourNodes(ply, cmd)
    local forwardHeld = cmd and cmd:KeyDown(IN_FORWARD) or ply:KeyDown(IN_FORWARD)

    local direction = GetFlatViewDirection(ply)
    local kind, data = UPar.ClassifyObstacleType(ply, direction)
    if not kind then return end
    local mins, maxs = ply:GetCollisionBounds()
    local playerHeight = maxs.z - mins.z
    local heightRatio = data.height / playerHeight

    local velocity = ply:GetVelocity()
    local horizontalVelocity = Vector(velocity.x, velocity.y, 0)
    local horizontalSpeed = horizontalVelocity:Length()
    local verticalSpeed = velocity.z
    local facingDot = direction:Dot(data.obstacleNormal)
    local totalCondition = facingDot <= -math.cos(math.rad(upar_facing_angle_delta:GetInt()))
    if verticalSpeed < -math.abs(UPar.ActionMAGIC.DIE_DOWN_SPEED) then
        totalCondition = false
    end
    if horizontalSpeed >= UPar.ActionMAGIC.DIRECTION_CHECK_MIN_SPEED then
        local velocityDirection = horizontalVelocity * (1 / horizontalSpeed)
        local speedDot = velocityDirection:Dot(data.obstacleNormal)
        if speedDot > -math.cos(math.rad(upar_speed_angle_delta:GetInt())) then
            totalCondition = false
        end
    end

    local shiftHeld = cmd and cmd:KeyDown(IN_SPEED) or ply:KeyDown(IN_SPEED)
    local climbGeometry = kind == 'platform' or kind == 'pulse'
    local lowMin = upar_lowclimb_min_height:GetFloat()
    local lowMax = upar_lowclimb_max_height:GetFloat()
    local highMin = upar_highclimb_min_height:GetFloat()
    local highMax = upar_highclimb_max_height:GetFloat()
    local lowHeight = heightRatio >= lowMin and heightRatio <= lowMax
    local highHeight = heightRatio >= highMin and heightRatio <= highMax

    if IsDev() then 
        print(string.format('[UPar] heightRatio=%.2f LOWCLIMB_MIN_HEIGHT=%.2f LOWCLIMB_MAX_HEIGHT=%.2f', heightRatio, lowMin, lowMax))
    end

    if IsDev() then 
        print(string.format('[UPar] heightRatio=%.2f HIGHCLIMB_MIN_HEIGHT=%.2f HIGHCLIMB_MAX_HEIGHT=%.2f', heightRatio, highMin, highMax))
    end


    local lowClimbCondition = upar_lowclimb_enabled:GetBool()
        and totalCondition and climbGeometry and lowHeight
        and WithinTriggerDistance(ply, data, 'low_climb')
    local highClimbCondition = upar_highclimb_enabled:GetBool()
        and totalCondition and climbGeometry and highHeight
        and WithinTriggerDistance(ply, data, 'high_climb')
    local vaultCondition = upar_vault_enabled:GetBool()
        and totalCondition and kind == 'pulse' and lowHeight
        and data.vaultLanding ~= nil and forwardHeld
        and verticalSpeed >= -math.abs(UPar.ActionMAGIC.VAULT_DIE_DOWN_SPEED)
        and (not upar_key_vault_require_shift:GetBool() or shiftHeld)
        and WithinTriggerDistance(ply, data, 'vault')
    local doubleVaultCondition = upar_doublevault_enabled:GetBool()
        and totalCondition and kind == 'pulse' and highHeight
        and data.vaultLanding ~= nil and forwardHeld
        and verticalSpeed >= -math.abs(UPar.ActionMAGIC.VAULT_DIE_DOWN_SPEED)
        and (not upar_key_doublevault_require_shift:GetBool() or shiftHeld)
        and WithinTriggerDistance(ply, data, 'double_vault')

    local nodes
    local action

    if doubleVaultCondition
        and AllowAction(ply, 'double_vault', kind, data, cmd) then
        nodes = BuildDoubleVaultMove(ply, data, direction, 'double_vault')
        if nodes then action = 'double_vault' end
    end

    if not nodes and vaultCondition
        and AllowAction(ply, 'vault', kind, data, cmd) then
        nodes = BuildVaultMove(ply, data, direction, 'vault')
        if nodes then action = 'vault' end
    end

    if not nodes and highClimbCondition
        and AllowAction(ply, 'high_climb', kind, data, cmd) then
        nodes = BuildClimbMove(ply, data, direction, 'high_climb')
        if nodes then action = 'high_climb' end
    end

    if not nodes and lowClimbCondition
        and AllowAction(ply, 'low_climb', kind, data, cmd) then
        nodes = BuildClimbMove(ply, data, direction, 'low_climb')
        if nodes then action = 'low_climb' end
    end

    if nodes then
        nodes = ApplyActionNodes(ply, action, kind, data, cmd, nodes)
    end

    return nodes, action
end

local function TryMove(ply, cmd, detectMask)
    if not IsValid(ply) or not ply:Alive() then return end

    local forwardHeld = cmd and cmd:KeyDown(IN_FORWARD) or ply:KeyDown(IN_FORWARD)
    local backHeld = cmd and cmd:KeyDown(IN_BACK) or ply:KeyDown(IN_BACK)
    local leftHeld = cmd and cmd:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVELEFT)
    local rightHeld = cmd and cmd:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_MOVERIGHT)
    local blockMoveKeys = backHeld or ((leftHeld or rightHeld) and not forwardHeld)
    if (upar_key_block_backstrafe:GetBool() and blockMoveKeys)
        or (upar_crouch_block:GetBool() and ply:Crouching()) then
        return
    end

    local state = GetActionState(ply)
    if state == 'wallrun' then
        if ply:GetMoveType() ~= MOVETYPE_WALK then return end
        if bit.band(detectMask, DETECT_PARKOUR) ~= 0 then
            local nodes, action = GetParkourNodes(ply, cmd)
            if nodes then
                UPar.EmitMoveFlag(ply, 'wallrun_interrupt')
                PublishMove(ply, nodes, action, UPar.MotionMode.TELEPORT)
            end
        end
        return
    end

    if state ~= 'idle' then return end
    if ply:GetMoveType() ~= MOVETYPE_WALK then return end

    local nodes, action
    if bit.band(detectMask, DETECT_PARKOUR) ~= 0 then
        nodes, action = GetParkourNodes(ply, cmd)
    end

    local wallrun
    local motionMode
    if not nodes and bit.band(detectMask, DETECT_WALLRUN) ~= 0 then
        nodes, action, wallrun = GetWallRunNodes(ply, cmd)
        if nodes then motionMode = UPar.MotionMode.VELOCITY end
    end

    local move = PublishMove(ply, nodes, action, motionMode)
    if move and action == 'wallrun' then move.wallrun = wallrun end
end

local function ShouldRunContinuousDetect(ply)
    if not upar_enabled:GetBool() then return false end

    local state = GetActionState(ply)
    if state == 'parkour' then return false end

    if not ply.upar_trigger_down then return false end
    if not upar_continuous_detect:GetBool() then return false end

    local nextDetect = ply.upar_action_next_detect_tick or 0
    if engine.TickCount() < nextDetect then return false end

    ply.upar_action_next_detect_tick = engine.TickCount()
        + math.max(1, upar_continuous_detect_interval:GetInt())
    return true
end

local function ShouldEndVerticalWallrun(ply, cmd)
    if ply:GetMoveType() ~= MOVETYPE_WALK then return true end

    local duckDown = cmd and cmd:KeyDown(IN_DUCK) or ply:KeyDown(IN_DUCK)
    if duckDown then return true end

    local move = ply.upar_motion
    local data = move and move.wallrun
    if not data then return true end
    return UPar.IsWallrunWallLost(ply, data) or UPar.IsWallrunHeadBlocked(ply, data)
end

local function UpdateVerticalWallrunState(ply, cmd, mv, move)
    local jumpDown = cmd and cmd:KeyDown(IN_JUMP) or ply:KeyDown(IN_JUMP)
    local jumpPressed = jumpDown and not ply.upar_wallrun_jump
    ply.upar_wallrun_jump = jumpDown

    if jumpPressed and move.nodeIndex > 1 then
        local angle = math.rad(UPar.ActionMAGIC.VERTICAL_WALLRUN_JUMP_ANGLE)
        local direction = GetFlatViewDirection(ply) * math.cos(angle) + Vector(0, 0, 1) * math.sin(angle)
        local jumpSpeed = (ply:GetJumpPower() + ply:GetWalkSpeed())
            * UPar.ActionMAGIC.VERTICAL_WALLRUN_JUMP_SPEED_MULTIPLIER
        local speedOverride = upar_speed_vertical_wallrun_jump:GetFloat()
        if speedOverride > 0 then jumpSpeed = speedOverride end
        local exitvel = direction * jumpSpeed
        UPar.AbortMove(ply)
        if mv then mv:SetVelocity(exitvel) end
        UPar.EmitMoveFlag(ply, 'vertical_wallrun_jump')
        return true
    end

    if ShouldEndVerticalWallrun(ply, cmd) then
        UPar.AbortMove(ply)
        UPar.EmitMoveFlag(ply, 'vertical_wallrun_end')
        return true
    end

    return false
end

local function ShouldEndHorizontalWallrun(ply, cmd, move, data)
    if ply:GetMoveType() ~= MOVETYPE_WALK then return true end

    local duckDown = cmd and cmd:KeyDown(IN_DUCK) or ply:KeyDown(IN_DUCK)
    if duckDown or ply:Crouching() then return true end
    if move.nodeIndex > 1 and ply:OnGround() then return true end
    return UPar.IsHorizontalWallrunWallLost(ply, data)
        or UPar.IsHorizontalWallrunForwardBlocked(ply, data)
end

local function UpdateHorizontalWallrunState(ply, cmd, mv, move)
    local data = move and move.wallrun
    if not data then return false end

    local jumpDown = cmd and cmd:KeyDown(IN_JUMP) or ply:KeyDown(IN_JUMP)
    local jumpPressed = jumpDown and not ply.upar_wallrun_jump
    ply.upar_wallrun_jump = jumpDown

    if jumpPressed and move.nodeIndex > 1 then
        local angle = math.rad(UPar.ActionMAGIC.HORIZONTAL_WALLRUN_JUMP_ANGLE)
        local jumpSpeed = (ply:GetJumpPower() + ply:GetWalkSpeed())
            * UPar.ActionMAGIC.HORIZONTAL_WALLRUN_JUMP_SPEED_MULTIPLIER
        local verticalSpeed = jumpSpeed * math.sin(angle)
        local horizontalSpeed = 0.5 * (ply:GetWalkSpeed() + ply:GetRunSpeed())
        local speedOverride = upar_speed_horizontal_wallrun_jump:GetFloat()
        if speedOverride > 0 then horizontalSpeed = speedOverride end
        if upar_speed_use_velocity:GetBool() then
            local velocity = ply:GetVelocity()
            local playerHorizontalSpeed = Vector(velocity.x, velocity.y, 0):Length()
            horizontalSpeed = math.max(playerHorizontalSpeed, horizontalSpeed)
        end
        local exitvel = GetFlatViewDirection(ply) * horizontalSpeed + Vector(0, 0, verticalSpeed)
        UPar.AbortMove(ply)
        if mv then mv:SetVelocity(exitvel) end
        UPar.EmitMoveFlag(ply, 'horizontal_wallrun_jump')
        return true
    end

    if ShouldEndHorizontalWallrun(ply, cmd, move, data) then
        UPar.AbortMove(ply)
        UPar.EmitMoveFlag(ply, 'horizontal_wallrun_end')
        return true
    end

    return false
end

local function UpdateWallrunState(ply, cmd, mv)
    local state = GetActionState(ply)
    if state ~= 'wallrun' then
        ply.upar_wallrun_jump = false
        return false
    end

    local move = ply.upar_motion
    local data = move and move.wallrun
    if not data then
        UPar.AbortMove(ply)
        if mv then mv:SetVelocity(vector_origin) end
        UPar.EmitMoveFlag(ply, 'wallrun_interrupt')
        return true
    end

    if data.TYPE == 'vertical' then
        return UpdateVerticalWallrunState(ply, cmd, mv, move)
    end

    if data.TYPE == 'horizontal' then
        return UpdateHorizontalWallrunState(ply, cmd, mv, move)
    end

    return false
end

hook.Add('SetupMove', 'upar.action.trigger', function(ply, mv, cmd)
    if UpdateWallrunState(ply, cmd, mv) then return end

    if not ShouldRunContinuousDetect(ply) then return end

    TryMove(ply, cmd, DETECT_PARKOUR)
end)

concommand.Add('+upar_trigger', function(ply)
    if not IsValid(ply) then return end
    if not upar_enabled:GetBool() then return end

    ply.upar_trigger_down = true
    TryMove(ply, nil, DETECT_ALL)
end)

concommand.Add('-upar_trigger', function(ply)
    if IsValid(ply) then ply.upar_trigger_down = false end
end)

concommand.Add('upar_trigger', function(ply)
    if IsValid(ply) and upar_enabled:GetBool() then TryMove(ply, nil, DETECT_ALL) end
end)

local function ResetActionState(ply)
    ply.upar_trigger_down = false
    ply.upar_action_next_detect_tick = 0
    ply.upar_wallrun_jump = false
    ply.upar_wallrun_last_normal = nil
end

hook.Add('PlayerDeath', 'upar.action.reset', ResetActionState)
hook.Add('PlayerSpawn', 'upar.action.reset', ResetActionState)

hook.Add('OnPlayerHitGround', 'upar.action.reset_wallrun_normal', function(ply)
    ply.upar_wallrun_last_normal = nil
end)
