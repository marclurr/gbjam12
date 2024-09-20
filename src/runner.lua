---@diagnostic disable: redundant-parameter

local ALPHA = 0.0002

local TIMESTEP_120HZ = 1 / 120
local TIMESTEP_60HZ = 1 / 60
local TIMESTEP_30HZ = 1 / 30

function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local dt = 0

    local timestep = 1 / 60
    local dt_accum = 0
    local fuzzy_timer_enabled = false
    local frames = 0

    function SetFuzzyTimerEnabled(b)
        fuzzy_timer_enabled = b
    end

    function ResetGametimer()
        dt_accum = 0
    end

    -- Main loop time.
    return function()
        -- Process events.
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end


        dt = love.timer.step()

        if fuzzy_timer_enabled then
            if math.abs(dt - TIMESTEP_120HZ) < ALPHA then
                dt = TIMESTEP_120HZ
            end
            if math.abs(dt - TIMESTEP_60HZ) < ALPHA then
                dt = TIMESTEP_60HZ
            end
            if math.abs(dt - TIMESTEP_30HZ) < ALPHA then
                dt = TIMESTEP_30HZ
            end
        end

        dt_accum = dt_accum + dt
        local count = 0
        while dt_accum > timestep do
            love.update(timestep)
            dt_accum = dt_accum - timestep
            count = count + 1
        end

        love.graphics.origin()
        love.graphics.clear(love.graphics.getBackgroundColor())
        love.draw()
        love.graphics.present()


        love.timer.sleep(0.001)
    end
end
