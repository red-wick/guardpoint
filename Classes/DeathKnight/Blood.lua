-- Guardpoint Blood DK resources
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

NS.BloodDK = NS.BloodDK or {
    Class = "DEATHKNIGHT",
    Spec = "BLOOD",
    SpecTree = 1,

    Features = {
        FourT10 = true,
        FourT10Markers = {"плет", "scourgelord"},
    },

    Spells = {
        TAP = 45529,
        VB = 55233,
        AMS = 48707,
        IBF = 48792,
        ARMY = 42650,
        PAIN = 33206,
        SAC = 6940,
    },

    Items = {
        FANG_N = 50361,
        FANG_H = 50364,
        SATRINA_N = 47080,
        SATRINA_H = 47088,
        KEY = 50356,
    },

    Trinkets = {
        fang = {Names = {"синдрагос", "sindragosa"}},
        satrina = {Items = {47080, 47088}},
        key = {Items = {50356}},
    },

    Planner = {
        Core = {
            Trinkets = {"fang"},
            Spells = {"TAP", "VB"},
            FourT10Spells = {"TAP"},
        },
        PreFallback = {"PAIN", "SAC"},
        SoloPriority = {"IBF", "AMS", "ARMY", "PAIN", "SAC"},
    },
}

if NS.ClassRegistry then
    NS.ClassRegistry:Register(NS.BloodDK.Class, NS.BloodDK.Spec, NS.BloodDK)
end
