local assets = require("game.assets")
local input = require("input")
local gfx = require("graphics")
local sfx = require("sfx")
local gamestate = require("gamestate")
local animator = require("animator")

local world = require("game.playing.world")
local player_control = require("game.playing.player_control")
local arm_control = require("game.playing.arm_control")
local enemy = require("game.playing.enemy")
local objects = require("game.playing.objects")

local M = {}

function M.update(dt)
    if not world.ready then return end


    local player = world.player
    local arms = world.player_arms
    local entities = world.entities

    if world.gameover_fadein == 3 and (input.is_just_pressed("a") or input.is_just_pressed("b") or input.is_just_pressed("start")) then
        gamestate.switch(TitleState, MODE_ARCADE)
        return
    end

    if world.enemy_count() == 0 and world.pickup_count() == 0 then
        world.next_level()
        return
    end

    local old_y = player.y
    player_control.update(dt, player)

    local new_room = world.get_room(player.x + player.cwidth / 2, player.y + (old_y < player.y and player.cheight or 0))

    for i = #arms, 1, -1 do
        arm_control.update(dt, arms[i])
        if arms[i].destroy then
            world.arm_collected(arms[i])
        end
    end

    local bump = world.bump_world

    local px, py, pw, ph = bump:getRect(player)
    local pcx, pcy = px + pw / 2, py + ph / 2


    for i = #entities, 1, -1 do
        local entity = entities[i]

        animator.update(dt, entity)
        if not entity.destroy then
            if  entity.type == COL_ENEMY then
                if entity.dead then
                    enemy.death_bounce(dt, entity)
                else
                    enemy.update(dt, entity)

                    if enemy.is_stunned(entity) then
                        entity.stunned.t = math.max(0, entity.stunned.t - dt)
                        animator.update(dt, entity.stunned)
                    elseif enemy.dead then


                    else

                        local ex, ey, ew, eh = bump:getRect(entity)
                        local ecx, ecy = ex + ew / 2, ey + eh / 2
                        if math.rects_overlap(px, py, pw, ph, ex, ey, ew, eh) and not enemy.is_stunned(entity)  then
                            player_control.take_damage(player, 1, math.sign(pcx - ecx))
                        end
                    end
                end

            elseif entity.type == COL_PICKUP then
                if not entity.no_collect then
                    entity.age = entity.age + dt

                    if entity.age > 5 then
                        if GlobalT % 5 == 0 then entity.visible = not entity.visible end
                    end

                    if entity.age > 8 then
                        entity.no_collect = true
                        animator.play(entity, assets.animations.spark)
                    else
                        local ex, ey, ew, eh = bump:getRect(entity)
                        if math.rects_overlap(px, py, pw, ph, ex, ey, ew, eh) then
                            world.player_score = world.player_score + 300
                            animator.play(entity, assets.animations.spark)
                            entity.no_collect = true
                        end
                    end
                else
                    entity.destroy = entity.animation_frame == #entity.animation.frames
                end
            end
        else
            world.remove_entity_by_id(i)
            if entity.type == COL_ENEMY then
                world.add_entity(objects.make("pumpkin", entity.x, (entity.y + entity.cheight) - 15 ))
            end
        end
    end

end

return M