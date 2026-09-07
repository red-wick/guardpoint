local _, ns = ...
ns = ns or {}

ns.BloodDK = {
    Class = "DEATHKNIGHT",

    Spells = {
        BloodTap = 45529,
        VampiricBlood = 55233,
        AntiMagicShell = 48707,
        IceboundFortitude = 48792,
        ArmyOfDead = 42650,
        PainSuppression = 33206,
        HandOfSacrifice = 6940,

        -- Runtime aliases used by Guardpoint's action resolver.
        TAP = 45529,
        VB = 55233,
        AMS = 48707,
        IBF = 48792,
        ARMY = 42650,
        PAIN = 33206,
        SAC = 6940,
    },

    Items = {
        FangNormal = 50361,
        FangHeroic = 50364,
        SatrinaNormal = 47080,
        SatrinaHeroic = 47088,
        Key = 50356,

        -- Runtime aliases used by Guardpoint's item resolver.
        FANG_N = 50361,
        FANG_H = 50364,
        SATRINA_N = 47080,
        SATRINA_H = 47088,
    },
}

_G.Guardpoint = ns
