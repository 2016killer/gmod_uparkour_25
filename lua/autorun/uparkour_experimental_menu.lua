AddCSLuaFile()

if not CLIENT then return end

hook.Add('PopulateToolMenu', 'upar.menu.experimental', function()
    spawnmenu.AddToolMenuOption('Options', 'UParkour', 'upar.menu.experimental',
        language.GetPhrase('#upgui.menu.experimental'), '', '', function(panel)
            panel:Clear()

            panel:CheckBox(
                language.GetPhrase('#upgui.experimental.throughglass_vault_enabled'),
                'upar_throughglass_vault_enabled'
            )

            panel:Help('')
            panel:ControlHelp('=========== ' .. UPar.Version .. ' ===========')
    end)
end)
