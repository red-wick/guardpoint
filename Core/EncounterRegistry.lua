-- Guardpoint encounter registry
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

NS.EncounterRegistry = NS.EncounterRegistry or {}
local E = NS.EncounterRegistry
E.modules = E.modules or {}
E.active = E.active or nil

function E:Register(id, module)
    if not id or not module then return end
    self.modules[id] = module
end

function E:Get(id)
    return self.modules[id]
end

function E:GetByMap(mapID)
    if not mapID then return nil end
    for _, module in pairs(self.modules) do
        if module.MapID == mapID then return module end
    end
end

function E:Select(mapID)
    self.active = self:GetByMap(mapID)
    return self.active
end

function E:GetActive()
    return self.active
end

function E:Detect()
    local mapID = GetCurrentMapAreaID and GetCurrentMapAreaID()
    return self:Select(mapID)
end
