AddCSLuaFile()

if not CLIENT then return end


CreateClientConVar('upar_key_trigger_key', tostring(KEY_SPACE), true, false, '')


hook.Add('PopulateToolMenu', 'upar.menu.key', function()
    spawnmenu.AddToolMenuOption('Options', 'UParkour', 'upar.menu.key',
        language.GetPhrase('#upgui.menu.key'), '', '', function(panel)
            panel:Clear()

            local ctrl = vgui.Create('ControlPresets', panel)
            ctrl:SetPreset('upar_key')
            local default = {
                upar_key_vault_require_shift = '1',
                upar_key_doublevault_require_shift = '1',
                upar_key_block_backstrafe = '1',
                upar_safe_mode = '0',
                upar_continuous_detect = '1',
                upar_continuous_detect_interval = '6',
            }
            ctrl:AddOption('#default', default)
            for k, _ in pairs(default) do
                ctrl:AddConVar(k)
            end
            panel:AddPanel(ctrl)

            panel:KeyBinder(language.GetPhrase('#upgui.key.trigger_key'), 'upar_key_trigger_key')
            panel:CheckBox(language.GetPhrase('#upgui.key.vault') .. language.GetPhrase('#upgui.motion.require_shift'), 'upar_key_vault_require_shift')
            panel:CheckBox(language.GetPhrase('#upgui.key.doublevault') .. language.GetPhrase('#upgui.motion.require_shift'), 'upar_key_doublevault_require_shift')
            panel:CheckBox(language.GetPhrase('#upgui.key.block_backstrafe'), 'upar_key_block_backstrafe')
            panel:CheckBox(language.GetPhrase('#upgui.motion.safe_mode'), 'upar_safe_mode')
            panel:ControlHelp(language.GetPhrase('#upgui.motion.safe_mode.desc'))
            panel:CheckBox(language.GetPhrase('#upgui.motion.continuous_detect'), 'upar_continuous_detect')
            panel:ControlHelp(language.GetPhrase('#upgui.motion.continuous_detect.desc'))
            panel:NumSlider(language.GetPhrase('#upgui.motion.continuous_detect_interval'),
                'upar_continuous_detect_interval', 1, 20, 0)
            panel:ControlHelp(language.GetPhrase('#upgui.motion.continuous_detect_interval.desc'))
            
            panel:Help('')
            panel:ControlHelp('=========== '.. UPar.Version ..' ===========')
    end)
end)


