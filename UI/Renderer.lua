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

    local lines = {}

    if state.playerClass then
        table.insert(lines, "Class: " .. state.playerClass)
    end

    if state.instance then
        table.insert(lines, "Instance: " .. (state.instance.name or "Unknown"))
    end

    if state.encounter then
        table.insert(lines, "Encounter: " .. (state.encounter.name or "Unknown"))
    end

    if #lines == 0 then
        table.insert(lines, "Ready")
    end

    panel:SetStatus(table.concat(lines, "\n"))
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
