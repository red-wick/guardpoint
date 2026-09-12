Guardpoint = Guardpoint or {}

Guardpoint.Core = Guardpoint.Core or {}
Guardpoint.Runtime = Guardpoint.Runtime or {}
Guardpoint.UI = Guardpoint.UI or {}
Guardpoint.Data = Guardpoint.Data or {}
Guardpoint.Classes = Guardpoint.Classes or {}
Guardpoint.Encounters = Guardpoint.Encounters or {}
Guardpoint.Config = Guardpoint.Config or {}

function Guardpoint:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGuardPoint|r: " .. tostring(message))
end
