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
    },

    Actions = {
        core_pair = { before = { "core", "core" }, after = { "ams" } },
        core_pair_ibf = { before = { "core", "core" }, after = { "ibf" } },
        ibf_solo = { before = { "ibf" }, after = { "ibf" } },
        remaining_core_trinket = { before = { "remaining_core", "trinket" }, after = { "army" } },
        remaining_core_pain = { before = { "remaining_core" }, after = { "pain" } },
    },

    ValidActions = {
        core = true,
        remaining_core = true,
        trinket = true,
        ibf = true,
        ams = true,
        army = true,
        pain = true,
        sac = true,
    },

    Plans = {
        Phase2 = {
            [1] = { type = "pair", close = "ams", before = { "core", "core" }, after = { "ams" } },
            [2] = { type = "solo", close = "ibf", before = { "ibf" }, after = { "ibf" } },
            [3] = { type = "pair", close = "ams", before = { "core", "core" }, after = { "ams" } },
            [4] = { type = "remaining", extra = "trinket", close = "army", before = { "remaining_core", "trinket" }, after = { "army" } },
            [5] = { type = "pair", close = "ams", before = { "core", "core" }, after = { "ams" } },
            [6] = { type = "solo", close = "ibf", before = { "ibf" }, after = { "ibf" } },
            [7] = { type = "pair", close = "ams", before = { "core", "core" }, after = { "ams" } },
            [8] = { type = "remaining", close = "pain", before = { "remaining_core" }, after = { "pain" } },
        },
        Phase3 = {
            [1] = { type = "pair", close = "ibf", before = { "core", "core" }, after = { "ibf" } },
            [2] = { type = "remaining", extra = "trinket", close = "ams", before = { "remaining_core", "trinket" }, after = { "ams" } },
            [3] = { type = "pair", close = "ams", before = { "core", "core" }, after = { "ams" } },
            [4] = { type = "solo", close = "ibf", before = { "ibf" }, after = { "ibf" } },
            [5] = { type = "pair", close = "ams", before = { "core", "core" }, after = { "ams" } },
            [6] = { type = "remaining", close = "pain", before = { "remaining_core" }, after = { "pain" } },
            [7] = { type = "solo", close = "ibf", before = { "ibf" }, after = { "ibf" } },
            [8] = { type = "pair", close = "ams", before = { "core", "core" }, after = { "ams" } },
        },
    },
}

local function phaseData(phase)
    if phase == 2 then return SoulReaper.Phase2, SoulReaper.Details.Phase2 end
    if phase == 3 then return SoulReaper.Phase3, SoulReaper.Details.Phase3 end
end

local function planData(phase)
    if phase == 2 then return SoulReaper.Plans.Phase2 end
    if phase == 3 then return SoulReaper.Plans.Phase3 end
end

function SoulReaper.IsValid(phase, number)
    if type(number) ~= "number" or number < 1 or number > SoulReaper.MaxReapers then return false end
    local plans = planData(phase)
    return plans and plans[number] ~= nil or false
end

function SoulReaper.GetStrategy(phase, number)
    local strategies = phaseData(phase)
    return strategies and strategies[number] or nil
end

function SoulReaper.GetDetails(phase, number)
    local _, details = phaseData(phase)
    return details and details[number] or nil
end

function SoulReaper.IsActionValid(action)
    return type(action) == "string" and SoulReaper.ValidActions[action] == true
end

function SoulReaper.GetActions(phase, number)
    local strategy = SoulReaper.GetStrategy(phase, number)
    local actions = strategy and SoulReaper.Actions[strategy]
    if not actions then return nil end
    for _, list in pairs(actions) do
        for i = 1, #list do
            if not SoulReaper.IsActionValid(list[i]) then return nil end
        end
    end
    return actions
end

function SoulReaper.GetPlan(phase, number)
    if not SoulReaper.IsValid(phase, number) then return nil end
    local canonical = planData(phase)[number]
    if not canonical or not canonical.before or not canonical.after then return nil end
    local details = SoulReaper.GetDetails(phase, number)
    local strategy = SoulReaper.GetStrategy(phase, number)
    return {
        phase = phase,
        number = number,
        strategy = strategy,
        actions = { before = canonical.before, after = canonical.after },
        beforeActions = canonical.before,
        afterActions = canonical.after,
        type = canonical.type or (details and details.type) or nil,
        extra = canonical.extra or (details and details.extra) or nil,
        close = canonical.close or (details and details.close) or nil,
    }
end

function SoulReaper.GetPhaseCount(phase)
    local plans = planData(phase)
    if not plans then return 0 end
    local count = 0
    for i = 1, SoulReaper.MaxReapers do
        if plans[i] then count = i else break end
    end
    return count
end

ns.LichKingSoulReaper = SoulReaper

if _G.GuardpointLichKing then
    _G.GuardpointLichKing.SoulReaper = SoulReaper
end
