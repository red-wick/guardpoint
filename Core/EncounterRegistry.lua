-- Guardpoint encounter registry
-- Keeps encounter modules isolated from the runtime core.
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

NS.EncounterRegistry = NS.EncounterRegistry or {}
local R = NS.EncounterRegistry

R.Modules = R.Modules or {}
R.Active = R.Active or nil

function R:Register(id, module)
    if not id or not module then return end
    self.Modules[id] = module
end

function R:Get(id)
    return id and self.Modules[id] or nil
end

function R:GetByMap(mapID)
    if not mapID then return nil end

    for _, module in pairs(self.Modules) do
        if module.MapID == mapID then
            return module
        end
    end
end

function R:Select(mapID)
    self.Active = self:GetByMap(mapID)
    return self.Active
end

function R:GetActive()
    return self.Active
end

function R:Detect()
    if not GetCurrentMapAreaID then return nil end
    return self:Select(GetCurrentMapAreaID())
end

function R:Resolve()
    return self:GetActive() or self:Detect()
end