hook.Add('PopulateToolMenu', 'upar.menu.effect', function()
    spawnmenu.AddToolMenuOption('Options', 'UParkour', 'upar.menu.effect',
        language.GetPhrase('#upgui.menu.effect'), '', '', function(panel)
            panel:Clear()

            local ctrl = vgui.Create('ControlPresets', panel)
            ctrl:SetPreset('upar_effect')

            local default = {
                upar_effect_lowclimb_sound = 'uparkour/dishonored/lowclimb.mp3',
                upar_effect_lowclimb_vmanip_anim = 'vault',
                upar_effect_lowclimb_vmlegs_anim = '',
                upar_effect_lowclimb_wos_anim = 'wos_Vaultlow',
                upar_effect_highclimb_sound = 'uparkour/dishonored/highclimb.mp3',
                upar_effect_highclimb_vmanip_anim = 'dp_catch_mtbntb',
                upar_effect_highclimb_vmlegs_anim = '',
                upar_effect_highclimb_wos_anim = 'wos_Vaulthigh',
                upar_effect_vault_sound = 'uparkour/dishonored/vault.mp3',
                upar_effect_vault_vmanip_anim = 'vault',
                upar_effect_vault_vmlegs_anim = 'dp_lazy_BaiLang',
                upar_effect_vault_wos_anim = 'wos_Vault',
                upar_effect_doublevault_state1_sound = 'uparkour/mtbntb/highclimb.mp3',
                upar_effect_doublevault_state1_vmanip_anim = 'dp_catch_mtbntb',
                upar_effect_doublevault_state1_vmlegs_anim = '',
                upar_effect_doublevault_state1_wos_anim = 'wos_Vaulthigh',
                upar_effect_doublevault_state2_sound = '',
                upar_effect_doublevault_state2_vmanip_anim = 'vault',
                upar_effect_doublevault_state2_vmlegs_anim = 'dp_lazy_BaiLang',
                upar_effect_doublevault_state2_wos_anim = 'wos_Vault',
                upar_effect_vertical_wallrun_sound = '',
                upar_effect_vertical_wallrun_footstep_sound = 'wallrun_footstep',
                upar_effect_vertical_wallrun_clean_sound = 'wallrun_clean',
                upar_effect_vertical_wallrun_vmanip_anim = 'verticalwallrun',
                upar_effect_vertical_wallrun_vmlegs_anim = '',
                upar_effect_vertical_wallrun_wos_anim = '',
                upar_effect_horizontal_wallrun_sound = '',
                upar_effect_horizontal_wallrun_footstep_sound = 'wallrun_footstep',
                upar_effect_horizontal_wallrun_clean_sound = 'wallrun_clean',
                upar_effect_horizontal_wallrun_vmanip_anim = 'horizontalwallrun_YongLi',
                upar_effect_horizontal_wallrun_vmlegs_anim = '',
                upar_effect_horizontal_wallrun_wos_anim = '',
            }

            ctrl:AddOption('#default', default)

            for k, _ in pairs(default) do
                ctrl:AddConVar(k)
            end

            local VManipAnims = {}
            for a, _ in pairs(VManip and VManip.Anims or {}) do table.insert(VManipAnims, a) end 
            table.sort(VManipAnims)

            local VMLegsAnims = {}
            for a, _ in pairs(VMLegs and VMLegs.Anims or {}) do table.insert(VMLegsAnims, a) end 
            table.sort(VMLegsAnims)

            local function VManipAnimsComboBox(label, cvarname)
                local combobox, label = panel:ComboBox(language.GetPhrase('#upgui.effect.vmanip'), cvarname)
                combobox:AddChoice('', '')
                for _, anim in ipairs(VManipAnims) do  
                    combobox:AddChoice(anim, anim)
                end
                return combobox, label
            end

            local function VMLegsAnimsComboBox(label, cvarname)
                local combobox, label = panel:ComboBox(language.GetPhrase('#upgui.effect.vmlegs'), cvarname)
                combobox:AddChoice('', '')
                for _, anim in ipairs(VMLegsAnims) do
                    combobox:AddChoice(anim, anim)
                end
                return combobox, label
            end


            panel:AddPanel(ctrl)

            panel:Help('====' .. language.GetPhrase('#upgui.effect.lowclimb') .. '====')
            panel:TextEntry(language.GetPhrase('#upgui.effect.sound'), 'upar_effect_lowclimb_sound')
            VManipAnimsComboBox(language.GetPhrase('#upgui.effect.vmanip'), 'upar_effect_lowclimb_vmanip_anim')
            VMLegsAnimsComboBox(language.GetPhrase('#upgui.effect.vmlegs'), 'upar_effect_lowclimb_vmlegs_anim')
            panel:TextEntry(language.GetPhrase('#upgui.effect.wos'), 'upar_effect_lowclimb_wos_anim')

            panel:Help('====' .. language.GetPhrase('#upgui.effect.highclimb') .. '====')
            panel:TextEntry(language.GetPhrase('#upgui.effect.sound'), 'upar_effect_highclimb_sound')
            VManipAnimsComboBox(language.GetPhrase('#upgui.effect.vmanip'), 'upar_effect_highclimb_vmanip_anim')
            VMLegsAnimsComboBox(language.GetPhrase('#upgui.effect.vmlegs'), 'upar_effect_highclimb_vmlegs_anim')
            panel:TextEntry(language.GetPhrase('#upgui.effect.wos'), 'upar_effect_highclimb_wos_anim')

            panel:Help('====' .. language.GetPhrase('#upgui.effect.vault') .. '====')
            panel:TextEntry(language.GetPhrase('#upgui.effect.sound'), 'upar_effect_vault_sound')
            VManipAnimsComboBox(language.GetPhrase('#upgui.effect.vmanip'), 'upar_effect_vault_vmanip_anim')
            VMLegsAnimsComboBox(language.GetPhrase('#upgui.effect.vmlegs'), 'upar_effect_vault_vmlegs_anim')
            panel:TextEntry(language.GetPhrase('#upgui.effect.wos'), 'upar_effect_vault_wos_anim')

            panel:Help('====' .. language.GetPhrase('#upgui.effect.doublevault.state1') .. '====')
            panel:TextEntry(language.GetPhrase('#upgui.effect.sound'), 'upar_effect_doublevault_state1_sound')
            VManipAnimsComboBox(language.GetPhrase('#upgui.effect.vmanip'), 'upar_effect_doublevault_state1_vmanip_anim')
            VMLegsAnimsComboBox(language.GetPhrase('#upgui.effect.vmlegs'), 'upar_effect_doublevault_state1_vmlegs_anim')
            panel:TextEntry(language.GetPhrase('#upgui.effect.wos'), 'upar_effect_doublevault_state1_wos_anim')

            panel:Help('====' .. language.GetPhrase('#upgui.effect.doublevault.state2') .. '====')
            panel:TextEntry(language.GetPhrase('#upgui.effect.sound'), 'upar_effect_doublevault_state2_sound')
            VManipAnimsComboBox(language.GetPhrase('#upgui.effect.vmanip'), 'upar_effect_doublevault_state2_vmanip_anim')
            VMLegsAnimsComboBox(language.GetPhrase('#upgui.effect.vmlegs'), 'upar_effect_doublevault_state2_vmlegs_anim')
            panel:TextEntry(language.GetPhrase('#upgui.effect.wos'), 'upar_effect_doublevault_state2_wos_anim')

            panel:Help('====' .. language.GetPhrase('#upgui.effect.vertical_wallrun') .. '====')
            panel:TextEntry(language.GetPhrase('#upgui.effect.sound'), 'upar_effect_vertical_wallrun_sound')
            panel:TextEntry(language.GetPhrase('#upgui.effect.footstep_sound'), 'upar_effect_vertical_wallrun_footstep_sound')
            panel:TextEntry(language.GetPhrase('#upgui.effect.clean_sound'), 'upar_effect_vertical_wallrun_clean_sound')
            VManipAnimsComboBox(language.GetPhrase('#upgui.effect.vmanip'), 'upar_effect_vertical_wallrun_vmanip_anim')
            VMLegsAnimsComboBox(language.GetPhrase('#upgui.effect.vmlegs'), 'upar_effect_vertical_wallrun_vmlegs_anim')
            panel:TextEntry(language.GetPhrase('#upgui.effect.wos'), 'upar_effect_vertical_wallrun_wos_anim')

            panel:Help('====' .. language.GetPhrase('#upgui.effect.horizontal_wallrun') .. '====')
            panel:TextEntry(language.GetPhrase('#upgui.effect.sound'), 'upar_effect_horizontal_wallrun_sound')
            panel:TextEntry(language.GetPhrase('#upgui.effect.footstep_sound'), 'upar_effect_horizontal_wallrun_footstep_sound')
            panel:TextEntry(language.GetPhrase('#upgui.effect.clean_sound'), 'upar_effect_horizontal_wallrun_clean_sound')
            VManipAnimsComboBox(language.GetPhrase('#upgui.effect.vmanip'), 'upar_effect_horizontal_wallrun_vmanip_anim')
            VMLegsAnimsComboBox(language.GetPhrase('#upgui.effect.vmlegs'), 'upar_effect_horizontal_wallrun_vmlegs_anim')
            panel:TextEntry(language.GetPhrase('#upgui.effect.wos'), 'upar_effect_horizontal_wallrun_wos_anim')

            panel:Help('')
            panel:ControlHelp('=========== '.. UPar.Version ..' ===========')
    end)
 end)

