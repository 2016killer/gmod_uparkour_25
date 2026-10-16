-- 只放稳定的简单声明: 命名空间、版本、数据结构. 不放运行逻辑.
--
-- 运动曲线与运行逻辑见 autorun/uparkour_motion.lua, 它依赖本文件先加载.

UPar = UPar or {}
UPar.Version = '2.5.3 Reupload'
UPar.ObstacleEntityClassFilter = UPar.ObstacleEntityClassFilter or {


}


local function IsFinite(n)
    return isnumber(n) and n == n and n ~= math.huge and n ~= -math.huge
end

local FIELDS = {
    pos      = { 'vector',  nil,   '世界坐标(必填)' },
    speed    = { 'number',  0,     '到达该节点的标量速度(方向由相邻节点几何推出), >= 0' },
    delay    = { 'number',  0,     '在该节点进入下一段运动前的原地停留时长, >= 0' },
    flag     = { 'string',  nil,   '到达时发布的事件名(nil = 不发布)' },
    movetype = { 'number',  nil,   '进入该节点时的移动方式(nil = 沿用搬运方式)' },
    addKeys  = { 'number',  nil,   '进入该节点时按下的按键位掩码(nil = 清空)' },
    removeKeys = { 'number', nil,  '进入该节点时释放的按键位掩码(nil = 清空)' },
    exitvel  = { 'vector',  nil,   '尾节点出口速度覆盖(nil = 由相邻节点几何推导)' },
    payload  = { 'table',   nil,   '到达该节点并发送 flag 时携带的附加数据(nil = 无)' },
}

local VALIDATORS = {
    vector  = function(v) return isvector(v) end,
    number  = function(v) return IsFinite(v) end,
    string  = function(v) return isstring(v) end,
    table   = function(v) return istable(v) end,
}

local Node = {}
Node.__index = Node
Node.FIELDS = FIELDS

function Node.new(t)
    assert(istable(t), '[UPar.Node] 需要一个 table')

    local out = {}
    for name, spec in pairs(FIELDS) do
        local ftype, default = spec[1], spec[2]
        local value = t[name]
        if value == nil then value = default end

        if value == nil then
            assert(name ~= 'pos', '[UPar.Node] 缺少必填字段 pos')
        else
            local validator = VALIDATORS[ftype]
            assert(validator and validator(value),
                string.format('[UPar.Node] 字段 "%s" 类型应为 %s', name, ftype))
            if ftype == 'vector' then value = Vector(value) end
        end

        out[name] = value
    end

    assert(out.speed >= 0, '[UPar.Node] speed 必须 >= 0')
    assert(out.delay >= 0, '[UPar.Node] delay 必须 >= 0')

    return setmetatable(out, Node)
end

function Node.Is(x)
    return getmetatable(x) == Node
end

function Node:__tostring()
    return string.format('Node(%s, speed=%s, delay=%s%s%s)',
        tostring(self.pos), tostring(self.speed), tostring(self.delay),
        self.flag and (', flag=' .. self.flag) or '',
        self.movetype and (', movetype=' .. tostring(self.movetype)) or '',
        self.exitvel and (', exitvel=' .. tostring(self.exitvel)) or '')
end

UPar.Node = setmetatable(Node, { __call = function(_, t) return Node.new(t) end })

local Platform = {}
Platform.__index = Platform
Platform.TYPE = 'platform'
Platform.FIELDS = {
    'obstacle',   -- 粗检测命中的 TraceResult
    'height',     -- 高度检测结果, 相对玩家脚底的 Source 单位
    'landing',    -- 高度检测命中的落脚点, Vector
    'canStand',   -- 落脚点能否容纳完整站立盒, boolean
    'groundClose',-- 玩家脚下附近是否有地面, boolean
    'dropTravel', -- 下探探针的垂直移动距离, Source 单位; 无下探时为 nil
    'obstacleNormal', -- 障碍法线(朝玩家侧), Vector
}

function Platform.new(t)
    local out = { TYPE = 'platform' }
    for _, name in ipairs(Platform.FIELDS) do
        out[name] = t[name]
    end
    return setmetatable(out, Platform)
end

function Platform:__tostring()
    return string.format('Platform(height=%s, landing=%s, canStand=%s)',
        tostring(self.height), tostring(self.landing), tostring(self.canStand))
