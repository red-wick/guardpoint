local _, ns = ...

ns.LichKing = ns.LichKing or {}

-- Keeps the prescribed Soul Reaper order separate from the UI and combat-log
-- handling. The caller supplies currently available buttons, so cooldown and
-- inventory checks remain in the main addon.
ns.LichKing.SoulReaper = {
    BuildPlan = function(api, phase, n, deadline)
        local before = {}
        local after = {}
        local pair = nil

        if phase == 2 then
            if n == 1 or n == 3 or n == 5 or n == 7 then
                pair = api.chooseCorePair(deadline)
                for i = 1, #pair do api.add(before, pair[i]) end
                while #before < 2 do
                    local action = api.choosePreFallback(deadline, before)
                    if not action then break end
                    api.add(before, action)
                end
                api.add(after, api.chooseSolo(api.SPELL.AMS, deadline, before))
            elseif n == 2 or n == 6 then
                local action = api.chooseSolo(api.SPELL.IBF, deadline, before)
                api.add(before, action)
                api.add(after, action)
            elseif n == 4 then
                api.add(before, api.chooseRemainingCore(deadline))
                api.add(before, api.chooseTrinket(deadline, before))
                api.add(after, api.chooseSolo(api.SPELL.ARMY, deadline, before))
            elseif n == 8 then
                api.add(before, api.chooseRemainingCore(deadline))
                api.add(after, api.chooseSolo(api.SPELL.PAIN, deadline, before))
            end
        elseif phase == 3 then
            if n == 1 then
                pair = api.chooseCorePair(deadline)
                for i = 1, #pair do api.add(before, pair[i]) end
                while #before < 2 do
                    local action = api.choosePreFallback(deadline, before)
                    if not action then break end
                    api.add(before, action)
                end
                api.add(after, api.chooseSolo(api.SPELL.IBF, deadline, before))
            elseif n == 2 then
                api.add(before, api.chooseRemainingCore(deadline))
                api.add(before, api.chooseTrinket(deadline, before))
                api.add(after, api.chooseSolo(api.SPELL.AMS, deadline, before))
            elseif n == 3 or n == 5 or n == 8 then
                pair = api.chooseCorePair(deadline)
                for i = 1, #pair do api.add(before, pair[i]) end
                while #before < 2 do
                    local action = api.choosePreFallback(deadline, before)
                    if not action then break end
                    api.add(before, action)
                end
                api.add(after, api.chooseSolo(api.SPELL.AMS, deadline, before))
            elseif n == 4 or n == 7 then
                local action = api.chooseSolo(api.SPELL.IBF, deadline, before)
                api.add(before, action)
                api.add(after, action)
            elseif n == 6 then
                api.add(before, api.chooseRemainingCore(deadline))
                api.add(after, api.chooseSolo(api.SPELL.PAIN, deadline, before))
            end
        end

        return before, after, pair
    end,
}
