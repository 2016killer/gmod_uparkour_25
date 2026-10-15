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

local horizontalWallrun = {
    centerYaw = nil,
    rollTarget = 0,
    rollActive = false,
}

local function SetWOS(ply, anim)
    if anim == '' then return end

    if SERVER then
        ply:SetNWString('UP_WOS', anim)
    elseif CLIENT then
        local sequence = ply:LookupSequence(anim)
        if sequence and sequence > 0 then
            ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_JUMP, sequence, 0, true)
            ply:SetPlaybackRate(1)
        end
    end
end

local function ClearWOS(ply)
    if SERVER and IsValid(ply) then
        ply:SetNWString('UP_WOS', '')
    end
end

local function EmitEffectSound(ply, sound)
    if SERVER and sound ~= '' then
        ply:EmitSound(sound)
    end
end

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

local function StartLowClimb(ply, payload)
    SetWOS(ply, upar_effect_lowclimb_wos_anim:GetString())

    if SERVER then
        ply:ViewPunch(Angle(0, 0, -2))
        EmitEffectSound(ply, upar_effect_lowclimb_sound:GetString())
    elseif CLIENT then
        local vmanipAnim = upar_effect_lowclimb_vmanip_anim:GetString()
        if VManip and vmanipAnim ~= '' then VManip:PlayAnim(vmanipAnim) end

        local vmlegsAnim = upar_effect_lowclimb_vmlegs_anim:GetString()
        if VMLegs and vmlegsAnim ~= '' then VMLegs:PlayAnim(vmlegsAnim) end
    end
end

local function StartHighClimb(ply, payload)
    SetWOS(ply, upar_effect_highclimb_wos_anim:GetString())

    if SERVER then
        ply:ViewPunch(Angle(-20, 5, 0))
        timer.Simple(0.2, function()
            if IsValid(ply) then ply:ViewPunch(Angle(20, 0, 0)) end
        end)
        EmitEffectSound(ply, upar_effect_highclimb_sound:GetString())
    elseif CLIENT then
        local vmanipAnim = upar_effect_highclimb_vmanip_anim:GetString()
        if VManip and vmanipAnim ~= '' then VManip:PlayAnim(vmanipAnim) end

        local vmlegsAnim = upar_effect_highclimb_vmlegs_anim:GetString()
        if VMLegs and vmlegsAnim ~= '' then VMLegs:PlayAnim(vmlegsAnim) end
    end
end

local function StartVault(ply, payload)
    SetWOS(ply, upar_effect_vault_wos_anim:GetString())

    if SERVER then
        EmitEffectSound(ply, upar_effect_vault_sound:GetString())
    elseif CLIENT then
        local vmanipAnim = upar_effect_vault_vmanip_anim:GetString()
        if VManip and vmanipAnim ~= '' then VManip:PlayAnim(vmanipAnim) end

        local vmlegsAnim = upar_effect_vault_vmlegs_anim:GetString()
        if VMLegs and vmlegsAnim ~= '' then VMLegs:PlayAnim(vmlegsAnim) end
    end
end

local function StartDoubleVaultState1(ply, payload)
    SetWOS(ply, upar_effect_doublevault_state1_wos_anim:GetString())

    if SERVER then
        ply:ViewPunch(Angle(-20, 5, 0))
        timer.Simple(0.2, function()
            if IsValid(ply) then ply:ViewPunch(Angle(20, 0, 0)) end
        end)
        EmitEffectSound(ply, upar_effect_doublevault_state1_sound:GetString())
    elseif CLIENT then
        local vmanipAnim = upar_effect_doublevault_state1_vmanip_anim:GetString()
        if VManip and vmanipAnim ~= '' then VManip:PlayAnim(vmanipAnim) end

        local vmlegsAnim = upar_effect_doublevault_state1_vmlegs_anim:GetString()
        if VMLegs and vmlegsAnim ~= '' then VMLegs:PlayAnim(vmlegsAnim) end
    end
end

local function StartDoubleVaultState2(ply, payload)
    SetWOS(ply, upar_effect_doublevault_state2_wos_anim:GetString())

    if SERVER then
        EmitEffectSound(ply, upar_effect_doublevault_state2_sound:GetString())
    elseif CLIENT then
        local vmanipAnim = upar_effect_doublevault_state2_vmanip_anim:GetString()
        if VManip and vmanipAnim ~= '' then VManip:PlayAnim(vmanipAnim) end

        local vmlegsAnim = upar_effect_doublevault_state2_vmlegs_anim:GetString()
        if VMLegs and vmlegsAnim ~= '' then VMLegs:PlayAnim(vmlegsAnim) end
    end
end

