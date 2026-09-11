Guardpoint.State = Guardpoint.State or {
    playerClass = nil,
    inCombat = false,
    encounter = nil,
}

function Guardpoint.State:RefreshPlayer()
    local class = UnitClass("player")
    self.playerClass = class
end

function Guardpoint.State:SetCombat(active)
    self.inCombat = active and true or false
end

function Guardpoint.State:SetEncounter(encounter)
    self.encounter = encounter
end
