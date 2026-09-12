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
