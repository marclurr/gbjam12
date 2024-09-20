local atlas = require("textureatlas")
local assets = require("game.assets")
local gfx = require("graphics")
local world = require("game.playing.world")



local M = {}

function M.draw()
    gfx.rectangle("fill", 0, 0, WIDTH, 8, 0)

    -- hp
    for i = 0, 2 do
        local x = i * 10
        local spr = assets.sprites.heart_full
        if world.player_lives < (i + 1) then spr = assets.sprites.heart_empty end

        gfx.draw_sprite(spr, x + 1, 0)
    end


    -- score
    local score = string.format("%06d", world.player_score)
    local font = assets.atlases.debug_atlas
    for i = 1, #score do
        local digit = tonumber(score:sub(i, i))

        local x = (7 + (i - 1)) * 8

        atlas.draw(font, digit + 23, x, 0)
    end
end

return M