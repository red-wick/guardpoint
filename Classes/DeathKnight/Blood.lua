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
}

DK.Items = {
    FangNormal = 50361,
    FangHeroic = 50364,
    SatrinaNormal = 47080,
    SatrinaHeroic = 47088,
    Key = 50356,
}

DK.Actions = {
    tap = DK.Spells.BloodTap,
    vb = DK.Spells.VampiricBlood,
    ams = DK.Spells.AntiMagicShell,
    ibf = DK.Spells.IceboundFortitude,
    army = DK.Spells.ArmyOfDead,
    pain = DK.Spells.PainSuppression,
    sac = DK.Spells.HandOfSacrifice,
}

DK.Items.FANG_N = DK.Items.FangNormal
DK.Items.FANG_H = DK.Items.FangHeroic
DK.Items.SATRINA_N = DK.Items.SatrinaNormal
DK.Items.SATRINA_H = DK.Items.SatrinaHeroic
DK.Items.KEY = DK.Items.Key
