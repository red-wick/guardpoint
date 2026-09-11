Guardpoint.Scheduler = Guardpoint.Scheduler or {}

local Scheduler = Guardpoint.Scheduler
local nextID = 0
local tasks = {}

function Scheduler:Schedule(delay, callback, group)
    if type(delay) ~= "number" or delay < 0 or type(callback) ~= "function" then
        return nil
    end

    nextID = nextID + 1

    tasks[nextID] = {
        runAt = GetTime() + delay,
        callback = callback,
        group = group,
    }

    return nextID
end

function Scheduler:ScheduleRepeating(interval, callback, group)
    if type(interval) ~= "number" or interval <= 0 or type(callback) ~= "function" then
        return nil
    end

    nextID = nextID + 1

    tasks[nextID] = {
        runAt = GetTime() + interval,
        interval = interval,
        callback = callback,
        group = group,
    }

    return nextID
end

function Scheduler:Cancel(taskID)
    if type(taskID) ~= "number" then
        return
    end

    tasks[taskID] = nil
end

function Scheduler:IsScheduled(taskID)
    return type(taskID) == "number" and tasks[taskID] ~= nil
end

function Scheduler:CancelGroup(group)
    if group == nil then
        return
    end

    for taskID, task in pairs(tasks) do
        if task.group == group then
            tasks[taskID] = nil
        end
    end
end

function Scheduler:RunDue(now)
    now = now or GetTime()

    local dueTasks = {}

    for taskID, task in pairs(tasks) do
        if now >= task.runAt then
            table.insert(dueTasks, taskID)
        end
    end

    for _, taskID in ipairs(dueTasks) do
        local task = tasks[taskID]

        if task and now >= task.runAt then
            if task.interval then
                task.runAt = task.runAt + task.interval
                task.callback()
            else
                tasks[taskID] = nil
                task.callback()
            end
        end
    end
end

function Scheduler:Clear()
    tasks = {}
end
