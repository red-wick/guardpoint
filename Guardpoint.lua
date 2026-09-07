-- Guardpoint bootstrap
-- WoW 3.3.5a / 12340
local NS = _G.Guardpoint

if NS.Runtime and NS.Runtime.initialize then
    NS.Runtime.initialize()
end

if NS.State and NS.State.DB and NS.State.DB.locked == nil then
    NS.State.DB.locked = false
end

DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGuardpoint|r загружен. /guardpoint help")
