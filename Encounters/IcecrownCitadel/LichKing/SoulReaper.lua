local _, ns = ...
ns = ns or {}

local SoulReaper = {
    Phase2 = {
        [1] = "core_pair",
        [2] = "ibf_solo",
        [3] = "core_pair",
        [4] = "remaining_core_trinket",
        [5] = "core_pair",
        [6] = "ibf_solo",
        [7] = "core_pair",
        [8] = "remaining_core_pain",
    },

    Phase3 = {
        [1] = "core_pair_ibf",
        [2] = "remaining_core_trinket",
        [3] = "core_pair",
        [4] = "ibf_solo",
        [5] = "core_pair",
        [6] = "remaining_core_pain",
        [7] = "ibf_solo",
        [8] = "core_pair",
    },

    -- Descriptive data kept separate from the runtime strategy strings.
    Details = {
        Phase2 = {
            [1] = { type = "pair", close = "ams" },
            [2] = { type = "solo", close = "ibf" },
            [3] = { type = "pair", close = "ams" },
            [4] = { type = "remaining", extra = "trinket", close = "army" },
            [5] = { type = "pair", close = "ams" },
            [6] = { type = "solo", close = "ibf" },
            [7] = { type = "pair", close = "ams" },
            [8] = { type = "remaining", close = "pain" },
        },

        Phase3 = {
            [1] = { type = "pair", close = "ibf" },
            [2] = { type = "remaining", extra = "trinket", close = "ams" },
            [3] = { type = "pair", close = "ams" },
            [4] = { type = "solo", close = "ibf" },
            [5] = { type = "pair", close = "ams" },
            [6] = { type = "remaining", close = "pain" },
            [7] = { type = "solo", close = "ibf" },
            [8] = { type = "pair", close = "ams" },
        },
    },
}

function SoulReaper.GetStrategy(phase, number)
    local phaseData = phase == 2 and SoulReaper.Phase2 or SoulReaper.Phase3
    return phaseData and phaseData[number] or nil
end

function SoulReaper.GetDetails(phase, number)
    local phaseData = phase == 2 and SoulReaper.Details.Phase2 or SoulReaper.Details.Phase3
    return phaseData and phaseData[number] or nil
end

function SoulReaper.GetPlan(phase, number)
    local strategy = SoulReaper.GetStrategy(phase, number)
    if not strategy then return nil end
    return {
        strategy = strategy,
        details = SoulReaper.GetDetails(phase, number),
    }
end

ns.LichKingSoulReaper = SoulReaper

if _G.GuardpointLichKing then
    _G.GuardpointLichKing.SoulReaper = SoulReaper
end
