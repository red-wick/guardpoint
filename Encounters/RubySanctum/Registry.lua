Guardpoint.Encounters.RubySanctum = Guardpoint.Encounters.RubySanctum or {}

local RS = Guardpoint.Encounters.RubySanctum

RS.instanceID = 724
RS.name = "Ruby Sanctum"
RS.encounters = RS.encounters or {}

function RS:Register(encounterID, encounterData)
    if type(encounterID) ~= "number" or type(encounterData) ~= "table" then
        return
    end

    self.encounters[encounterID] = encounterData
end

function RS:Get(encounterID)
    return self.encounters[encounterID]
end

Guardpoint.Encounters.Registry:Register(RS.instanceID, RS)
