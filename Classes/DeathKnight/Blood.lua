-- Guardpoint Blood Death Knight module
local NS = _G.Guardpoint

NS.BloodDK = NS.BloodDK or {}
local DK = NS.BloodDK

DK.Class = "DEATHKNIGHT"

DK.Spells = {
    BloodTap = 45529,
    VampiricBlood = 55233,
    AntiMagicShell = 48707,
    IceboundFortitude = 48792,
    ArmyOfDead = 42650,
    PainSuppression = 33206,
    HandOfSacrifice = 6940,

    -- Canonical planner keys.
    TAP = 45529,
    VB = 55233,
    AMS = 48707,
    IBF = 48792,
    ARMY = 42650,
    PAIN = 33206,
    SAC = 6940,
}

DK.Items = {
    FangNormal = 50361,
    FangHeroic = 50364,
    SatrinaNormal = 47080,
    SatrinaHeroic = 47088,
    Key = 50356,

    -- Canonical planner keys.
    FANG_N = 50361,
    FANG_H = 50364,
    SATRINA_N = 47080,
    SATRINA_H = 47088,
    KEY = 50356,
}

DK.Actions = {
    tap = DK.Spells.TAP,
    vb = DK.Spells.VB,
    ams = DK.Spells.AMS,
    ibf = DK.Spells.IBF,
    army = DK.Spells.ARMY,
    pain = DK.Spells.PAIN,
    sac = DK.Spells.SAC,
}
