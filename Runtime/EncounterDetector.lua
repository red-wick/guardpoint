Guardpoint.Runtime = Guardpoint.Runtime or {}

local Detector = {}
local npcIndex = {}
local active = nil

Guardpoint.Runtime.EncounterDetector = Detector

local function GetNPCID(guid)
    if type(guid) ~= "string" then
        return nil
    end

    if string.sub(guid, 1, 6) ~= "0xF130" then
        return nil
    end

    local entryHex = string.sub(guid, 7, 10)
    if string.len(entryHex) ~= 4 or not string.match(entryHex, "^%x%x%x%x$") then
        return nil
    end

    return tonumber(entryHex, 16)
end

local function RegisterEncounter(encounter)
    if type(encounter) ~= "table" then
        return
    end

    if type(encounter.npcID) == "number" then
        npcIndex[encounter.npcID] = encounter
    end

    if type(encounter.npcIDs) == "table" then
        for _, npcID in pairs(encounter.npcIDs) do
            if type(npcID) == "number" then
                npcIndex[npcID] = encounter
            end
        end
    end
end

local function RegisterRaidBosses(raid)
    if type(raid) ~= "table" or type(raid.encounters) ~= "table" then
        return
    end

    for _, encounter in pairs(raid.encounters) do
        RegisterEncounter(encounter)
    end
end

local function IsActiveNPCID(encounter, npcID)
    if type(encounter) ~= "table" then
        return false
    end

    if encounter.npcID == npcID then
        return true
    end

    if type(encounter.npcIDs) == "table" then
        for _, id in pairs(encounter.npcIDs) do
            if id == npcID then
                return true
            end
        end
    end

    return false
end

function Detector:Refresh()
    npcIndex = {}

    local raid = Guardpoint.Encounters.Registry:GetCurrent()
    RegisterRaidBosses(raid)
end

function Detector:GetActive()
    return active
end

function Detector:End(reason)
    local previous = active
    active = nil

    if reason == "LEAVE" then
        Guardpoint.State:ClearEncounter()
    elseif previous then
        Guardpoint.State:EndEncounter(reason)
    end

    if previous then
        Guardpoint.EventBus:Fire("ENCOUNTER_END", previous, reason)
    end
end

function Detector:Clear()
    self:End("WIPE")
end

function Detector:Reset()
    active = nil
end

function Detector:HandleCombatLog(...)
    local args = {...}
    local event = args[2]
    local sourceGUID = args[3]
    local destGUID = args[7]
    local sourceNPCID = GetNPCID(sourceGUID)
    local destNPCID = GetNPCID(destGUID)
    local encounter

    if destNPCID then
        encounter = npcIndex[destNPCID]
    end

    if not encounter and sourceNPCID then
        encounter = npcIndex[sourceNPCID]
    end

    if event == "UNIT_DIED" or event == "PARTY_KILL" then
        if active and IsActiveNPCID(active, destNPCID) then
            Guardpoint.State:CompleteEncounter()
            local completed = active
            active = nil
            Guardpoint.EventBus:Fire("ENCOUNTER_END", completed, "KILL")
        end
        return
    end

    if not encounter then
        return
    end

    if active ~= encounter then
        if active then
            self:End("SWITCH")
        end

        active = encounter
        Guardpoint.State:SetEncounter(encounter)
        Guardpoint.EventBus:Fire("ENCOUNTER_START", encounter)
    end
end

Guardpoint.EventBus:Register("COMBAT_END", function()
    if active then
        Detector:Clear()
    end
end)

Detector:Refresh()

local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        Detector:End("LEAVE")
        Detector:Refresh()
        return
    end

    Detector:HandleCombatLog(...)
end)
