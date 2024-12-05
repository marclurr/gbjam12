local input = require("input")
local gamestate = require("gamestate")
local print2 = require("print2")
local sfx = require("sfx")

local function print_centre(text, y, col)
    local x = WIDTH / 2 - (#text / 2) * 8
    print2(text, x, y, col)
end

local M = {}

function M.enter()
    love.timer.sleep(1 / 30)
    sfx("menu_accept")
end

function M.exit()
    sfx("menu_accept")
end

function M.update()
    if input.is_just_pressed("start") then
        gamestate.pop()
    end
end

function M.draw()
    print_centre("paused", 64)
end

return M