hook.Add('PopulateToolMenu', 'upar.menu.motion', function()
    spawnmenu.AddToolMenuOption('Options', 'UParkour', 'upar.menu.motion',
        language.GetPhrase('#upgui.menu.motion'), '', '', function(panel)
            panel:Clear()

            local ctrl = vgui.Create('ControlPresets', panel)
            ctrl:SetPreset('upar_motion')
            local default = {
                upar_enabled = '1',
                upar_facing_angle_delta = '40',
                upar_speed_angle_delta = '120',
                upar_speed_use_velocity = '1',
                upar_crouch_block = '0',
                upar_speed_climb = '0',
                upar_speed_vault = '0',
                upar_speed_doublevault_state_1 = '0',
                upar_speed_doublevault_state_2 = '0',
                upar_speed_vertical_wallrun = '0',
                upar_vertical_wallrun_height_ratio = '1.4',
                upar_speed_vertical_wallrun_jump = '0',
                upar_speed_horizontal_wallrun = '0',
                upar_horizontal_wallrun_duration = '1',
                upar_speed_horizontal_wallrun_jump = '0',
                upar_wallrun_vertical_angle = '40',
                upar_wallrun_horizontal_angle = '5',
                upar_obstacle_ragdoll = '1',
                upar_obstacle_character = '1',
                upar_obstacle_require_frozen = '0',
                upar_lowclimb_enabled = '1',
                upar_highclimb_enabled = '1',
                upar_vault_enabled = '1',
                upar_doublevault_enabled = '1',
                upar_vertical_wallrun_enabled = '1',
                upar_horizontal_wallrun_enabled = '1',
                upar_lowclimb_trigger_ratio = '0.278',
                upar_highclimb_trigger_ratio = '0.278',
                upar_vault_trigger_ratio = '0.48',
                upar_doublevault_trigger_ratio = '0.278',
            }
            ctrl:AddOption('#default', default)
            for k, _ in pairs(default) do
                ctrl:AddConVar(k)
            end
            panel:AddPanel(ctrl)

            panel:CheckBox(language.GetPhrase('#upgui.key.enabled'), 'upar_enabled')

            panel:ControlHelp('====' .. language.GetPhrase('#upgui.motion.category.enable') .. '====')
            panel:CheckBox(language.GetPhrase('#upgui.motion.lowclimb_enabled'), 'upar_lowclimb_enabled')
            panel:CheckBox(language.GetPhrase('#upgui.motion.highclimb_enabled'), 'upar_highclimb_enabled')
            panel:CheckBox(language.GetPhrase('#upgui.motion.vault_enabled'), 'upar_vault_enabled')
            panel:CheckBox(language.GetPhrase('#upgui.motion.doublevault_enabled'), 'upar_doublevault_enabled')
            panel:CheckBox(language.GetPhrase('#upgui.motion.vertical_wallrun_enabled'), 'upar_vertical_wallrun_enabled')
            panel:CheckBox(language.GetPhrase('#upgui.motion.horizontal_wallrun_enabled'), 'upar_horizontal_wallrun_enabled')

            panel:ControlHelp('====' .. language.GetPhrase('#upgui.motion.category.trigger') .. '====')
            panel:NumSlider(language.GetPhrase('#upgui.motion.facing_angle_delta'), 'upar_facing_angle_delta', 0, 90, 0)
            panel:NumSlider(language.GetPhrase('#upgui.motion.speed_angle_delta'), 'upar_speed_angle_delta', 0, 120, 0)
            panel:NumSlider(language.GetPhrase('#upgui.motion.wallrun_vertical_angle'),
                'upar_wallrun_vertical_angle', 0, 90, 0)
            panel:NumSlider(language.GetPhrase('#upgui.motion.wallrun_horizontal_angle'),
                'upar_wallrun_horizontal_angle', 0, 90, 0)
            panel:CheckBox(language.GetPhrase('#upgui.motion.crouch_block'), 'upar_crouch_block')
            panel:ControlHelp(language.GetPhrase('#upgui.motion.crouch_block.desc'))

            panel:ControlHelp('====' .. language.GetPhrase('#upgui.motion.category.obstacle') .. '====')
            panel:CheckBox(language.GetPhrase('#upgui.motion.ragdoll'), 'upar_obstacle_ragdoll')
            panel:CheckBox(language.GetPhrase('#upgui.motion.character'), 'upar_obstacle_character')
            panel:CheckBox(language.GetPhrase('#upgui.motion.require_frozen'), 'upar_obstacle_require_frozen')
            panel:ControlHelp(language.GetPhrase('#upgui.motion.require_frozen.desc'))

            panel:ControlHelp('====' .. language.GetPhrase('#upgui.motion.category.trigger_distance') .. '====')
            panel:NumSlider(language.GetPhrase('#upgui.motion.lowclimb_trigger_ratio'), 'upar_lowclimb_trigger_ratio', 0, 2.5, 2)
            panel:ControlHelp(language.GetPhrase('#upgui.motion.trigger_ratio.desc'))
            panel:NumSlider(language.GetPhrase('#upgui.motion.highclimb_trigger_ratio'), 'upar_highclimb_trigger_ratio', 0, 2.5, 2)
            panel:NumSlider(language.GetPhrase('#upgui.motion.vault_trigger_ratio'), 'upar_vault_trigger_ratio', 0, 2.5, 2)
            panel:NumSlider(language.GetPhrase('#upgui.motion.doublevault_trigger_ratio'), 'upar_doublevault_trigger_ratio', 0, 2.5, 2)

            panel:ControlHelp('====' .. language.GetPhrase('#upgui.motion.category.speed') .. '====')
            panel:ControlHelp(language.GetPhrase('#upgui.motion.speed_override.desc'))
            panel:CheckBox(language.GetPhrase('#upgui.motion.speed_use_velocity'), 'upar_speed_use_velocity')
            panel:NumSlider(language.GetPhrase('#upgui.motion.speed_climb'), 'upar_speed_climb', 0, 1000, 0)
            panel:NumSlider(language.GetPhrase('#upgui.motion.speed_vault'), 'upar_speed_vault', 0, 1000, 0)
            panel:NumSlider(language.GetPhrase('#upgui.motion.speed_doublevault_state_1'),
                'upar_speed_doublevault_state_1', 0, 1000, 0)
            panel:NumSlider(language.GetPhrase('#upgui.motion.speed_doublevault_state_2'),
                'upar_speed_doublevault_state_2', 0, 1000, 0)
            panel:NumSlider(language.GetPhrase('#upgui.motion.speed_vertical_wallrun'),
                'upar_speed_vertical_wallrun', 0, 1000, 0)
            panel:NumSlider(language.GetPhrase('#upgui.motion.speed_vertical_wallrun_jump'),
                'upar_speed_vertical_wallrun_jump', 0, 1000, 0)
            panel:NumSlider(language.GetPhrase('#upgui.motion.speed_horizontal_wallrun'),
                'upar_speed_horizontal_wallrun', 0, 1000, 0)
            panel:NumSlider(language.GetPhrase('#upgui.motion.speed_horizontal_wallrun_jump'),
                'upar_speed_horizontal_wallrun_jump', 0, 1000, 0)

            panel:ControlHelp('====' .. language.GetPhrase('#upgui.motion.category.duration_height') .. '====')
            panel:NumSlider(language.GetPhrase('#upgui.motion.vertical_wallrun_height_ratio'),
                'upar_vertical_wallrun_height_ratio', 0.1, 3, 2)
            panel:NumSlider(language.GetPhrase('#upgui.motion.horizontal_wallrun_duration'),
                'upar_horizontal_wallrun_duration', 0.1, 5, 2)

            panel:Help('')
            panel:ControlHelp('=========== '.. UPar.Version ..' ===========')
    end)
end)

