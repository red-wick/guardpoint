Guardpoint.Data.Icons = Guardpoint.Data.Icons or {}

local Icons = Guardpoint.Data.Icons

Icons.Default = "Interface\\Icons\\INV_Misc_QuestionMark"

function Icons:GetSpell(spellID)
    if type(spellID) ~= "number" then
        return self.Default
    end

    local _, _, icon = GetSpellInfo(spellID)
    return icon or self.Default
end

function Icons:GetItem(itemID)
    if type(itemID) ~= "number" then
        return self.Default
    end

    return GetItemIcon(itemID) or self.Default
end
