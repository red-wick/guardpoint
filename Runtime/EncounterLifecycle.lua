Guardpoint.Runtime = Guardpoint.Runtime or {}

local Lifecycle = {}

Guardpoint.Runtime.EncounterLifecycle = Lifecycle

Guardpoint.EventBus:Register("ENCOUNTER_START", function()
    Guardpoint.Scheduler:CancelGroup("encounter")
end)

Guardpoint.EventBus:Register("ENCOUNTER_END", function()
    Guardpoint.Scheduler:CancelGroup("encounter")
end)
