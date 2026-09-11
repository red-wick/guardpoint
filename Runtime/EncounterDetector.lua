Guardpoint.Runtime = Guardpoint.Runtime or {}

local Detector = {}
local npcIndex = {}
local active = nil

Guardpoint.Runtime.EncounterDetector = Detector

local function GetNPCID(guid)
    if type(guid) ~= "string" then
        return nil
    end

    return tonumber(string.match(guid, "^.-%-(%d+)%-%x+$"))
end

local function RegisterEncounter(encounter)
    if type(encounter) ~= "table" or type(encounter.npcID) ~= "number" then
        return
    end

    npcIndex[encounter.npcID] = encounter
end

local function RegisterRaidBosses(raid)
    if type(raid) ~= "table" or type(raid.encounters) ~= "table" then
        return
    end

    for _, encounter in pairs(raid.encounters) do
        RegisterEncounter(encounter)
    end
end

function Detector:Refresh()
    npcIndex = {}

    RegisterRaidBosses(Guardpoint.Encounters.IcecrownCitadel)
    RegisterRaidBosses(Guardpoint.Encounters.RubySanctum)
end

function Detector:GetActive()
    return active
end

function Detector:HandleCombatLog(...)
    local timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID = ...
    local npcID

    if event == "UNIT_DIED" then
        npcID = GetNPCID(destGUID)
        if active and active.npcID == npcID then
            active = nil
            Guardpoint.State:SetEncounter(nil)
        end
        return
    end

    npcID = GetNPCID(sourceGUID)
    if not npcID then
        return
    end

    local encounter = npcIndex[npcID]
    if not encounter then
        return
    end

    if active ~= encounter then
        active = encounter
        Guardpoint.State:SetEncounter(encounter)
    end
end

Detector:Refresh()

local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function(self, event, ...)
    Detector:HandleCombatLog(...)
end)
