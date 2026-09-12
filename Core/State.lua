Guardpoint.State = Guardpoint.State or {
    playerClass = nil,
    inCombat = false,
    instance = nil,
    mapID = nil,
    instanceName = nil,
    instanceType = nil,
    difficultyID = nil,
    maxPlayers = nil,
    encounter = nil,
    encounterActive = false,
    encounterStartedAt = nil,
    encounterEndedAt = nil,
    encounterCompleted = false,
    encounterEndReason = nil,
}

function Guardpoint.State:RefreshPlayer()
    local _, classToken = UnitClass("player")
    self.playerClass = classToken
end

function Guardpoint.State:RefreshInstance()
    self.instance = nil
    self.mapID = nil
    self.instanceName = nil
    self.instanceType = nil
    self.difficultyID = nil
    self.maxPlayers = nil

    if Guardpoint.Encounters and Guardpoint.Encounters.Registry then
        local registry = Guardpoint.Encounters.Registry
        self.mapID = registry:GetCurrentMapID()
        self.instance = registry:GetCurrent()
    end

    local name, instanceType, difficultyID, _, maxPlayers = GetInstanceInfo()
    self.instanceName = name
    self.instanceType = instanceType
    self.difficultyID = difficultyID
    self.maxPlayers = maxPlayers

    self.encounter = nil
    self.encounterActive = false
    self.encounterStartedAt = nil
    self.encounterEndedAt = nil
    self.encounterCompleted = false
    self.encounterEndReason = nil
end

function Guardpoint.State:Refresh()
    self:RefreshPlayer()
    self:RefreshInstance()
    self:SetCombat(UnitAffectingCombat("player"))
end

function Guardpoint.State:SetCombat(active)
    self.inCombat = active and true or false
end

function Guardpoint.State:GetPlayerClass()
    return self.playerClass
end

function Guardpoint.State:IsInCombat()
    return self.inCombat
end

function Guardpoint.State:GetInstance()
    return self.instance
end

function Guardpoint.State:GetMapID()
    return self.mapID
end

function Guardpoint.State:GetInstanceName()
    return self.instanceName
end

function Guardpoint.State:GetInstanceType()
    return self.instanceType
end

function Guardpoint.State:GetDifficultyID()
    return self.difficultyID
end

function Guardpoint.State:GetMaxPlayers()
    return self.maxPlayers
end

function Guardpoint.State:GetEncounter()
    return self.encounter
end

function Guardpoint.State:IsEncounterActive()
    return self.encounterActive
end

function Guardpoint.State:GetEncounterStartedAt()
    return self.encounterStartedAt
end

function Guardpoint.State:GetEncounterEndedAt()
    return self.encounterEndedAt
end

function Guardpoint.State:IsEncounterCompleted()
    return self.encounterCompleted
end

function Guardpoint.State:GetEncounterEndReason()
    return self.encounterEndReason
end

function Guardpoint.State:SetEncounter(encounter)
    self.encounter = encounter
    self.encounterActive = encounter ~= nil
    self.encounterStartedAt = encounter and GetTime() or nil
    self.encounterEndedAt = nil
    self.encounterCompleted = false
    self.encounterEndReason = nil
end

function Guardpoint.State:EndEncounter(reason)
    if not self.encounter or self.encounterEndedAt then
        return
    end

    self.encounterActive = false
    self.encounterEndedAt = GetTime()
    self.encounterCompleted = reason == "KILL"
    self.encounterEndReason = reason
end

function Guardpoint.State:ClearEncounter()
    self.encounter = nil
    self.encounterActive = false
    self.encounterStartedAt = nil
    self.encounterEndedAt = nil
    self.encounterCompleted = false
    self.encounterEndReason = nil
end

function Guardpoint.State:CompleteEncounter()
    self:EndEncounter("KILL")
end
