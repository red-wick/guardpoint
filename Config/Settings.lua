Guardpoint.Config = Guardpoint.Config or {}

local Config = Guardpoint.Config

function Config:Initialize()
    GuardpointDB = GuardpointDB or {}

    for key, defaultValue in pairs(self.Defaults) do
        if GuardpointDB[key] == nil then
            GuardpointDB[key] = defaultValue
        end
    end

    self.values = GuardpointDB
end

function Config:Get(key)
    if not self.values then
        return nil
    end

    return self.values[key]
end

function Config:Set(key, value)
    if not self.values or self.Defaults[key] == nil then
        return false
    end

    self.values[key] = value
    return true
end

Config:Initialize()
