Guardpoint.EventBus = Guardpoint.EventBus or {}

local listeners = {}

function Guardpoint.EventBus:Register(event, callback)
    if type(callback) ~= "function" then
        return
    end

    listeners[event] = listeners[event] or {}
    table.insert(listeners[event], callback)
end

function Guardpoint.EventBus:Fire(event, ...)
    local eventListeners = listeners[event]
    if not eventListeners then
        return
    end

    for _, callback in ipairs(eventListeners) do
        callback(...)
    end
end
