Guardpoint.Encounters = Guardpoint.Encounters or {}
Guardpoint.Encounters.Registry = Guardpoint.Encounters.Registry or {}

local Registry = Guardpoint.Encounters.Registry
Registry.maps = Registry.maps or {}

function Registry:Register(instanceID, encounterData)
    if type(instanceID) ~= "number" or type(encounterData) ~= "table" then
        return
    end

    self[instanceID] = encounterData
end

function Registry:RegisterMap(mapID, encounterData)
    if type(mapID) ~= "number" or type(encounterData) ~= "table" then
        return
    end

    self.maps[mapID] = encounterData
end

function Registry:Get(instanceID)
    return self[instanceID]
end

function Registry:GetCurrent()
    local mapID = GetCurrentMapAreaID()
    return self.maps[mapID]
end

function Registry:GetCurrentMapID()
    return GetCurrentMapAreaID()
end
