local gfx = require("graphics")
local tweens = require("tweens")
local assets = require("game.assets")
local gamestate = require("gamestate")

local frames = {
    {0, 0, 0, 0},
    {0, 1, 1, 1},
    {0, 1, 2, 2},
    {0, 1, 2, 3},
    {0, 1, 2, 3},
    {0, 1, 2, 3},
    {0, 1, 2, 3},
    {0, 1, 2, 3},
    {0, 1, 2, 2},
    {0, 1, 1, 1},
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 0, 0, 0},

}

local M = {}

function M.enter()
    M.frame = 0
    gfx.pal(0, 0)
    gfx.pal(1, 0)
    gfx.pal(2, 0)
    gfx.pal(3, 0)

    tweens.new_tween(M, "frame", 0, #frames - 1, 5).on_complete = function()
        gamestate.switch(TitleState)
    end
end

function M.update(dt)
    tweens.update(dt)
end

function M.draw()
    gfx.cls()

    local pal = frames[math.floor(M.frame) + 1]
    for i = 1, #pal do
        gfx.pal(i - 1, pal[i])
    end

    gfx.draw(assets.textures.splash)
end

return M