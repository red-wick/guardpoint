SLASH_GUARDPOINT1 = "/guardpoint"
SLASH_GUARDPOINT2 = "/gp"

SlashCmdList.GUARDPOINT = function(message)
    local command = string.lower(message or "")

    if command == "debug" then
        local state = Guardpoint.State
        Guardpoint:Print("version " .. Guardpoint.VERSION)
        Guardpoint:Print("class: " .. tostring(state.playerClass))
        Guardpoint:Print("combat: " .. tostring(state.inCombat))
        Guardpoint:Print("encounter: " .. tostring(state.encounter))
    elseif command == "reset" then
        Guardpoint.State:SetCombat(false)
        Guardpoint.State:SetEncounter(nil)
        Guardpoint:Print("state reset")
    else
        Guardpoint:Print("v" .. Guardpoint.VERSION .. " | /gp debug | /gp reset")
    end
end
