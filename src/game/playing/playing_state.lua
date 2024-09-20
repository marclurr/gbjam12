local assets = require("game.assets")
local tweens = require("tweens")
local world = require("game.playing.world")
local logic = require("game.playing.logic")
local render = require("game.playing.render")



local M = {}

function M.enter(mode)
    world.init(assets.tilemaps.levels(), mode)
end

function M.update(dt)
    tweens.update(dt)
    world.update(dt)
    logic.update(dt)
end

function M.draw()
    render.draw()
end

return M