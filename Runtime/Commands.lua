SLASH_GUARDPOINT1 = "/guardpoint"
SLASH_GUARDPOINT2 = "/gp"

SlashCmdList.GUARDPOINT = function(message)
    local command = string.lower(message or "")

    if command == "debug" then
        local state = Guardpoint.State
        Guardpoint:Print("version " .. Guardpoint.VERSION)
        Guardpoint:Print("class: " .. tostring(state.playerClass))
        Guardpoint:Print("combat: " .. tostring(state.inCombat))
        Guardpoint:Print("instance: " .. tostring(state.instance and state.instance.name))
        Guardpoint:Print("encounter: " .. tostring(state.encounter and state.encounter.name))
    elseif command == "show" then
        Guardpoint.UI.Panel:ShowPanel()
    elseif command == "hide" then
        Guardpoint.UI.Panel:HidePanel()
    elseif command == "lock" then
        Guardpoint.Config:Set("locked", true)
        Guardpoint:Print("panel locked")
    elseif command == "unlock" then
        Guardpoint.Config:Set("locked", false)
        Guardpoint:Print("panel unlocked")
    elseif command == "reset" then
        Guardpoint.State:SetCombat(false)
        Guardpoint.State:SetEncounter(nil)
        Guardpoint.State:RefreshInstance()
        Guardpoint.UI.Panel:Reset()
        Guardpoint:Print("state and panel reset")
    else
        Guardpoint:Print("v" .. Guardpoint.VERSION .. " | /gp show | /gp hide | /gp lock | /gp unlock | /gp debug | /gp reset")
    end
end
