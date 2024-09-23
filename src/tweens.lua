local tweens = {}

local M = {}

function M.new_tween(obj, field, start_val, end_val, duration)
    local t = {}
    t.object = obj
    t.field = field
    t.start_value = start_val
    t.end_value = end_val
    t.duration = duration
    t.t = 0

    table.insert(tweens, t)
    return t
end

function M.get_count()
    return #tweens
end

function M.update(dt)
    for i = #tweens, 1, -1 do
        local t = tweens[i]
        t.t = t.t + dt
        local x = t.t / t.duration
        if x > 1 then
            x = 1
            if type(t.field) == "function" then
                t.field(t.object,  t.end_value)
            else
                t.object[t.field] = t.end_value
            end
            if t.on_complete then t.on_complete() end
            table.remove(tweens, i)
        else
            if type(t.field) == "function" then
                t.field(t.object,  math.lerp(t.start_value, t.end_value, x))
            else
                t.object[t.field] = math.lerp(t.start_value, t.end_value, x)
            end
        end
    end
end

return M