Guardpoint.EventBus = Guardpoint.EventBus or {}

local listeners = {}

function Guardpoint.EventBus:Register(event, callback)
    if type(event) ~= "string" or type(callback) ~= "function" then
        return
    end

    listeners[event] = listeners[event] or {}
    table.insert(listeners[event], callback)
end

function Guardpoint.EventBus:Unregister(event, callback)
    local eventListeners = listeners[event]
    if not eventListeners or type(callback) ~= "function" then
        return
    end

    for index = table.getn(eventListeners), 1, -1 do
        if eventListeners[index] == callback then
            table.remove(eventListeners, index)
        end
    end

    if table.getn(eventListeners) == 0 then
        listeners[event] = nil
    end
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
