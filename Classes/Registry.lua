Guardpoint.Classes = Guardpoint.Classes or {}
Guardpoint.Classes.Registry = Guardpoint.Classes.Registry or {}

local Registry = Guardpoint.Classes.Registry

function Registry:Register(classToken, classData)
    if type(classToken) ~= "string" or type(classData) ~= "table" then
        return
    end

    self[classToken] = classData
end

function Registry:Get(classToken)
    return self[classToken]
end

function Registry:GetPlayerClass()
    local classToken = select(2, UnitClass("player"))
    return self:Get(classToken)
end
