local assets = require("game.assets")

local tweens = require("tweens")
local gfx = require("graphics")
local print2 = require("print2")
local tilemap = require("tilemap")

local world = require("game.playing.world")
local player_control = require("game.playing.player_control")
local arm_control = require("game.playing.arm_control")
local enemy = require("game.playing.enemy")
local hud = require("game.playing.hud")

local M = {}



function M.draw()
    gfx.cls(0)

    if world.gameover or world.win then
        local pal = pals[math.floor(world.gameover_fadein) + 1]
        for i = 1, #pal do
            gfx.pal(i - 1, pal[i])
        end
        gfx.disable_pals = true
    end



    love.graphics.push()
    love.graphics.translate(-world.camera.x, -world.camera.y)


    gfx.palt(0)

    tilemap.draw_layer(world.map, "background")
    gfx.palt()
    tilemap.draw_layer(world.map, "foreground")

    gfx.palt(0)

    for i = 1, #world.entities do
        local entity = world.entities[i]
        if entity.type == COL_ENEMY then
            enemy.draw(entity)
        else
            if entity.draw then
                entity.draw(entity, world)
            else
                if entity.visible == nil or entity.visible == true then
                    gfx.draw_sprite(entity.sprite, entity.x - entity.cx, entity.y - entity.cy)
                end
            end
        end

        -- gfx.rectangle("line", entity.x, entity.y, entity.cwidth, entity.cheight, 3)
    end


    for i = 1, #world.player_arms do
        arm_control.draw(world.player_arms[i])
        -- local arm = world.player_arms[i]
        -- gfx.draw_sprite(assets.sprites.hand_1, arm.x, arm.y)
        -- gfx.rectangle("line", arm.x, arm.y, arm.cwidth, arm.cheight, 3)
    end

    player_control.draw(world.player)


    love.graphics.pop()
    hud.draw()

    gfx.disable_pals = false
    gfx.pal()

    if world.gameover then

        gfx.pal(3, math.floor(world.gameover_fadein))
        print2("GAME OVER", 44, 64)
        gfx.pal()
    end

    if world.win then
        gfx.pal(3, math.floor(world.gameover_fadein))
        print2("you won!", 44, 64)
        gfx.pal()
    end

end

return M