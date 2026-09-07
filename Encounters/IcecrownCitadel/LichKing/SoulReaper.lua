local _, ns = ...
ns = ns or {}

local SoulReaper = {
    MaxReapers = 8,

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

    -- Canonical action names. Runtime class files resolve these to actual spell/item IDs.
    Actions = {
        core_pair = { before = { "core", "core" }, after = { "ams" } },
        core_pair_ibf = { before = { "core", "core" }, after = { "ibf" } },
        ibf_solo = { before = { "ibf" }, after = { "ibf" } },
        remaining_core_trinket = { before = { "remaining_core", "trinket" }, after = { "army" } },
        remaining_core_pain = { before = { "remaining_core" }, after = { "pain" } },
    },
}

local function phaseData(phase)
    if phase == 2 then return SoulReaper.Phase2, SoulReaper.Details.Phase2 end
    if phase == 3 then return SoulReaper.Phase3, SoulReaper.Details.Phase3 end
end

function SoulReaper.IsValid(phase, number)
    if type(number) ~= "number" or number < 1 or number > SoulReaper.MaxReapers then
        return false
    end
    local strategies = phaseData(phase)
    return strategies and strategies[number] ~= nil or false
end

function SoulReaper.GetStrategy(phase, number)
    local strategies = phaseData(phase)
    return strategies and strategies[number] or nil
end

function SoulReaper.GetDetails(phase, number)
    local _, details = phaseData(phase)
    return details and details[number] or nil
end

function SoulReaper.GetActions(phase, number)
    local strategy = SoulReaper.GetStrategy(phase, number)
    return strategy and SoulReaper.Actions[strategy] or nil
end

function SoulReaper.GetPlan(phase, number)
    if not SoulReaper.IsValid(phase, number) then return nil end

    local details = SoulReaper.GetDetails(phase, number)
    local actions = SoulReaper.GetActions(phase, number)
    if not actions or not actions.before or not actions.after then return nil end

    return {
        phase = phase,
        number = number,
        strategy = SoulReaper.GetStrategy(phase, number),
        actions = actions,
        beforeActions = actions.before,
        afterActions = actions.after,
        type = details and details.type or nil,
        extra = details and details.extra or nil,
        close = details and details.close or nil,
    }
end

function SoulReaper.GetPhaseCount(phase)
    local strategies = phaseData(phase)
    if not strategies then return 0 end

    local count = 0
    for i = 1, SoulReaper.MaxReapers do
        if strategies[i] then count = i else break end
    end
    return count
end

ns.LichKingSoulReaper = SoulReaper

if _G.GuardpointLichKing then
    _G.GuardpointLichKing.SoulReaper = SoulReaper
end
