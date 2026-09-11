Guardpoint.Encounters.IcecrownCitadel = Guardpoint.Encounters.IcecrownCitadel or {}

local ICC = Guardpoint.Encounters.IcecrownCitadel

ICC.instanceID = 631
ICC.name = "Icecrown Citadel"
ICC.encounters = ICC.encounters or {}

function ICC:Register(encounterID, encounterData)
    if type(encounterID) ~= "number" or type(encounterData) ~= "table" then
        return
    end

    self.encounters[encounterID] = encounterData
end

function ICC:Get(encounterID)
    return self.encounters[encounterID]
end

Guardpoint.Encounters.Registry:Register(ICC.instanceID, ICC)
