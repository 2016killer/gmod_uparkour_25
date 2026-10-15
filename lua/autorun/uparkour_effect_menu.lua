AddCSLuaFile()

if not CLIENT then return end

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