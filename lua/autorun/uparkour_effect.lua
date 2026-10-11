if SERVER then AddCSLuaFile() end

UPar = UPar or {}

UPar.EffectMAGIC = {
    HORIZONTAL_WALLRUN_ROLL = 10,
    HORIZONTAL_WALLRUN_ROLL_LERP = 5,
    HORIZONTAL_WALLRUN_VIEW_LIMIT = 90,
}

sound.Add({
    name = 'wallrun_footstep',
    channel = CHAN_AUTO,
    volume = 1.0,
    level = 75,
    sound = {
        'uparkour/mirrorsedge/me_footstep_concretewallrun1.wav',
        'uparkour/mirrorsedge/me_footstep_concretewallrun2.wav',
        'uparkour/mirrorsedge/me_footstep_concretewallrun3.wav',
        'uparkour/mirrorsedge/me_footstep_concretewallrun4.wav',
        'uparkour/mirrorsedge/me_footstep_concretewallrun5.wav',
        'uparkour/mirrorsedge/me_footstep_concretewallrun6.wav',
    },
})

sound.Add({
    name = 'wallrun_clean',
    channel = CHAN_AUTO,
    volume = 1.0,
    level = 75,
    sound = {
        'uparkour/mirrorsedge/me_footsteps_congrete_clean_wallrun_slow_faith1.wav',
        'uparkour/mirrorsedge/me_footsteps_congrete_clean_wallrun_slow_faith2.wav',
        'uparkour/mirrorsedge/me_footsteps_congrete_clean_wallrun_slow_faith3.wav',
        'uparkour/mirrorsedge/me_footsteps_congrete_clean_wallrun_slow_faith5.wav',
        'uparkour/mirrorsedge/me_footsteps_congrete_clean_wallrun_slow_faith4.wav',
        'uparkour/mirrorsedge/me_footsteps_congrete_clean_wallrun_slow_faith6.wav',
        'uparkour/mirrorsedge/me_footsteps_congrete_clean_wallrun_slow_faith7.wav',
    },
})

