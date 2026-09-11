Guardpoint.Scheduler = Guardpoint.Scheduler or {}

local Scheduler = Guardpoint.Scheduler
local nextID = 0
local tasks = {}

function Scheduler:Schedule(delay, callback)
    if type(delay) ~= "number" or delay < 0 or type(callback) ~= "function" then
        return nil
    end

    nextID = nextID + 1

    tasks[nextID] = {
        runAt = GetTime() + delay,
        callback = callback,
    }

    return nextID
end

function Scheduler:ScheduleRepeating(interval, callback)
    if type(interval) ~= "number" or interval <= 0 or type(callback) ~= "function" then
        return nil
    end

    nextID = nextID + 1

    tasks[nextID] = {
        runAt = GetTime() + interval,
        interval = interval,
        callback = callback,
    }

    return nextID
end

function Scheduler:Cancel(taskID)
    if type(taskID) ~= "number" then
        return
    end

    tasks[taskID] = nil
end

function Scheduler:RunDue(now)
    now = now or GetTime()

    for taskID, task in pairs(tasks) do
        if now >= task.runAt then
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
