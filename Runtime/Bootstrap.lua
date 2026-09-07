-- Guardpoint modular activation bridge
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

local function activate()
    if NS.Runtime and NS.Runtime.initialize then
        NS.Runtime.initialize()
    end
    if NS.Runtime and NS.Runtime.RegisterCommands then
        NS.Runtime.RegisterCommands()
    end
end

-- Guardpoint.lua is still the legacy implementation at this stage.
-- We let it finish creating its frames, then replace only the runtime frame.
activate()
