local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

local SoulReaper = {
    MaxReapers = 8,

    Plans = {
        Phase2 = {
            [1] = { strategy = "core_pair", before = { "core", "core" }, after = { "ams" } },
            [2] = { strategy = "ibf_solo", before = { "ibf" }, after = { "ibf" } },
            [3] = { strategy = "core_pair", before = { "core", "core" }, after = { "ams" } },
            [4] = { strategy = "remaining_core_trinket", before = { "remaining_core", "trinket" }, after = { "army" } },
            [5] = { strategy = "core_pair", before = { "core", "core" }, after = { "ams" } },
            [6] = { strategy = "ibf_solo", before = { "ibf" }, after = { "ibf" } },
            [7] = { strategy = "core_pair", before = { "core", "core" }, after = { "ams" } },
            [8] = { strategy = "remaining_core_pain", before = { "remaining_core" }, after = { "pain" } },
        },
        Phase3 = {
            [1] = { strategy = "core_pair_ibf", before = { "core", "core" }, after = { "ibf" } },
            [2] = { strategy = "remaining_core_trinket", before = { "remaining_core", "trinket" }, after = { "ams" } },
            [3] = { strategy = "core_pair", before = { "core", "core" }, after = { "ams" } },
            [4] = { strategy = "ibf_solo", before = { "ibf" }, after = { "ibf" } },
            [5] = { strategy = "core_pair", before = { "core", "core" }, after = { "ams" } },
            [6] = { strategy = "remaining_core_pain", before = { "remaining_core" }, after = { "pain" } },
            [7] = { strategy = "ibf_solo", before = { "ibf" }, after = { "ibf" } },
            [8] = { strategy = "core_pair", before = { "core", "core" }, after = { "ams" } },
        },
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
}

local function planData(phase)
    if phase == 2 then return SoulReaper.Plans.Phase2 end
    if phase == 3 then return SoulReaper.Plans.Phase3 end
end

local function strategyMeta(strategy)
    if strategy == "core_pair" then return "pair", nil, "ams" end
    if strategy == "core_pair_ibf" then return "pair", nil, "ibf" end
    if strategy == "ibf_solo" then return "solo", nil, "ibf" end
    if strategy == "remaining_core_trinket" then return "remaining", "trinket", "army" end
    if strategy == "remaining_core_pain" then return "remaining", nil, "pain" end
end

function SoulReaper.GetStrategyMeta(strategy)
    return strategyMeta(strategy)
end

function SoulReaper.IsValid(phase, number)
    if type(number) ~= "number" or number < 1 or number > SoulReaper.MaxReapers then return false end
    local plans = planData(phase)
    return plans and plans[number] ~= nil or false
end

function SoulReaper.IsActionValid(action)
    return type(action) == "string" and SoulReaper.ValidActions[action] == true
end

local function validActionList(list)
    if type(list) ~= "table" or #list == 0 then return false end
    for i = 1, #list do
        if not SoulReaper.IsActionValid(list[i]) then return false end
    end
    return true
end

function SoulReaper.GetActions(phase, number)
    if not SoulReaper.IsValid(phase, number) then return nil end
    local plan = planData(phase)[number]
    if not plan then return nil end
    if not validActionList(plan.before) or not validActionList(plan.after) then return nil end

    return {
        before = plan.before,
        after = plan.after,
    }
end

function SoulReaper.GetStrategy(phase, number)
    if not SoulReaper.IsValid(phase, number) then return nil end
    return planData(phase)[number].strategy
end

function SoulReaper.GetPlan(phase, number)
    if not SoulReaper.IsValid(phase, number) then return nil end
    local plan = planData(phase)[number]
    local actions = SoulReaper.GetActions(phase, number)
    if not plan or not actions then return nil end

    local planType, extra, close = SoulReaper.GetStrategyMeta(plan.strategy)
    if not planType or not close then return nil end

    return {
        phase = phase,
        number = number,
        strategy = plan.strategy,
        actions = actions,
        beforeActions = actions.before,
        afterActions = actions.after,
        type = planType,
        extra = extra,
        close = close,
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

NS.LichKingSoulReaper = SoulReaper

if _G.GuardpointLichKing then
    _G.GuardpointLichKing.SoulReaper = SoulReaper
end