local upar_effect_lowclimb_sound = CreateConVar('upar_effect_lowclimb_sound', 'uparkour/dishonored/lowclimb.mp3', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_lowclimb_vmanip_anim = CreateConVar('upar_effect_lowclimb_vmanip_anim', 'vault', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_lowclimb_vmlegs_anim = CreateConVar('upar_effect_lowclimb_vmlegs_anim', '', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_lowclimb_wos_anim = CreateConVar('upar_effect_lowclimb_wos_anim', 'wos_Vaultlow', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

local upar_effect_highclimb_sound = CreateConVar('upar_effect_highclimb_sound', 'uparkour/dishonored/highclimb.mp3', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_highclimb_vmanip_anim = CreateConVar('upar_effect_highclimb_vmanip_anim', 'dp_catch_mtbntb', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_highclimb_vmlegs_anim = CreateConVar('upar_effect_highclimb_vmlegs_anim', '', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_highclimb_wos_anim = CreateConVar('upar_effect_highclimb_wos_anim', 'wos_Vaulthigh', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

local upar_effect_vault_sound = CreateConVar('upar_effect_vault_sound', 'uparkour/dishonored/vault.mp3', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_vault_vmanip_anim = CreateConVar('upar_effect_vault_vmanip_anim', 'vault', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_vault_vmlegs_anim = CreateConVar('upar_effect_vault_vmlegs_anim', 'dp_lazy_BaiLang', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_vault_wos_anim = CreateConVar('upar_effect_vault_wos_anim', 'wos_Vault', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

local upar_effect_doublevault_state1_sound = CreateConVar('upar_effect_doublevault_state1_sound', 'uparkour/mtbntb/highclimb.mp3', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_doublevault_state1_vmanip_anim = CreateConVar('upar_effect_doublevault_state1_vmanip_anim', 'dp_catch_mtbntb', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_doublevault_state1_vmlegs_anim = CreateConVar('upar_effect_doublevault_state1_vmlegs_anim', '', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_doublevault_state1_wos_anim = CreateConVar('upar_effect_doublevault_state1_wos_anim', 'wos_Vaulthigh', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

local upar_effect_doublevault_state2_sound = CreateConVar('upar_effect_doublevault_state2_sound', '', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_doublevault_state2_vmanip_anim = CreateConVar('upar_effect_doublevault_state2_vmanip_anim', 'vault', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_doublevault_state2_vmlegs_anim = CreateConVar('upar_effect_doublevault_state2_vmlegs_anim', 'dp_lazy_BaiLang', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_doublevault_state2_wos_anim = CreateConVar('upar_effect_doublevault_state2_wos_anim', 'wos_Vault', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

local upar_effect_vertical_wallrun_sound = CreateConVar('upar_effect_vertical_wallrun_sound', '', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_vertical_wallrun_footstep_sound = CreateConVar('upar_effect_vertical_wallrun_footstep_sound', 'wallrun_footstep', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_vertical_wallrun_clean_sound = CreateConVar('upar_effect_vertical_wallrun_clean_sound', 'wallrun_clean', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_vertical_wallrun_vmanip_anim = CreateConVar('upar_effect_vertical_wallrun_vmanip_anim', 'verticalwallrun', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_vertical_wallrun_vmlegs_anim = CreateConVar('upar_effect_vertical_wallrun_vmlegs_anim', '', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_vertical_wallrun_wos_anim = CreateConVar('upar_effect_vertical_wallrun_wos_anim', '', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

local upar_effect_horizontal_wallrun_sound = CreateConVar('upar_effect_horizontal_wallrun_sound', '', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_horizontal_wallrun_footstep_sound = CreateConVar('upar_effect_horizontal_wallrun_footstep_sound', 'wallrun_footstep', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_horizontal_wallrun_clean_sound = CreateConVar('upar_effect_horizontal_wallrun_clean_sound', 'wallrun_clean', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_horizontal_wallrun_vmanip_anim = CreateConVar('upar_effect_horizontal_wallrun_vmanip_anim', 'horizontalwallrun_YongLi', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_horizontal_wallrun_vmlegs_anim = CreateConVar('upar_effect_horizontal_wallrun_vmlegs_anim', '', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })
local upar_effect_horizontal_wallrun_wos_anim = CreateConVar('upar_effect_horizontal_wallrun_wos_anim', '', { FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE })

local effectConVars = {
    low_climb = {
        sound = upar_effect_lowclimb_sound,
        vmanipAnim = upar_effect_lowclimb_vmanip_anim,
        vmlegsAnim = upar_effect_lowclimb_vmlegs_anim,
        wosAnim = upar_effect_lowclimb_wos_anim,
    },
    high_climb = {
        sound = upar_effect_highclimb_sound,
        vmanipAnim = upar_effect_highclimb_vmanip_anim,
        vmlegsAnim = upar_effect_highclimb_vmlegs_anim,
        wosAnim = upar_effect_highclimb_wos_anim,
    },
    vault = {
        sound = upar_effect_vault_sound,
        vmanipAnim = upar_effect_vault_vmanip_anim,
        vmlegsAnim = upar_effect_vault_vmlegs_anim,
        wosAnim = upar_effect_vault_wos_anim,
    },
    double_vault_state1 = {
        sound = upar_effect_doublevault_state1_sound,
        vmanipAnim = upar_effect_doublevault_state1_vmanip_anim,
        vmlegsAnim = upar_effect_doublevault_state1_vmlegs_anim,
        wosAnim = upar_effect_doublevault_state1_wos_anim,
    },
    double_vault_state2 = {
        sound = upar_effect_doublevault_state2_sound,
        vmanipAnim = upar_effect_doublevault_state2_vmanip_anim,
        vmlegsAnim = upar_effect_doublevault_state2_vmlegs_anim,
        wosAnim = upar_effect_doublevault_state2_wos_anim,
    },
    vertical_wallrun = {
        sound = upar_effect_vertical_wallrun_sound,
        vmanipAnim = upar_effect_vertical_wallrun_vmanip_anim,
        vmlegsAnim = upar_effect_vertical_wallrun_vmlegs_anim,
        wosAnim = upar_effect_vertical_wallrun_wos_anim,
    },
    horizontal_wallrun = {
        sound = upar_effect_horizontal_wallrun_sound,
        vmanipAnim = upar_effect_horizontal_wallrun_vmanip_anim,
        vmlegsAnim = upar_effect_horizontal_wallrun_vmlegs_anim,
        wosAnim = upar_effect_horizontal_wallrun_wos_anim,
    },
}

local activeEffect
local horizontalWallrun = {
    centerYaw = nil,
    rollTarget = 0,
    rollActive = false,
}

if CLIENT then
    local function NormalizeAngle(angle)
        angle = angle % 360
        if angle > 180 then angle = angle - 360 end
        return angle
    end

    hook.Add('InputMouseApply', 'upar.effect.horizontal_wallrun', function(cmd)
        if not horizontalWallrun.centerYaw and not horizontalWallrun.rollActive then return end

        local angles = cmd:GetViewAngles()

        if horizontalWallrun.centerYaw then
            local limit = UPar.EffectMAGIC.HORIZONTAL_WALLRUN_VIEW_LIMIT
            local delta = NormalizeAngle(angles.yaw - horizontalWallrun.centerYaw)
            angles.yaw = horizontalWallrun.centerYaw + math.Clamp(delta, -limit, limit)
        end

        if horizontalWallrun.rollActive then
            local diff = horizontalWallrun.rollTarget - angles.roll
            if math.abs(diff) < 0.1 then
                angles.roll = horizontalWallrun.rollTarget
                if horizontalWallrun.rollTarget == 0 then
                    horizontalWallrun.rollActive = false
                end
            else
                angles.roll = Lerp(
                    FrameTime() * UPar.EffectMAGIC.HORIZONTAL_WALLRUN_ROLL_LERP,
                    angles.roll,
                    horizontalWallrun.rollTarget
                )
            end
        end

        cmd:SetViewAngles(angles)
    end)
end

local function PlayEffect(ply, effectName, payload)
    local convars = effectConVars[effectName]
    if not convars then return end
    if CLIENT then activeEffect = effectName end

    if CLIENT and effectName == 'horizontal_wallrun' and payload then
        horizontalWallrun.centerYaw = math.deg(math.atan2(payload.along.y, payload.along.x))
        horizontalWallrun.rollTarget = payload.roll
        horizontalWallrun.rollActive = true
    end

    local wosAnim = convars.wosAnim:GetString()
    if wosAnim ~= '' then
        if SERVER then
            ply:SetNWString('UP_WOS', wosAnim)
        elseif CLIENT then
            local sequence = ply:LookupSequence(wosAnim)
            if sequence and sequence > 0 then
                ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_JUMP, sequence, 0, true)
                ply:SetPlaybackRate(1)
            end
        end
    end

    if SERVER and effectName == 'low_climb' then
        ply:ViewPunch(Angle(0, 0, -2))
    end


    if SERVER and (effectName == 'high_climb' or effectName == 'double_vault_state1') then
        ply:ViewPunch(Angle(-20, 5, 0))
        timer.Simple(0.2, function()
            if IsValid(ply) then ply:ViewPunch(Angle(20, 0, 0)) end
        end)
    end

    local sound = convars.sound:GetString()
    if SERVER and sound ~= '' then
        ply:EmitSound(sound)
    end

    if CLIENT then
        local vmanipAnim = convars.vmanipAnim:GetString()
        if VManip and vmanipAnim ~= '' then
            VManip:PlayAnim(vmanipAnim)
            if vmanipAnim == 'verticalwallrun' and VManip:GetCurrentAnim() == vmanipAnim
                and IsValid(VManip:GetVMGesture()) then
                VManip:GetVMGesture().RenderOverride = function(self)
                    self:SetPos(EyePos() - ply:EyeAngles():Up() * 64)
                    self:SetAngles(ply:EyeAngles())
                end
            end
        end

        local vmlegsAnim = convars.vmlegsAnim:GetString()
        if VMLegs and vmlegsAnim ~= '' then
            VMLegs:PlayAnim(vmlegsAnim)
        end
    end
end

local function ClearEffect(ply, endtype)
    if CLIENT and activeEffect then
        if activeEffect == 'horizontal_wallrun' then
            horizontalWallrun.centerYaw = nil
            horizontalWallrun.rollTarget = 0
            horizontalWallrun.rollActive = true
        end

        local convars = effectConVars[activeEffect]
        local vmanipAnim = convars and convars.vmanipAnim:GetString() or ''
        if VManip and vmanipAnim ~= '' and VManip:GetCurrentAnim() == vmanipAnim then
            VManip:QuitHolding(vmanipAnim)
            if endtype == 'interrupt' and IsValid(VManip:GetVMGesture()) then
                VManip:Remove()
            end
        end
        activeEffect = nil
    end

    if SERVER then
        ply:SetNWString('UP_WOS', '')
    end
end

if SERVER then util.AddNetworkString('UParEffect') end

local function StartEffect(ply, effectName, payload)
    if not isstring(effectName) then return end

    PlayEffect(ply, effectName)

    if SERVER then
        net.Start('UParEffect')
            net.WriteString(effectName)
            net.WriteString('')
            net.WriteBool(payload ~= nil)
            if payload then
                net.WriteVector(payload.along)
                net.WriteFloat(payload.roll)
            end
        net.Send(ply)
    end
end

local function StopEffect(ply, endtype)
    ClearEffect(ply, endtype)

    if SERVER then
        net.Start('UParEffect')
            net.WriteString('')
            net.WriteString(endtype or '')
        net.Send(ply)
    end
end

local function OnMoveFlag(ply, flag, index, node, move)
    if flag == 'move_end' then
        StopEffect(ply, 'end')
        return
    end

    if flag == 'wallrun_interrupt' then
        StopEffect(ply, 'interrupt')
        return
    end

    if flag == 'vertical_wallrun_interrupt' then
        StopEffect(ply, 'interrupt')
        return
    end 

    if flag == 'horizontal_wallrun_interrupt' then
        StopEffect(ply, 'interrupt')
        return
    end

    if flag == 'vertical_wallrun_step' then
        local sound = upar_effect_vertical_wallrun_footstep_sound:GetString()
        if sound ~= '' then ply:EmitSound(sound) end
        return
    end

    if flag == 'horizontal_wallrun_step' then
        local sound = upar_effect_horizontal_wallrun_footstep_sound:GetString()
        if sound ~= '' then ply:EmitSound(sound) end
        return
    end

    if flag == 'vertical_wallrun' then
        local sound = upar_effect_vertical_wallrun_footstep_sound:GetString()
        if sound ~= '' then ply:EmitSound(sound) end
    end

    local payload
    if flag == 'horizontal_wallrun' then
        local sound = upar_effect_horizontal_wallrun_footstep_sound:GetString()
        if sound ~= '' then ply:EmitSound(sound) end

        local nodes = move and move.timeline and move.timeline.nodes
        if nodes and nodes[2] then
            local along = nodes[2].pos - nodes[1].pos
            along.z = 0
            along:Normalize()

            local right = ply:EyeAngles():Right()
            right.z = 0
            right:Normalize()

            local direction = along:Dot(right) >= 0 and 1 or -1
            payload = {
                along = along,
                roll = direction * UPar.EffectMAGIC.HORIZONTAL_WALLRUN_ROLL,
            }
        end
    end

    if flag == 'vertical_wallrun_clean' then
        ply:ViewPunch(Angle(5, 0, 0))
        StopEffect(ply, 'jump')
        local sound = upar_effect_vertical_wallrun_clean_sound:GetString()
        if sound ~= '' then ply:EmitSound(sound) end
        return
    end

    if flag == 'horizontal_wallrun_clean' then
        ply:ViewPunch(Angle(5, 0, 0))
        StopEffect(ply, 'jump')
        local sound = upar_effect_horizontal_wallrun_clean_sound:GetString()
        if sound ~= '' then ply:EmitSound(sound) end
        return
    end

    StartEffect(ply, flag, payload)
end

hook.Add('UParMoveFlag', 'upar.effect.flag', OnMoveFlag)
hook.Add('PlayerDeath', 'upar.effect.clear', function(ply) StopEffect(ply, 'end') end)
hook.Add('PlayerSpawn', 'upar.effect.clear', function(ply) StopEffect(ply, 'end') end)
hook.Add('PlayerDisconnect', 'upar.effect.clear', function(ply) StopEffect(ply, 'end') end)

if CLIENT then
    net.Receive('UParEffect', function()
        local ply = LocalPlayer()
        local effectName = net.ReadString()
        local endtype = net.ReadString()

        if effectName == '' then
            ClearEffect(ply, endtype)
        else
            local payload
            if net.ReadBool() then
                payload = {
                    along = net.ReadVector(),
                    roll = net.ReadFloat(),
                }
            end
            PlayEffect(ply, effectName, payload)
        end
    end)
end