local function StartVerticalWallrun(ply, payload)
    SetWOS(ply, upar_effect_vertical_wallrun_wos_anim:GetString())
    if SERVER then
        EmitEffectSound(ply, upar_effect_vertical_wallrun_footstep_sound:GetString())
        EmitEffectSound(ply, upar_effect_vertical_wallrun_sound:GetString())
    elseif CLIENT then
        local vmanipAnim = upar_effect_vertical_wallrun_vmanip_anim:GetString()
        if VManip and vmanipAnim ~= '' then
            VManip:PlayAnim(vmanipAnim)
            if VManip:GetCurrentAnim() == vmanipAnim and IsValid(VManip:GetVMGesture()) then
                VManip:GetVMGesture().RenderOverride = function(self)
                    local normal = payload and payload.normal or nil
                    local along = payload and payload.along or nil

                    local newPos
                    local newAnlge
                    if isvector(along) and isvector(normal) then
                        newPos = EyePos() - along * 64
                        newAnlge = (-normal):Angle()
                    else
                        newPos = EyePos() - ply:EyeAngles():Up() * 64
                        newAnlge = ply:EyeAngles()
                    end

                    self:SetPos(newPos)
                    self:SetAngles(newAnlge)
                end
            end
        end

        local vmlegsAnim = upar_effect_vertical_wallrun_vmlegs_anim:GetString()
        if VMLegs and vmlegsAnim ~= '' then VMLegs:PlayAnim(vmlegsAnim) end
    end
end

local function StartHorizontalWallrun(ply, payload)
    SetWOS(ply, upar_effect_horizontal_wallrun_wos_anim:GetString())

    if SERVER then
        EmitEffectSound(ply, upar_effect_horizontal_wallrun_footstep_sound:GetString())
        EmitEffectSound(ply, upar_effect_horizontal_wallrun_sound:GetString())
    elseif CLIENT then
        if payload and payload.along then
            horizontalWallrun.centerYaw = math.deg(math.atan2(payload.along.y, payload.along.x))
            local rollDirection = payload.side == 'left' and 1 or -1
            horizontalWallrun.rollTarget =
                rollDirection * UPar.EffectMAGIC.HORIZONTAL_WALLRUN_ROLL
            horizontalWallrun.rollActive = true
        end

        local vmanipAnim = upar_effect_horizontal_wallrun_vmanip_anim:GetString()
        if VManip and vmanipAnim ~= '' and payload.side == 'left' then 
            VManip:PlayAnim(vmanipAnim) 
            if VManip:GetCurrentAnim() == vmanipAnim and IsValid(VManip:GetVMGesture()) then
                VManip:GetVMGesture().RenderOverride = function(self)
                    local along = payload and payload.along or nil
                    self:SetAngles(along and along:Angle() or ply:EyeAngles())
                end
            end
        end

        local vmlegsAnim = upar_effect_horizontal_wallrun_vmlegs_anim:GetString()
        if VMLegs and vmlegsAnim ~= '' then VMLegs:PlayAnim(vmlegsAnim) end
    end
end

local function StopLowClimb(ply)
    local anim = upar_effect_lowclimb_vmanip_anim:GetString()
    if CLIENT and VManip and anim ~= '' and VManip:GetCurrentAnim() == anim then
        VManip:QuitHolding(anim)
    end
    ClearWOS(ply)
end

local function StopHighClimb(ply)
    local anim = upar_effect_highclimb_vmanip_anim:GetString()
    if CLIENT and VManip and anim ~= '' and VManip:GetCurrentAnim() == anim then
        VManip:QuitHolding(anim)
    end
    ClearWOS(ply)
end

local function StopVault(ply)
    local anim = upar_effect_vault_vmanip_anim:GetString()
    if CLIENT and VManip and anim ~= '' and VManip:GetCurrentAnim() == anim then
        VManip:QuitHolding(anim)
    end
    ClearWOS(ply)
end

local function StopDoubleVaultState1(ply)
    local anim = upar_effect_doublevault_state1_vmanip_anim:GetString()
    if CLIENT and VManip and anim ~= '' and VManip:GetCurrentAnim() == anim then
        VManip:QuitHolding(anim)
    end
    ClearWOS(ply)
end

local function StopDoubleVaultState2(ply)
    local anim = upar_effect_doublevault_state2_vmanip_anim:GetString()
    if CLIENT and VManip and anim ~= '' and VManip:GetCurrentAnim() == anim then
        VManip:QuitHolding(anim)
    end
    ClearWOS(ply)
end

