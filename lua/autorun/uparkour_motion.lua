-- 运动曲线 + 运行逻辑 + 测试
-- 依赖 autorun/uparkour.lua 提供 UPar.Node(文件名排序在它之后, 已先加载)
--
-- 对外:
--   UPar.Motion.Build(nodes) -> timeline   纯逻辑, 可离线采样
--   UPar.Move(ply, nodes)    开始一段运动(服务端; 会中断该玩家已有运动)
--   UPar.AbortMove(ply)      中断
--   UPar.IsMoving(ply)       是否运动中

UPar = UPar or {}

local Node = assert(UPar.Node, '[UPar.Motion] 需要先加载 autorun/uparkour.lua')

-- ====================================================================
-- 运动曲线: 时间线(分段三次 Hermite, 建在时间域)
--   C(u) = h00*P0 + h10*(T*V0) + h01*P1 + h11*(T*V1)
--   切线乘 T: 基函数对参数求导, 而 speed 对时间求导, 差一个 T 缩放
--   => 端点速度严格等于声明值, 相邻段共用 V_i => 速度 C1 连续
-- ====================================================================
local Motion = {}
UPar.Motion = Motion

UPar.MotionMode = {
    TELEPORT = 1,
    VELOCITY = 2,
}

UPar.MotionMAGIC = {
    EPS = 1e-4,
    DEBUG_TTL = 2,
    DEBUG_STEPS = 32,
    DEBUG_CROSS_SIZE = 8,
    CLIENT_TIMEOUT_MARGIN = 1,
    LOCK_HARD_TIMEOUT = 30,
    PENDING_TIMEOUT = 0.5,
}
Motion.EPS = UPar.MotionMAGIC.EPS

local function Dir(v)
    local len = v:Length()
    if len < UPar.MotionMAGIC.EPS then return nil end
    return v * (1 / len)
end

local Timeline = {}
Timeline.__index = Timeline
Motion.Timeline = Timeline

local function HermiteSegment(nodes, vel, dur, i, u)
    local p0, p1 = nodes[i].pos, nodes[i + 1].pos
    local T = dur[i]
    local m0, m1 = vel[i] * T, vel[i + 1] * T

    local u2 = u * u
    local u3 = u2 * u

    return p0 * (2 * u3 - 3 * u2 + 1)
         + m0 * (u3 - 2 * u2 + u)
         + p1 * (-2 * u3 + 3 * u2)
         + m1 * (u3 - u2)
end

local function HermiteVelocity(nodes, vel, dur, i, u)
    local T = dur[i]
    local m0, m1 = vel[i] * T, vel[i + 1] * T

    local u2 = u * u

    return (
        nodes[i].pos * (6 * u2 - 6 * u)
        + m0 * (3 * u2 - 4 * u + 1)
        + nodes[i + 1].pos * (-6 * u2 + 6 * u)
        + m1 * (3 * u2 - 2 * u)
    ) / T
end

