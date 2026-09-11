local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "Guardpoint" then
            Guardpoint.Config:Initialize()
            Guardpoint.UI.Panel:ApplyScale()
            Guardpoint.UI.Panel:ApplyPosition()
        end
    elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        Guardpoint.State:RefreshPlayer()
        Guardpoint.State:RefreshInstance()
        Guardpoint.EventBus:Fire(event, ...)
    elseif event == "PLAYER_REGEN_DISABLED" then
        Guardpoint.State:SetCombat(true)
        Guardpoint.EventBus:Fire("COMBAT_START", ...)
    elseif event == "PLAYER_REGEN_ENABLED" then
        Guardpoint.State:SetCombat(false)
        Guardpoint.EventBus:Fire("COMBAT_END", ...)
        Guardpoint.Scheduler:CancelGroup("encounter")
    end
end)
