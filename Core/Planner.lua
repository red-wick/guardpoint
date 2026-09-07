-- Guardpoint planner dispatcher
local NS = _G.Guardpoint

NS.Planner = NS.Planner or {}
local P = NS.Planner

function P.getClassPlanner()
    local class = NS.Class and NS.Class.get and NS.Class.get() or NS.ActiveClass
    return class and class.Planner or nil
end

function P.buildPlan(phase,number,deadline)
    local planner=P.getClassPlanner()
    if planner and planner.buildPlan then
        return planner.buildPlan(phase,number,deadline)
    end
    return {},{},nil
end
