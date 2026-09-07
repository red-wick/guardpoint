-- Guardpoint bootstrap
-- WoW 3.3.5a / 12340

local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

if NS.Runtime and NS.Runtime.initialize then
    NS.Runtime.initialize()
end
