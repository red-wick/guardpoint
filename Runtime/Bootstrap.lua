-- Guardpoint modular activation bridge
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

-- During migration the legacy file creates GP_Main/GP_Events.
-- Keep the legacy UI visible until the modular runtime proves that its
-- own frame is alive. The modular runtime owns events only.
if NS.Runtime and NS.Runtime.initialize then
    NS.Runtime.initialize()
end

if NS.Runtime and NS.Runtime.RegisterCommands then
    NS.Runtime.RegisterCommands()
end

DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGuardpoint|r modular runtime active")
