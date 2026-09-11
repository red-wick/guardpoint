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

    local text = "Ready"

    if state.playerClass then
        text = "Class: " .. state.playerClass
    end

    if state.instance then
        text = text .. "\nInstance: " .. (state.instance.name or "Unknown")
    end

    if state.encounter then
        text = text .. "\nEncounter: " .. (state.encounter.name or "Unknown")
    end

    panel:SetStatus(text)
    return true
end
