-- Guardpoint utility functions
local _, NS = ...
local S = NS.State.data

NS.Util = NS.Util or {}
local U = NS.Util

function U.now() return GetTime() end
function U.lower(s) return string.lower(s or "") end
function U.copy(a)
    if not a then return nil end
    local b = {}
    for k,v in pairs(a) do b[k] = v end
    return b
end
function U.key(a) return a and (a.kind..":"..tostring(a.id)) or "" end
function U.same(a,b) return a and b and U.key(a)==U.key(b) end
function U.has(list,a)
    if not a then return false end
    local k=U.key(a)
    for i=1,#list do if U.key(list[i])==k then return true end end
    return false
end
function U.add(list,a)
    if a and not U.has(list,a) then list[#list+1]=U.copy(a) end
end
function U.isUsed(a) return a and S.used[U.key(a)] end
