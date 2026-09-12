Guardpoint.Runtime = Guardpoint.Runtime or {}

local CombatLog = {}

Guardpoint.Runtime.CombatLog = CombatLog

function CombatLog:Parse(...)
    local args = {...}

    return {
        timestamp = args[1],
        event = args[2],
        sourceGUID = args[3],
        sourceName = args[4],
        sourceFlags = args[5],
        sourceRaidFlags = args[6],
        destGUID = args[7],
        destName = args[8],
        destFlags = args[9],
        destRaidFlags = args[10],
        args = args,
    }
end

function CombatLog:GetNPCID(guid)
    if type(guid) ~= "string" then
        return nil
    end

    local entryHex = string.match(guid, "^0xF130%x%x(%x%x%x%x)")
    if not entryHex then
        return nil
    end

    return tonumber(entryHex, 16)
end

function CombatLog:IsDeathEvent(event)
    return event == "UNIT_DIED" or event == "PARTY_KILL"
end
