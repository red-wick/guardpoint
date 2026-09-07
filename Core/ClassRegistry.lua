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

    local specToken
    local tree = GetPrimaryTalentTree and GetPrimaryTalentTree(false, false)
    if tree then
        for _, module in pairs(self.Modules) do
            if module.Class == classToken and module.SpecTree == tree then
                specToken = module.Spec
                break
            end
        end
    end

    if specToken then
        return self:Select(classToken, specToken)
    end

    local module = self:Get(classToken)
    if module then
        self.Active = module
        return module
    end

    self.Active = nil
    return nil
end

function R:Resolve()
    return self:GetActive() or self:Detect()
end
