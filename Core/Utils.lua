Guardpoint.Utils = Guardpoint.Utils or {}

local Utils = Guardpoint.Utils

function Utils.IsNumber(value)
    return type(value) == "number"
end

function Utils.IsString(value)
    return type(value) == "string"
end

function Utils.IsTable(value)
    return type(value) == "table"
end

function Utils.IsFunction(value)
    return type(value) == "function"
end