function Motion.Build(list)
    assert(istable(list), '[UPar.Motion.Build] 需要节点数组')
    assert(#list >= 2, '[UPar.Motion.Build] 至少需要 2 个节点')

    local nodes = {}
    for i = 1, #list do
        local item = list[i]
        nodes[i] = Node.Is(item) and item or Node(item)
    end

    local n = #nodes

    -- 1. 方向: 内部节点 Catmull-Rom 中心差分, 端点单侧
    local dir = {}
    for i = 1, n do
        local prev, nxt = nodes[i - 1], nodes[i + 1]
        local d
        if prev and nxt then
            d = Dir(nxt.pos - prev.pos)
        elseif nxt then
            d = Dir(nxt.pos - nodes[i].pos)
        elseif prev then
            d = Dir(nodes[i].pos - prev.pos)
        end
        dir[i] = d
    end

    -- 2. 速度向量: 方向退化 -> 0
    local vel = {}
    for i = 1, n do
        if i == n and nodes[i].exitvel then
            vel[i] = Vector(nodes[i].exitvel)
        elseif not dir[i] then
            vel[i] = Vector(0, 0, 0)
        else
            vel[i] = dir[i] * nodes[i].speed
        end
    end

    -- 3. 段时长: 直线距离 / 平均速度(匀加速)
    local dur = {}
    for i = 1, n - 1 do
        local chord = (nodes[i + 1].pos - nodes[i].pos):Length()
        if chord < UPar.MotionMAGIC.EPS then
            dur[i] = 0
        else
            local vsum = nodes[i].speed + nodes[i + 1].speed
            assert(vsum > UPar.MotionMAGIC.EPS, string.format(
                '[UPar.Motion.Build] 段 %d: 两端速度为 0 但有位移, 无解', i))
            dur[i] = 2 * chord / vsum
        end
    end

    -- 4. 到达时刻: 先停留 delay, 再走 dur
    local arrival = { 0 }
    for i = 1, n - 1 do
        arrival[i + 1] = arrival[i] + nodes[i].delay + dur[i]
    end

    return setmetatable({
        nodes = nodes,
        vel = vel,
        dur = dur,
        arrival = arrival,
        Duration = arrival[n] + nodes[n].delay,
    }, Timeline)
end

function Timeline:NodeIndexAt(t)
    local arrival = self.arrival
    local idx = 1
    for i = #arrival, 1, -1 do
        if t >= arrival[i] then idx = i break end
    end
    return idx
end

function Timeline:NodeAt(t)
    return self.nodes[self:NodeIndexAt(t)]
end

function Timeline:StateAt(t)
    local idx = self:NodeIndexAt(t)
    local node = self.nodes[idx]
    return { index = idx, movetype = node.movetype }
end

function Timeline:Sample(t)
    local nodes, dur, arrival = self.nodes, self.dur, self.arrival
    local n = #nodes

    if t <= 0 then return Vector(nodes[1].pos) end
    if t >= self.Duration then return Vector(nodes[n].pos) end

    for i = 1, n do
        local holdEnd = arrival[i] + nodes[i].delay
        if t < holdEnd then
            return Vector(nodes[i].pos)                       -- 停靠中
        end
        local segEnd = holdEnd + (dur[i] or 0)
        if t < segEnd then
            local u = (t - holdEnd) / dur[i]
            return HermiteSegment(nodes, self.vel, dur, i, u)
        end
    end

    return Vector(nodes[n].pos)
end

function Timeline:SampleVelocity(t)
    local nodes, dur, arrival = self.nodes, self.dur, self.arrival
    local n = #nodes

    if t <= 0 then return Vector(self.vel[1] or vector_origin) end
    if t >= self.Duration then return Vector(self.vel[n] or vector_origin) end

    for i = 1, n do
        local holdEnd = arrival[i] + nodes[i].delay
        if t < holdEnd then
            return Vector(0, 0, 0)
        end

        local segmentDuration = dur[i] or 0
        local segEnd = holdEnd + segmentDuration
        if t < segEnd then
            if segmentDuration < UPar.MotionMAGIC.EPS then
                return Vector(0, 0, 0)
            end

            local u = (t - holdEnd) / segmentDuration
            return HermiteVelocity(nodes, self.vel, dur, i, u)
        end
    end

    return Vector(0, 0, 0)
end

function Timeline:Events()
    local out = {}
    for i = 1, #self.nodes do
        local node = self.nodes[i]
        if node.flag then
            out[#out + 1] = { time = self.arrival[i], flag = node.flag, index = i }
        end
    end
    return out
end

-- ====================================================================
-- 运行逻辑: 服务端 noclip 驱动 + 客户端输入接管 + 可中断
-- ====================================================================
local NET = 'UParMotion'
local OP_ARM, OP_KEYS, OP_ACK, OP_STOP = 1, 2, 3, 4

-- 诊断输出 / 绘制统一跟随开发者模式
local function IsDev()
    local c = GetConVar('developer')
    return c ~= nil and c:GetInt() > 0
end

local upar_safe_mode = CreateConVar(
    'upar_safe_mode', '0',
    { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }
)

if SERVER then util.AddNetworkString(NET) end

if SERVER then
    local function SendArm(ply, id, addKeys, removeKeys, duration)
        net.Start(NET)
        net.WriteUInt(OP_ARM, 3)
        net.WriteUInt(id, 16)
        net.WriteUInt(addKeys, 32)
        net.WriteUInt(removeKeys, 32)
        net.WriteFloat(duration)
        net.Send(ply)
    end

    local function SendKeys(ply, addKeys, removeKeys)
        net.Start(NET)
        net.WriteUInt(OP_KEYS, 3)
        net.WriteUInt(addKeys, 32)
        net.WriteUInt(removeKeys, 32)
        net.Send(ply)
    end

    local function SendStop(ply)
        net.Start(NET)
        net.WriteUInt(OP_STOP, 3)
        net.Send(ply)
    end

    local function FireFlag(ply, node, index, move)
        if node.flag then hook.Run('UParMoveFlag', ply, node.flag, index, node, move) end
    end

    -- 收尾: running 恢复 movetype, 统一解除输入接管. 幂等.
    local function Teardown(move)
        if move.phase == 'stopped' then return end
        local wasRunning = move.phase == 'running'
        move.phase = 'stopped'

        local ply = move.ply
        if ply.upar_motion == move then ply.upar_motion = nil end
        if IsValid(ply) then
            if wasRunning then
                ply:SetMoveType(move.prevMoveType or MOVETYPE_WALK)
            end
            SendStop(ply)
        end
    end

    local function AbortMove(move)
        if move.phase == 'stopped' then return end
        local ply = move.ply
        Teardown(move)
        if IsValid(ply) then ply:SetVelocity(vector_origin) end
    end

    local function BeginMove(move)
        if move.phase ~= 'pending' then return end

        local ply = move.ply
        if not IsValid(ply) or not ply:Alive() then AbortMove(move) return end

        local nodes = move.timeline.nodes
        nodes[1].pos = ply:GetPos()
        move.timeline = Motion.Build(nodes)

        local node1 = move.timeline.nodes[1]
        move.startTime = CurTime()
        move.nodeIndex = 1
        move.prevMoveType = ply:GetMoveType()
        move.phase = 'running'

        ply:SetVelocity(vector_origin)
        if node1.movetype then ply:SetMoveType(node1.movetype) end

        FireFlag(ply, node1, 1, move)
    end

    local function Step(move, mv)
        if move.phase ~= 'running' then return end

        local ply = move.ply
        if not IsValid(ply) or not ply:Alive() then AbortMove(move) return end

        local timeline = move.timeline
        local t = CurTime() - move.startTime

        if move.mode == UPar.MotionMode.VELOCITY then
            mv:SetVelocity(timeline:SampleVelocity(t))
        else
            mv:SetOrigin(timeline:Sample(t))
            if ply:GetMoveType() ~= MOVETYPE_NOCLIP then
                mv:SetVelocity(timeline:SampleVelocity(t))
            end
        end

        -- 节点推进: 应用 movetype / 蹲姿 / 发布 flag
        local idx = timeline:NodeIndexAt(t)
        while move.nodeIndex < idx do
            move.nodeIndex = move.nodeIndex + 1
            local node = timeline.nodes[move.nodeIndex]
            if IsDev() then
                print(string.format('[UPar] 到达节点 %d (t=%.3f)', move.nodeIndex, t))
            end
            if node.movetype then ply:SetMoveType(node.movetype) end
            SendKeys(ply, node.addKeys or 0, node.removeKeys or 0)
            FireFlag(ply, node, move.nodeIndex, move)
        end

        if t >= timeline.Duration then
            local last = #timeline.nodes
            mv:SetVelocity(Vector(timeline.vel[last]))   -- 出口速度 = 尾节点速度
            Teardown(move)
        end
    end

    local function SafeStep(move, mv)
        local ok, err = pcall(Step, move, mv)
        if not ok then
            print('[UPar] 运动步进出错, 已中断: ' .. tostring(err))
            AbortMove(move)
        end
    end

    function UPar.Move(ply, list, mode)
        assert(IsValid(ply) and ply:IsPlayer(), '[UPar.Move] 需要有效玩家')
        mode = mode or UPar.MotionMode.TELEPORT
        local timeline = Motion.Build(list)

        local old = ply.upar_motion
        if old then AbortMove(old) end

        local node1 = timeline.nodes[1]
        local id = ((ply.upar_motion_id or 0) % 65535) + 1
        ply.upar_motion_id = id

        local move = {
            ply = ply,
            id = id,
            timeline = timeline,
            mode = mode,
            phase = 'pending',
            pendingSince = CurTime(),
            nodeIndex = 1,
        }
        ply.upar_motion = move

        if upar_safe_mode:GetBool() then
            if IsDev() then
                print(string.format('[UPar] motion safe mode id=%d', id))
            end
            BeginMove(move)
        else
            SendArm(ply, id, node1.addKeys or 0, node1.removeKeys or 0, timeline.Duration)
            if IsDev() then
                print(string.format('[UPar] motion arm id=%d', id))
            end
        end

        return move
    end

    net.Receive(NET, function(_, ply)
        local op = net.ReadUInt(3)
        if op ~= OP_ACK or not IsValid(ply) then return end

        local id = net.ReadUInt(16)
        local move = ply.upar_motion
        if move and move.phase == 'pending' and move.id == id then
            if IsDev() then
                print(string.format('[UPar] motion ack id=%d', id))
            end
            BeginMove(move)
        end
    end)

    function UPar.AbortMove(ply)
        if IsValid(ply) and ply.upar_motion then AbortMove(ply.upar_motion) end
    end

    function UPar.IsMoving(ply)
        return IsValid(ply) and ply.upar_motion ~= nil
    end

    hook.Add('SetupMove', 'upar.motion.step', function(ply, mv)
        local move = ply.upar_motion
        if move then
            if move.phase == 'running' then
                SafeStep(move, mv)
            elseif CurTime() - move.pendingSince > UPar.MotionMAGIC.PENDING_TIMEOUT then
                AbortMove(move)
            end
        end
    end)

    local function interrupt(ply)
        if IsValid(ply) and ply.upar_motion then AbortMove(ply.upar_motion) end
    end
    hook.Add('PlayerDeath', 'upar.motion.interrupt', interrupt)
    hook.Add('PlayerSilentDeath', 'upar.motion.interrupt', interrupt)
    hook.Add('PlayerSpawn', 'upar.motion.interrupt', interrupt)
    hook.Add('PlayerDisconnect', 'upar.motion.interrupt', interrupt)
end

if CLIENT then
    local state = {
        active = false,
        ackPending = false,
        stopPending = false,
        id = 0,
        addKeys = 0,
        removeKeys = 0,
        expires = 0,
    }

    net.Receive(NET, function()
        local op = net.ReadUInt(3)
        if op == OP_ARM then
            state.active = true
            state.ackPending = true
            state.stopPending = false
            state.id = net.ReadUInt(16)
            state.addKeys = net.ReadUInt(32)
            state.removeKeys = net.ReadUInt(32)
            local duration = net.ReadFloat()
            local expectedExpires = CurTime() + duration + UPar.MotionMAGIC.CLIENT_TIMEOUT_MARGIN
            local hardExpires = CurTime() + UPar.MotionMAGIC.LOCK_HARD_TIMEOUT
            state.expires = math.min(expectedExpires, hardExpires)
            if IsDev() then
                print(string.format('[UPar] client arm id=%d', state.id))
            end
        elseif op == OP_KEYS then
            state.addKeys = net.ReadUInt(32)
            state.removeKeys = net.ReadUInt(32)
        elseif op == OP_STOP then
            state.ackPending = false
            state.stopPending = state.active
        end
    end)

    hook.Add('CreateMove', 'upar.motion.control', function(cmd)
        if not state.active then return end
        if CurTime() > state.expires then
            state.active, state.ackPending, state.stopPending, state.id, state.addKeys, state.removeKeys =
                false, false, false, 0, 0, 0
            return
        end

        if state.stopPending and LocalPlayer():GetMoveType() ~= MOVETYPE_NOCLIP then
            state.active, state.ackPending, state.stopPending, state.id, state.addKeys, state.removeKeys =
                false, false, false, 0, 0, 0
            return
        end

        cmd:ClearMovement()
        if state.removeKeys ~= 0 then cmd:RemoveKey(state.removeKeys) end
        if state.addKeys ~= 0 then cmd:AddKey(state.addKeys) end

        if state.ackPending then
            state.ackPending = false
            net.Start(NET)
            net.WriteUInt(OP_ACK, 3)
            net.WriteUInt(state.id, 16)
            net.SendToServer()
            if IsDev() then
                print(string.format('[UPar] client ack id=%d', state.id))
            end
        end
    end)
end

-- ====================================================================
-- 测试指令(服务端; 客户端控制台输入即可转发)
--   upar_move_test <preset>   运行预设(preset: line/accel/curve/arc/hold/duck)
--   upar_move_stop            中断当前运动
-- 诊断统一跟随 developer >= 1(到达节点/flag 打印 + 路径绘制)
-- ====================================================================
if SERVER then
    local function ResolvePly(ply)
        if IsValid(ply) and ply:IsPlayer() then return ply end
        for _, pl in ipairs(player.GetAll()) do
            if pl:Alive() then return pl end
        end
        return player.GetAll()[1]
    end

    local function Frame(ply)
        local flat = Angle(0, ply:EyeAngles().y, 0)
        return flat:Forward(), flat:Right(), Vector(0, 0, 1)
    end

    local Presets = {}

    Presets.line = function(ply)
        local p, fwd = ply:GetPos(), Frame(ply)
        return {
            UPar.Node{ pos = p, speed = 300, movetype = MOVETYPE_NOCLIP },
            UPar.Node{ pos = p + fwd * 160, speed = 300 },
        }
    end

    Presets.accel = function(ply)
        local p, fwd = ply:GetPos(), Frame(ply)
        return {
            UPar.Node{ pos = p, speed = 120, movetype = MOVETYPE_NOCLIP },
            UPar.Node{ pos = p + fwd * 220, speed = 480 },
        }
    end

    Presets.curve = function(ply)
        local p = ply:GetPos()
        local fwd, right = Frame(ply)
        return {
            UPar.Node{ pos = p, speed = 250, movetype = MOVETYPE_NOCLIP },
            UPar.Node{ pos = p + fwd * 100, speed = 250 },
            UPar.Node{ pos = p + fwd * 160 + right * 70, speed = 250 },
            UPar.Node{ pos = p + fwd * 220, speed = 250 },
        }
    end

    Presets.arc = function(ply)
        local p = ply:GetPos()
        local fwd, right, up = Frame(ply)
        return {
            UPar.Node{ pos = p, speed = 300, flag = 'arc_start', movetype = MOVETYPE_NOCLIP },
            UPar.Node{ pos = p + fwd * 90 + up * 48, speed = 300, flag = 'arc_apex' },
            UPar.Node{ pos = p + fwd * 180, speed = 300, flag = 'arc_land' },
        }
    end

    Presets.hold = function(ply)
        local p, fwd = ply:GetPos(), Frame(ply)
        return {
            UPar.Node{ pos = p, speed = 300, movetype = MOVETYPE_NOCLIP },
            UPar.Node{ pos = p + fwd * 160, speed = 0, delay = 0.5 },
        }
    end

    Presets.duck = function(ply)
        local p, fwd = ply:GetPos(), Frame(ply)
        return {
            UPar.Node{ pos = p, speed = 200, movetype = MOVETYPE_NOCLIP, addKeys = IN_DUCK },
            UPar.Node{ pos = p + fwd * 140, speed = 200, addKeys = IN_DUCK },
            UPar.Node{ pos = p + fwd * 260, speed = 200, removeKeys = IN_DUCK },
        }
    end

    concommand.Add('upar_move_test', function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then return end

        ply = ResolvePly(ply)
        if not IsValid(ply) then print('[UPar] 没有可用玩家') return end

        local name = args[1] or 'line'
        local preset = Presets[name]
        if not preset then
            print('[UPar] 未知预设 "' .. name .. '"; 可用: ' ..
                table.concat(table.GetKeys(Presets), ', '))
            return
        end

        UPar.Move(ply, preset(ply))
        print('[UPar] 运行预设: ' .. name)
    end)

    concommand.Add('upar_move_stop', function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        ply = ResolvePly(ply)
        if IsValid(ply) and UPar.IsMoving(ply) then
            UPar.AbortMove(ply)
            print('[UPar] 已中断')
        else
            print('[UPar] 没有进行中的运动')
        end
    end)

    -- 调试钩子: developer 打开时挂上, 关了就摘掉, 不在热路径里判断.
    --   Think         —— 每 tick 把当前所有活跃运动的路径画出来
    --   UParMoveFlag  —— flag 发布时打印出来
    -- 服务端 debugoverlay 单次提交不可靠, 必须持续重画; 生命周期给 2 秒做余量.
    local DEBUG_HOOK = 'upar.motion.debug'
    local FLAG_HOOK = 'upar.motion.debug.flag'

    local function DrawActiveMoves()
        for _, ply in ipairs(player.GetAll()) do
            local move = ply.upar_motion
            if move then
                local timeline = move.timeline

                for i = 1, #timeline.nodes do
                    debugoverlay.Cross(timeline.nodes[i].pos, UPar.MotionMAGIC.DEBUG_CROSS_SIZE,
                        UPar.MotionMAGIC.DEBUG_TTL, true)
                end

                local prev
                for k = 0, UPar.MotionMAGIC.DEBUG_STEPS do
                    local p = timeline:Sample(timeline.Duration * k / UPar.MotionMAGIC.DEBUG_STEPS)
                    if prev then
                        debugoverlay.Line(prev, p, UPar.MotionMAGIC.DEBUG_TTL,
                            Color(0, 200, 255), true)
                    end
                    prev = p
                end
            end
        end
    end

    local function PrintFlag(ply, name, index)
        local node = index and (' @ node ' .. index) or ''
        print(string.format('[UPar] flag "%s"%s (%s)',
            name, node, IsValid(ply) and ply:Nick() or '?'))
    end

    local function SyncDebugDraw()
        hook.Remove('Think', DEBUG_HOOK)
        hook.Remove('UParMoveFlag', FLAG_HOOK)

        if IsDev() then
            hook.Add('Think', DEBUG_HOOK, DrawActiveMoves)
            hook.Add('UParMoveFlag', FLAG_HOOK, PrintFlag)
        end
    end

    cvars.AddChangeCallback('developer', SyncDebugDraw, DEBUG_HOOK)
    SyncDebugDraw()   -- 按启动时的当前值先同步一次
end
