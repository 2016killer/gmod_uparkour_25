AddCSLuaFile()

if not CLIENT then return end

hook.Add('PopulateToolMenu', 'upar.menu.experimental', function()
    spawnmenu.AddToolMenuOption('Options', 'UParkour', 'upar.menu.experimental',
        language.GetPhrase('#upgui.menu.experimental'), '', '', function(panel)
            panel:Clear()

            local ctrl = vgui.Create('ControlPresets', panel)
            ctrl:SetPreset('upar_experimental')
            local default = {
                upar_throughglass_vault_enabled = '0',
                upar_throughglass_volume_limit = '0',
                upar_throughglass_health_limit = '0',
            }
            ctrl:AddOption('#default', default)
            for k, _ in pairs(default) do
                ctrl:AddConVar(k)
            end
            panel:AddPanel(ctrl)

            panel:CheckBox(
                language.GetPhrase('#upgui.experimental.throughglass_vault_enabled'),
                'upar_throughglass_vault_enabled'
            )
            panel:NumSlider(
                language.GetPhrase('#upgui.experimental.throughglass_volume_limit'),
                'upar_throughglass_volume_limit', 0, 1000000000, 0
            )
            panel:NumSlider(
                language.GetPhrase('#upgui.experimental.throughglass_health_limit'),
                'upar_throughglass_health_limit', 0, 10000, 0
            )
            panel:ControlHelp(language.GetPhrase('#upgui.experimental.throughglass_limits.desc'))

            panel:Help('')
            panel:ControlHelp('=========== ' .. UPar.Version .. ' ===========')
    end)
end)
