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
                upar_continuous_detect = '1',
                upar_continuous_detect_interval = '3',
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
            panel:CheckBox(language.GetPhrase('#upgui.motion.continuous_detect'), 'upar_continuous_detect')
            panel:ControlHelp(language.GetPhrase('#upgui.motion.continuous_detect.desc'))
            panel:NumSlider(language.GetPhrase('#upgui.motion.continuous_detect_interval'),
                'upar_continuous_detect_interval', 1, 20, 0)
            panel:ControlHelp(language.GetPhrase('#upgui.motion.continuous_detect_interval.desc'))
            
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
