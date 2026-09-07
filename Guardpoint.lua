-- Guardpoint addon bootstrap
-- WoW 3.3.5a / 12340

local ADDON = ...
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

-- Core modules are loaded before this file from Guardpoint.toc.
-- Runtime owns encounter events; Commands owns slash commands; UI owns the frame.
if NS.State and NS.State.DB and NS.State.DB.locked == nil then
    NS.State.DB.locked = false
end

if NS.Runtime and NS.Runtime.initialize then
    NS.Runtime.initialize()
end

DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGuardpoint|r загружен. /guardpoint help")
