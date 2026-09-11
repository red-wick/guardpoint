Guardpoint.State = Guardpoint.State or {
    playerClass = nil,
    inCombat = false,
    instance = nil,
    encounter = nil,
    encounterStartedAt = nil,
}

function Guardpoint.State:RefreshPlayer()
    local class = UnitClass("player")
    self.playerClass = class
end

function Guardpoint.State:RefreshInstance()
    if not Guardpoint.Encounters or not Guardpoint.Encounters.Registry then
        self.instance = nil
        self.encounter = nil
        self.encounterStartedAt = nil
        return
    end

    self.instance = Guardpoint.Encounters.Registry:GetCurrent()
    self.encounter = nil
    self.encounterStartedAt = nil
end

function Guardpoint.State:SetCombat(active)
    self.inCombat = active and true or false
end

function Guardpoint.State:SetEncounter(encounter)
    self.encounter = encounter
    self.encounterStartedAt = encounter and GetTime() or nil
end
