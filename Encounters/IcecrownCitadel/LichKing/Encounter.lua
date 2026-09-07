local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

local LichKing = {
    Id = "IcecrownCitadel/LichKing",
    BossID = 36597,
    MapID = 631,

    ReaperIDs = {
        [69409] = true,
        [73797] = true,
        [73798] = true,
        [73799] = true,
    },

    QuakeID = 72262,

    Timing = {
        P2First = 32.0,
        P3First = 37.5,
        NextReaper = 34.0,
        ReaperDuration = 5.1,
        Prewarn = 8.0,
        GlowLead = 5.0,
    },
}

function LichKing.CreatureEntryFromGUID(guid)
    if not guid then return nil end
    local hex = string.match(guid, "0x[%x]+")
    if hex then
        local body = string.sub(hex, 3)
        if string.len(body) >= 12 then
            local entry = tonumber(string.sub(body, 5, 10), 16)
            if entry then return entry end
        end
    end
    local entry = string.match(guid, "Creature%-[^%-]*%-[^%-]*%-([0-9]+)")
    return entry and tonumber(entry) or nil
end

function LichKing.IsBossGUID(guid)
    return LichKing.CreatureEntryFromGUID(guid) == LichKing.BossID
end

function LichKing.IsReaperSpell(spellID)
    return spellID and LichKing.ReaperIDs[spellID] == true
end

function LichKing.IsQuakeSpell(spellID)
    return spellID and spellID == LichKing.QuakeID
end

function LichKing.GetSoulReaper()
    return LichKing.SoulReaper
end

function LichKing.GetSoulReaperPlan(phase, number)
    local soulReaper = LichKing.GetSoulReaper()
    if soulReaper and soulReaper.GetPlan then
        return soulReaper.GetPlan(phase, number)
    end
end

function LichKing.ShouldSaveCorePair(phase, number)
    local soulReaper = LichKing.GetSoulReaper()
    if soulReaper and soulReaper.ShouldSaveCorePair then
        return soulReaper.ShouldSaveCorePair(phase, number)
    end
    return false
end

function LichKing.GetReaperDelay(phase, reaper)
    local timing = LichKing.Timing
    if not timing then return nil end
    if reaper == 0 then
        if phase == 3 then return timing.P3First end
        return timing.P2First
    end
    return timing.NextReaper
end

function LichKing.GetReaperDuration()
    return LichKing.Timing and LichKing.Timing.ReaperDuration
end

function LichKing.GetReaperPrewarn()
    return LichKing.Timing and LichKing.Timing.Prewarn
end

function LichKing.FindUnit()
    local units={"boss1","boss2","boss3","boss4","target","focus","mouseover"}
    for i=1,#units do
        local unit=units[i]
        if UnitExists(unit) then
            local guid=UnitGUID(unit)
            if LichKing.IsBossGUID(guid) then return guid end
        end
    end
end

function LichKing.IsUnitPresent(guid)
    if not guid then return false end
    local units={"boss1","boss2","boss3","boss4","target","focus","mouseover"}
    for i=1,#units do
        local unit=units[i]
        if UnitExists(unit) and UnitGUID(unit)==guid then return true end
    end
    return false
end

function LichKing.ScanSoulReaper()
    for i=1,40 do
        local _,_,_,_,_,duration,expiration,_,_,_,spellID=UnitDebuff("player",i)
        if spellID and LichKing.ReaperIDs[spellID] then
            return expiration or (GetTime()+LichKing.Timing.ReaperDuration)
        end
    end
end

NS.LichKing=LichKing
_G.GuardpointLichKing=LichKing

if NS.EncounterRegistry then
    NS.EncounterRegistry:Register(LichKing.Id, LichKing)
end
