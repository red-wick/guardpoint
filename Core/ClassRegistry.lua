-- Guardpoint class/spec registry
-- Keeps class modules isolated from the runtime core.
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

NS.ClassRegistry = NS.ClassRegistry or {}
local R = NS.ClassRegistry

R.Modules = R.Modules or {}
R.Active = R.Active or nil

function R:Register(classToken, specToken, module)
    if not classToken or not module then return end

    local key = classToken .. ":" .. (specToken or "*")
    self.Modules[key] = module
end

function R:Get(classToken, specToken)
    if not classToken then return nil end

    local exact = self.Modules[classToken .. ":" .. (specToken or "*")]
    if exact then return exact end

    return self.Modules[classToken .. ":*"]
end

function R:Select(classToken, specToken)
    self.Active = self:Get(classToken, specToken)
    return self.Active
end

function R:GetActive()
    return self.Active
end

function R:Detect()
    if not UnitClass then return nil end

    local classToken = select(2, UnitClass("player"))
    if not classToken then return nil end

    local module = self:Get(classToken)
    if module then
        self.Active = module
        return module
    end

    local prefix = classToken .. ":"
    for key, candidate in pairs(self.Modules) do
        if string.sub(key, 1, string.len(prefix)) == prefix then
            self.Active = candidate
            return candidate
        end
    end

    self.Active = nil
    return nil
end
