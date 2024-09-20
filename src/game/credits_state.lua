local assets = require("game.assets")
local config = require("config")
local gfx = require("graphics")
local sfx = require("sfx")
local input = require("input")
local print2 = require("print2")
local gamestate = require("gamestate")
local tweens = require("tweens")

local function print_centre(text, y, col)
    local x = WIDTH / 2 - (#text / 2) * 8
    print2(text, x, y, col)
end

local M = {}

function M.enter()
    M.palette = 0
    gfx.set_palette(4)
end

function M.update(dt)
    tweens.update(dt)
    if (input.is_just_pressed("start") or input.is_just_pressed("a") or input.is_just_pressed("b")) then
        tweens.new_tween(M, "palette", 0, 4, 1).on_complete = function()
            gamestate.switch(TitleState)
            gfx.set_palette(config.values.palette)
        end
    end
end

function M.draw()
    gfx.cls()

    local pal = pals[math.floor(M.palette) + 1]
    for i = 1, #pal do
        gfx.pal(i - 1, pal[i])
    end

    print_centre("code/art/audio", 20)
    print_centre("--------------", 26)

    print_centre("marclurr", 40)
    -- love.graphics.line()
    -- print_centre("--------------", 30)
    -- print_centre("audio     marclurr", )
    local lv = 90
    print_centre("made with", lv)
    gfx.draw(assets.textures.love_logo, 64, lv + 10)

    gfx.pal()
end

return M