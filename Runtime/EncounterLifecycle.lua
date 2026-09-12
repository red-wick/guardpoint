Guardpoint.Runtime = Guardpoint.Runtime or {}

local Lifecycle = {}

Guardpoint.Runtime.EncounterLifecycle = Lifecycle

local function CancelEncounterTasks()
    Guardpoint.Scheduler:CancelGroup("encounter")
end

Guardpoint.EventBus:Register("ENCOUNTER_START", function()
    CancelEncounterTasks()
end)

Guardpoint.EventBus:Register("ENCOUNTER_END", function(_, reason)
    CancelEncounterTasks()

    if Guardpoint.State:GetEncounter() then
        Guardpoint.State:SetEncounterEndReason(reason)
    end
end)
