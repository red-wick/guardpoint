SLASH_GUARDPOINT1 = "/guardpoint"
SLASH_GUARDPOINT2 = "/gp"

SlashCmdList.GUARDPOINT = function(message)
    local command = string.lower(message or "")

    if command == "debug" then
        local state = Guardpoint.State
        local instance = state:GetInstance()
        local encounter = state:GetEncounter()

        Guardpoint:Print("version " .. Guardpoint.VERSION)
        Guardpoint:Print("class: " .. tostring(state:GetPlayerClass()))
        Guardpoint:Print("combat: " .. tostring(state:IsInCombat()))
        Guardpoint:Print("instance: " .. tostring(instance and instance.name))
        Guardpoint:Print("encounter: " .. tostring(encounter and encounter.name))
        Guardpoint:Print("encounter active: " .. tostring(state:IsEncounterActive()))
        Guardpoint:Print("encounter completed: " .. tostring(state:IsEncounterCompleted()))
        Guardpoint:Print("encounter end reason: " .. tostring(state:GetEncounterEndReason()))
        Guardpoint:Print("encounter started at: " .. tostring(state:GetEncounterStartedAt()))
        Guardpoint:Print("encounter ended at: " .. tostring(state:GetEncounterEndedAt()))
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
    elseif string.sub(command, 1, 5) == "scale" then
        local value = tonumber(string.match(command, "^scale%s+([%d%.]+)$"))
        if value then
            if value < 0.5 then
                value = 0.5
            elseif value > 2 then
                value = 2
            end

            Guardpoint.Config:Set("scale", value)
            Guardpoint.UI.Panel:ApplyScale()
            Guardpoint:Print("scale set to " .. tostring(value))
        else
            Guardpoint:Print("usage: /gp scale 0.5-2")
        end
    elseif command == "reset" then
        Guardpoint.State:SetCombat(false)
        Guardpoint.State:ClearEncounter()
        Guardpoint.State:RefreshInstance()
        Guardpoint.UI.Panel:Reset()
        Guardpoint:Print("state and panel reset")
    else
        Guardpoint:Print("v" .. Guardpoint.VERSION .. " | /gp show | /gp hide | /gp scale | /gp lock | /gp unlock | /gp debug | /gp reset")
    end
end
