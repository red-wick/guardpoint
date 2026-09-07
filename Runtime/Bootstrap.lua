-- Guardpoint modular activation bridge
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

-- Guardpoint.lua still owns the legacy frame while we migrate by subsystem.
-- Hide its UI before the modular UI creates its own frame.
if _G.GP_Main then
    _G.GP_Main:Hide()
end

if NS.Runtime and NS.Runtime.initialize then
    NS.Runtime.initialize()
end

if NS.Runtime and NS.Runtime.RegisterCommands then
    NS.Runtime.RegisterCommands()
end

DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGuardpoint|r modular runtime active")
