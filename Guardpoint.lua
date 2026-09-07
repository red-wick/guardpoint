-- Guardpoint bootstrap
-- WoW 3.3.5a / 12340

local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

local S = NS.State and NS.State.data
local R = NS.Resources
local X = NS.Runtime

if S and S.DB and S.DB.locked == nil then
    S.DB.locked = false
end

if R and R.ConfigureActiveClass then
    R.ConfigureActiveClass()
end

if X and X.ConfigureEncounter then
    X.ConfigureEncounter()
end

if X and X.initialize then
    X.initialize()
end

DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGuardpoint|r загружен. /guardpoint help")
