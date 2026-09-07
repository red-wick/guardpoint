-- Guardpoint class selection
local NS = _G.Guardpoint

NS.Class = NS.Class or {}
local C = NS.Class

function C.refresh()
    local _, class = UnitClass("player")
    if class == "DEATHKNIGHT" and NS.BloodDK then
        NS.ActiveClass = NS.BloodDK
    else
        NS.ActiveClass = nil
    end
    return NS.ActiveClass
end

function C.get()
    return NS.ActiveClass or C.refresh()
end
