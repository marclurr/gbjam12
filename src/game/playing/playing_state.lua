local input = require("input")
local gamestate = require("gamestate")
local audio = require("audio")
local assets = require("game.assets")
local music = require("music")
local tweens = require("tweens")
local world = require("game.playing.world")
local logic = require("game.playing.logic")
local render = require("game.playing.render")



local M = {}

function M.enter(mode)
    world.init(assets.tilemaps.levels(), mode)
    music.play(assets.music.bgmusic)
end

function M.pause()
    audio.pause_all()
end

function M.resume()
    audio.resume_all()
end

function M.exit()
    music.stop()
end

function M.update(dt)
    if input.is_just_pressed("start") then
        return gamestate.push(PausedState)
    end

    if world.paused then return end
    tweens.update(dt)
    world.update(dt)
    logic.update(dt)
end

function M.draw()
    render.draw()
end

return M