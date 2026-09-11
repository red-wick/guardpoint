Guardpoint.Config = Guardpoint.Config or {}

local Config = Guardpoint.Config

function Config:Initialize()
    GuardpointDB = GuardpointDB or {}

    for key, defaultValue in pairs(self.Defaults) do
        if key ~= "position" and GuardpointDB[key] == nil then
            GuardpointDB[key] = defaultValue
        end
    end

    local position = GuardpointDB.position
    if type(position) ~= "table" then
        position = {}
        GuardpointDB.position = position
    end

    position.point = position.point or self.Defaults.position.point
    position.relativePoint = position.relativePoint or self.Defaults.position.relativePoint
    position.x = tonumber(position.x) or self.Defaults.position.x
    position.y = tonumber(position.y) or self.Defaults.position.y

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

function Config:GetPosition()
    if not self.values then
        return nil
    end

    local position = self.values.position
    if type(position) ~= "table" then
        return nil
    end

    return position
end

function Config:SetPosition(point, relativePoint, x, y)
    if not self.values then
        return false
    end

    self.values.position = {
        point = point or "CENTER",
        relativePoint = relativePoint or "CENTER",
        x = tonumber(x) or 0,
        y = tonumber(y) or 0,
    }

    return true
end