local triggerKeyDown = false
local spaceKeyDown = false

hook.Add('CreateMove', 'upar.input.space', function(cmd)
    local key = GetConVar('upar_key_trigger_key'):GetInt()
    if key ~= KEY_SPACE then
        if spaceKeyDown then
            spaceKeyDown = false
            RunConsoleCommand('-upar_trigger')
        end
        return
    end

    local paused = game.IsPaused and game.IsPaused()
    local blocked = gui.IsGameUIVisible() or gui.IsConsoleVisible() or paused
    local down = not blocked and cmd:KeyDown(IN_JUMP)

    if down == spaceKeyDown then return end
    spaceKeyDown = down
    RunConsoleCommand(down and '+upar_trigger' or '-upar_trigger')
end)

hook.Add('Think', 'upar.input.trigger', function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local key = GetConVar('upar_key_trigger_key'):GetInt()
    if key == KEY_SPACE then
        if triggerKeyDown then
            triggerKeyDown = false
            RunConsoleCommand('-upar_trigger')
        end
        return
    end

    local paused = game.IsPaused and game.IsPaused()
    local blocked = gui.IsGameUIVisible() or gui.IsConsoleVisible() or paused
    local down = not blocked and input.IsKeyDown(key)

    if down == triggerKeyDown then return end
    triggerKeyDown = down
    RunConsoleCommand(down and '+upar_trigger' or '-upar_trigger')
end)
