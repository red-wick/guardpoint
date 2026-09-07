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
}

function SoulReaper.GetStrategy(phase, number)
    local phaseData = phase == 2 and SoulReaper.Phase2 or SoulReaper.Phase3
    return phaseData and phaseData[number] or nil
end

ns.LichKingSoulReaper = SoulReaper

if _G.GuardpointLichKing then
    _G.GuardpointLichKing.SoulReaper = SoulReaper
end
