Guardpoint.Runtime = Guardpoint.Runtime or {}

local Detector = {}
local npcIndex = {}
local active = nil

Guardpoint.Runtime.EncounterDetector = Detector

local function GetNPCID(guid)
    if type(guid) ~= "string" then
        return nil
    end

    local entryHex = string.match(guid, "^0xF130%x%x(%x%x%x%x)")
    if not entryHex then
        return nil
    end

    return tonumber(entryHex, 16)
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

function Detector:Clear()
    active = nil
    Guardpoint.State:SetEncounter(nil)
end

function Detector:HandleCombatLog(...)
    local args = {...}
    local event
    local npcID
    local encounter

    for i = 1, table.getn(args) do
        local value = args[i]

        if type(value) == "string" then
            if not event and string.match(value, "^[A-Z_]+$") then
                event = value
            end

            local id = GetNPCID(value)
            if id then
                local candidate = npcIndex[id]
                if candidate then
                    npcID = id
                    encounter = candidate
                    break
                end
            end
        end
    end

    if event == "UNIT_DIED" then
        if active and npcID == active.npcID then
            self:Clear()
        end
        return
    end

    if not encounter then
        return
    end

    if active ~= encounter then
        active = encounter
        Guardpoint.State:SetEncounter(encounter)
    end
end

Guardpoint.EventBus:Register("COMBAT_END", function()
    Detector:Clear()
end)

Detector:Refresh()

local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", function(self, event, ...)
    Detector:HandleCombatLog(...)
end)
