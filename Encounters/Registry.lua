Guardpoint.Encounters = Guardpoint.Encounters or {}
Guardpoint.Encounters.Registry = Guardpoint.Encounters.Registry or {}

local Registry = Guardpoint.Encounters.Registry

function Registry:Register(instanceID, encounterData)
    if type(instanceID) ~= "number" or type(encounterData) ~= "table" then
        return
    end

    self[instanceID] = encounterData
end

function Registry:Get(instanceID)
    return self[instanceID]
end

function Registry:GetCurrent()
    local instanceID = GetCurrentMapAreaID()
    return self:Get(instanceID)
end