end

UPar.Platform = setmetatable(Platform, { __call = function(_, t) return Platform.new(t) end })

local Pulse = {}
Pulse.__index = Pulse
Pulse.TYPE = 'pulse'
Pulse.FIELDS = {
    'obstacle',   -- 粗检测命中的 TraceResult
    'height',     -- 高度检测结果, 相对玩家脚底的 Source 单位
    'landing',    -- 高度检测命中的落脚点, Vector
    'canStand',   -- 落脚点能否容纳完整站立盒, boolean
    'groundClose',-- 玩家脚下附近是否有地面, boolean
    'dropTravel', -- 下探探针的垂直移动距离, Source 单位; 无下探时为 nil

    'vaultLanding', -- 翻越最终落脚点, Vector
    'thickness',    -- 反向站立盒测得的通行厚度, Source 单位
    'obstacleNormal', -- 障碍法线(朝玩家侧), Vector
}

function Pulse.new(t)
    local out = { TYPE = 'pulse' }
    for _, name in ipairs(Pulse.FIELDS) do
        out[name] = t[name]
    end
    return setmetatable(out, Pulse)
end

function Pulse:__tostring()
    return string.format('Pulse(height=%s, landing=%s, vaultLanding=%s, thickness=%s)',
        tostring(self.height), tostring(self.landing), tostring(self.vaultLanding), tostring(self.thickness))
end

UPar.Pulse = setmetatable(Pulse, { __call = function(_, t) return Pulse.new(t) end })

local HorizontalWallrun = {}
HorizontalWallrun.__index = HorizontalWallrun
HorizontalWallrun.TYPE = 'horizontal'
HorizontalWallrun.FIELDS = {
    'side',       -- 墙在玩家的哪一侧: 'left' 或 'right'
    'normal',     -- 候选墙法线, Vector
    'along',      -- 沿墙跑方向, Vector
    'leftCount',  -- 左侧三层探针的有效命中数, 0..3
    'rightCount', -- 右侧三层探针的有效命中数, 0..3
    'widthHits',  -- 沿墙方向两个宽度探针的有效命中数, 0..2
    'hasLift',    -- 是否执行地面起跳抬升, boolean
}

function HorizontalWallrun.new(t)
    local out = { TYPE = 'horizontal' }
    for _, name in ipairs(HorizontalWallrun.FIELDS) do
        out[name] = t[name]
    end
    return setmetatable(out, HorizontalWallrun)
end

function HorizontalWallrun:__tostring()
    return string.format('HorizontalWallrun(side=%s, widthHits=%s)',
        tostring(self.side), tostring(self.widthHits))
end

UPar.HorizontalWallrun = setmetatable(HorizontalWallrun, {
    __call = function(_, t) return HorizontalWallrun.new(t) end
})

local VerticalWallrun = {}
VerticalWallrun.__index = VerticalWallrun
VerticalWallrun.TYPE = 'vertical'
VerticalWallrun.FIELDS = {
    'normal',     -- 候选墙法线, Vector
    'along',      -- 垂直墙跑方向, Vector
    'contactPos', -- 墙面命中点, Vector
    'frontCount', -- 前方三层探针的有效命中数, 0..3
    'widthHits',  -- 墙面水平方向两个宽度探针的有效命中数, 0..2
}

function VerticalWallrun.new(t)
    local out = { TYPE = 'vertical' }
    for _, name in ipairs(VerticalWallrun.FIELDS) do
        out[name] = t[name]
    end
    return setmetatable(out, VerticalWallrun)
end

function VerticalWallrun:__tostring()
    return string.format('VerticalWallrun(frontCount=%s)', tostring(self.frontCount))
end

UPar.VerticalWallrun = setmetatable(VerticalWallrun, {
    __call = function(_, t) return VerticalWallrun.new(t) end
})




if CLIENT then
    concommand.Add('upar_debug_movepoint', function(ply)
        if timer.Exists('upar_debug_movepoint') then
            print('Remove debug movepoint')
            timer.Remove('upar_debug_movepoint')
        else
            print('Create debug movepoint')
            timer.Create('upar_debug_movepoint', 0, 0, function()
                debugoverlay.Box(LocalPlayer():GetPos(), Vector(0, 0, 0), Vector(1, 1, 1), 2)
            end)
        end
    end)
end