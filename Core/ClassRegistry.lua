-- Guardpoint class registry
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

NS.ClassRegistry = NS.ClassRegistry or {}
local C = NS.ClassRegistry
C.modules = C.modules or {}
C.active = C.active or nil

function C:Register(classToken, specToken, module)
    if not classToken or not module then return end
    self.modules[classToken] = self.modules[classToken] or {}
    self.modules[classToken][specToken or "*"] = module
end

function C:Get(classToken, specToken)
    local byClass = self.modules[classToken]
    if not byClass then return nil end
    return byClass[specToken] or byClass["*"]
end

function C:Select(classToken, specToken)
    self.active = self:Get(classToken, specToken)
    return self.active
end

function C:GetActive()
    return self.active
end

function C:Detect()
    local _, classToken = UnitClass("player")
    if not classToken then return nil end
    return self:Select(classToken)
end