local function StopVerticalWallrun(ply)
    local anim = upar_effect_vertical_wallrun_vmanip_anim:GetString()
    if CLIENT and VManip and anim ~= '' and VManip:GetCurrentAnim() == anim then
        VManip:QuitHolding(anim)
    end
    ClearWOS(ply)
end

local function InterruptVerticalWallrun(ply)
    local anim = upar_effect_vertical_wallrun_vmanip_anim:GetString()
    if CLIENT and VManip and anim ~= '' and VManip:GetCurrentAnim() == anim then
        VManip:QuitHolding(anim)
        if IsValid(VManip:GetVMGesture()) then VManip:Remove() end
    end
    ClearWOS(ply)
end

local function StopHorizontalWallrun(ply)
    if CLIENT then
        horizontalWallrun.centerYaw = nil
        horizontalWallrun.rollTarget = 0
        horizontalWallrun.rollActive = true
    end

    local anim = upar_effect_horizontal_wallrun_vmanip_anim:GetString()
    if CLIENT and VManip and anim ~= '' and VManip:GetCurrentAnim() == anim then
        VManip:QuitHolding(anim)
    end
    ClearWOS(ply)
end

local function InterruptHorizontalWallrun(ply)
    if CLIENT then
        horizontalWallrun.centerYaw = nil
        horizontalWallrun.rollTarget = 0
        horizontalWallrun.rollActive = true
    end

    local anim = upar_effect_horizontal_wallrun_vmanip_anim:GetString()
    if CLIENT and VManip and anim ~= '' and VManip:GetCurrentAnim() == anim then
        VManip:QuitHolding(anim)
        if IsValid(VManip:GetVMGesture()) then VManip:Remove() end
    end
    ClearWOS(ply)
end

local function StopAllEffects(ply)
    StopLowClimb(ply)
    StopHighClimb(ply)
    StopVault(ply)
    StopDoubleVaultState1(ply)
    StopDoubleVaultState2(ply)
    StopVerticalWallrun(ply)
    StopHorizontalWallrun(ply)
end

local function OnMoveFlag(ply, flag, payload)
    if flag == 'low_climb_end' then
        StopLowClimb(ply)
    elseif flag == 'high_climb_end' then
        StopHighClimb(ply)
    elseif flag == 'vault_end' then
        StopVault(ply)
    elseif flag == 'double_vault_end' then
        StopDoubleVaultState2(ply)
    elseif flag == 'vertical_wallrun_end' then
        StopVerticalWallrun(ply)
    elseif flag == 'horizontal_wallrun_end' then
        StopHorizontalWallrun(ply)
    elseif flag == 'wallrun_interrupt' then
        InterruptVerticalWallrun(ply)
        InterruptHorizontalWallrun(ply)
    elseif flag == 'vertical_wallrun_step' then
        EmitEffectSound(ply, upar_effect_vertical_wallrun_footstep_sound:GetString())
    elseif flag == 'horizontal_wallrun_step' then
        EmitEffectSound(ply, upar_effect_horizontal_wallrun_footstep_sound:GetString())
    elseif flag == 'vertical_wallrun_jump' then
        if SERVER then ply:ViewPunch(Angle(5, 0, 0)) end
        EmitEffectSound(ply, upar_effect_vertical_wallrun_clean_sound:GetString())
        StopVerticalWallrun(ply)
    elseif flag == 'horizontal_wallrun_jump' then
        if SERVER then ply:ViewPunch(Angle(5, 0, 0)) end
        EmitEffectSound(ply, upar_effect_horizontal_wallrun_clean_sound:GetString())
        StopHorizontalWallrun(ply)
    elseif flag == 'low_climb_start' then
        StartLowClimb(ply, payload)
    elseif flag == 'high_climb_start' then
        StartHighClimb(ply, payload)
    elseif flag == 'vault_start' then
        StartVault(ply, payload)
    elseif flag == 'double_vault_state1' then
        StartDoubleVaultState1(ply, payload)
    elseif flag == 'double_vault_state2' then
        StopDoubleVaultState1(ply)
        StartDoubleVaultState2(ply, payload)
    elseif flag == 'vertical_wallrun_start' then
        StartVerticalWallrun(ply, payload)
    elseif flag == 'horizontal_wallrun_start' then
        StartHorizontalWallrun(ply, payload)
    end
end

hook.Add('UParMoveFlag', 'upar.effect.flag', OnMoveFlag)
hook.Add('PlayerDeath', 'upar.effect.clear', function(ply) StopAllEffects(ply) end)
hook.Add('PlayerSpawn', 'upar.effect.clear', function(ply) StopAllEffects(ply) end)
hook.Add('PlayerDisconnect', 'upar.effect.clear', function(ply) StopAllEffects(ply) end)
