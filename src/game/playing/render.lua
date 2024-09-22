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



local function print_centre(text, y, col)
    local x = WIDTH / 2 - (#text / 2) * 8
    print2(text, x, y, col)
end

local function draw_tile_collision()
    local bump = world.bump_world
    gfx.disable_shader()
    local items, len = bump:getItems()

    for i = 1, len do
        local item = items[i]
        if item.type == COL_SOLID then
            love.graphics.setColor(1, 0, 0, 0.5)
            love.graphics.rectangle("fill", item.x, item.y,  8, 8)
        elseif item.type == COL_ONEWAY then
            love.graphics.setColor(1, 0, 1, 0.5)
            love.graphics.rectangle("fill", item.x, item.y,  8, 4)
        elseif item.type == COL_ROPE then
            love.graphics.setColor(1, 1, 0, 0.5)
            love.graphics.rectangle("fill", item.x, item.y,  4, 8)
        end
    end
    gfx.enable_shader()
end

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

    draw_tile_collision()

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
        print_centre("GAME OVER", 64)
        gfx.pal()
    end

    if world.win then
        gfx.pal(3, math.floor(world.gameover_fadein))
        print_centre("you won!", 48)
        print_centre("thanks for playing", 72)
        gfx.pal()
    end

end

return M