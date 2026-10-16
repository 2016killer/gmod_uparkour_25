AddCSLuaFile()

if not CLIENT then return end

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
                upar_speed_climb = '200',
                upar_speed_vault = '200',
                upar_speed_doublevault_state_1 = '200',
                upar_speed_doublevault_state_2 = '200',
                upar_speed_vertical_wallrun = '300',
                upar_vertical_wallrun_height_ratio = '1.4',
                upar_speed_vertical_wallrun_jump = '300',
                upar_speed_horizontal_wallrun = '300',
                upar_horizontal_wallrun_duration = '1',
                upar_speed_horizontal_wallrun_jump = '300',
                upar_wallrun_vertical_angle = '40',
                upar_wallrun_horizontal_angle = '5',
                upar_obstacle_ragdoll = '1',
                upar_obstacle_character = '1',
                upar_obstacle_require_frozen = '0',
                upar_lowclimb_enabled = '1',
                upar_highclimb_enabled = '1',
                upar_vault_enabled = '1',
                upar_doublevault_enabled = '1',
                upar_lowclimb_min_height = '0.4',
                upar_lowclimb_max_height = '0.86',
                upar_highclimb_min_height = '0.87',
                upar_highclimb_max_height = '1.2',
                upar_vertical_wallrun_enabled = '1',
                upar_horizontal_wallrun_enabled = '1',
                upar_lowclimb_trigger_ratio = '0.278',
                upar_highclimb_trigger_ratio = '0.278',
                upar_vault_trigger_ratio = '0.48',
                upar_doublevault_trigger_ratio = '0.278',
                upar_trigger_speed_comp_factor = '3',
                upar_lowclimb_trigger_speed_comp = '0.5',
                upar_highclimb_trigger_speed_comp = '0.5',
                upar_vault_trigger_speed_comp = '1.5',
                upar_doublevault_trigger_speed_comp = '0.5',
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
            panel:NumSlider(language.GetPhrase('#upgui.motion.lowclimb_min_height'), 'upar_lowclimb_min_height', 0, 1.5, 2)
            panel:NumSlider(language.GetPhrase('#upgui.motion.lowclimb_max_height'), 'upar_lowclimb_max_height', 0, 1.5, 2)
            panel:NumSlider(language.GetPhrase('#upgui.motion.highclimb_min_height'), 'upar_highclimb_min_height', 0, 1.5, 2)
            panel:NumSlider(language.GetPhrase('#upgui.motion.highclimb_max_height'), 'upar_highclimb_max_height', 0, 1.5, 2)
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
            panel:NumSlider(language.GetPhrase('#upgui.motion.trigger_speed_comp_factor'),
                'upar_trigger_speed_comp_factor', 0, 12, 2)
            panel:NumSlider(language.GetPhrase('#upgui.motion.lowclimb_trigger_speed_comp'),
                'upar_lowclimb_trigger_speed_comp', 0, 3, 2)
            panel:NumSlider(language.GetPhrase('#upgui.motion.highclimb_trigger_speed_comp'),
                'upar_highclimb_trigger_speed_comp', 0, 3, 2)
            panel:NumSlider(language.GetPhrase('#upgui.motion.vault_trigger_speed_comp'),
                'upar_vault_trigger_speed_comp', 0, 3, 2)
            panel:NumSlider(language.GetPhrase('#upgui.motion.doublevault_trigger_speed_comp'),
                'upar_doublevault_trigger_speed_comp', 0, 3, 2)
            panel:ControlHelp(language.GetPhrase('#upgui.motion.trigger_speed_comp.desc'))

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
