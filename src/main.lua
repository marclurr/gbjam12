debug = true
require("runner")
require("const")

local gfx = require("graphics")
local sfx = require("sfx")
local input = require("input")
local textureatlas = require("textureatlas")
local tilemap = require("tilemap")
local gamestate = require("gamestate")

TitleState = require("game.title.title_state")
OptionsState = require("game.options_state")
CreditsState = require("game.credits_state")
PlayingState = require("game.playing.playing_state")

gamestate.push(TitleState)

gfx.set_palette(3)

tex = LoadImg("data/gfx/splash")
smile = LoadImg("data/gfx/smile")
debug = LoadImg("data/gfx/debug")

debug_atlas = textureatlas.new(debug, 8, 8)

debug_map = tilemap.load("data/tilemaps/debug.lua", debug_atlas)

music = love.audio.newSource("data/music/test.wav", "stream")

pals = {
    {0,1,2,3},
    {1,1,2,3},
    {2,2,2,3},
    {3,3,3,3},
}

pals = {
    {0,1,2,3},
    {0,1,2,2},
    {0,1,1,1},
    {0,0,0,0},
    {0,0,0,0},
}

i = 1

gfx.palt(0)

function love.load()

end

x = 0

GlobalT = 0

function love.update(dt)
    if input.is_pressed("a") and input.is_pressed("b") and input.is_pressed("start") and input.is_pressed("select") then
        GlobalT = 0
        gamestate.switch(TitleState, MODE_ARCADE)
    else
        GlobalT = GlobalT + 1
        gamestate.update(dt)
        input.update()
    end
end

function love.draw()

    gfx.begin()
    love.graphics.clear(1, 0, 0, 1)

    gamestate.draw()

    gfx.finish()
end