Guardpoint.UI = Guardpoint.UI or {}

local UI = Guardpoint.UI

UI.Renderer = UI.Renderer or {}
local Renderer = UI.Renderer

function Renderer:Refresh()
    local panel = UI.Panel
    if not panel then
        return false
    end

    local state = Guardpoint.State
    if not state then
        return false
    end

    panel:SetTitle("GuardPoint")
    panel:SetStatus("Ready")
    return true
end

Guardpoint.EventBus:Register("PLAYER_LOGIN", function()
    Renderer:Refresh()
end)

Guardpoint.EventBus:Register("PLAYER_ENTERING_WORLD", function()
    Renderer:Refresh()
end)

Guardpoint.EventBus:Register("COMBAT_START", function()
    Renderer:Refresh()
end)

Guardpoint.EventBus:Register("COMBAT_END", function()
    Renderer:Refresh()
end)
