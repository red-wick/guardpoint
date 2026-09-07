-- Guardpoint state
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

NS.State = NS.State or {}
local S = NS.State

S.DB = GuardpointDB or {}
GuardpointDB = S.DB

S.data = S.data or {
    phase = 1, reaper = 0, nextAt = nil, nextNumber = 1,
    active = false, expire = 0, plan = nil, used = {}, corePair = nil,
    lastApplied = 0, test = false, t10Override = nil,
    encounter = false, encounterGUID = nil, encounterStart = 0,
}
