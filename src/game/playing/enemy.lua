local assets = require("game.assets")
local gfx = require("graphics")

local world = require("game.playing.world")

local M = {}

local updaters = {}
updaters.ghost = function (dt, enemy)
    local player = world.player
    local bump = world.bump_world
    if M.is_stunned(enemy) then
        enemy.dx = 0
        enemy.dy = 16

    else

        local dx, dy = math.norm(player.x - enemy.x, player.y - enemy.y)
        enemy.dx = enemy.dx + dx * 16 * dt
        enemy.dy = enemy.dy + dy * 16 * dt
        if math.length(enemy.dx, enemy.dy) > 16 then
            local nx, ny = math.norm(enemy.dx, enemy.dy)
            enemy.dx = nx * 16
            enemy.dy = ny * 16
        end
    end

    local room = world.current_room
    local goal_x = math.max(room.x * WIDTH, math.min(room.x * WIDTH + WIDTH - enemy.cwidth, enemy.x + enemy.dx * dt))
    local goal_y = math.max(room.y * HEIGHT, math.min(room.y * HEIGHT + HEIGHT - 8 - enemy.cheight, enemy.y + enemy.dy * dt))

    local ax, ay, items, len = bump:move(enemy, goal_x, goal_y, function (item, other)
        if M.is_stunned(item) and (world.is_solid(other) or world.is_one_way(other) ) and item.y + item.cheight <= other.y then
            return "slide"
        end
        if other.type == COL_ENEMY then
            return "cross"
        end
    end)

    for i = 1, len do
        local item = items[i].other
        if item.type == COL_ENEMY then
            local to_x, to_y = math.norm(item.x - enemy.x, item.y - enemy.y)
            enemy.dx = enemy.dx - to_x * 64 * dt
            enemy.dy = enemy.dy - to_y * 64 * dt

            item.dx = item.dx + to_x * 64 * dt
            item.dy = item.dy + to_y * 64 * dt
        end
    end

    enemy.x = ax
    enemy.y = ay
    enemy.flip_x = player.x - enemy.x < 0
end

updaters.frank = function(dt, enemy)
    if M.is_stunned(enemy) then return end
    local bump = world.bump_world
    local room = world.current_room
    local room_x = room.x * WIDTH

    enemy.dy = enemy.dy + 128 * dt
    local goal_x = enemy.x + enemy.dir * 8 * dt
    local goal_y = enemy.y + enemy.dy * dt

    local ax, ay, items, len = bump:move(enemy, goal_x, goal_y, function (item, other)
        return (world.is_solid(other) or world.is_one_way(other)) and "slide"
    end)

    enemy.x, enemy.y = ax, ay

    local new_dir = enemy.dir
    for i = 1, len do
        local item = items[i]
        if item.normal.x ~= 0 then
            new_dir = -1 * enemy.dir
        end
        if item.normal.y ~= 0 then
            enemy.dy = 0
        end
    end

    if enemy.x < room_x or enemy.x > room_x + WIDTH - enemy.cwidth then
        new_dir = -1 * enemy.dir
    end

    local qp_x, qp_y = enemy.x, enemy.y + enemy.cheight + 3
    if enemy.dir == 1 then qp_x = qp_x + enemy.cwidth end

    -- really not sure why queryPoint wouldn't work properly
    items, len = bump:queryRect(qp_x, qp_y, 1, 1)
    if enemy.dy == 0  and len == 0 then
        new_dir = -1 * enemy.dir
    end

    enemy.dir = new_dir
    enemy.flip_x = enemy.dir < 0
end

local dirs = { -1, 1 }
function M.take_damage(obj, dir, type)

    if M.is_stunned(obj) and type == DMG_BONK then
        obj.dead = true
        obj.animation = obj.dead_animation
        obj.dx = dirs[1 + math.round(love.math.random())] * 128
        obj.dy = -128
        world.player_score = world.player_score + 150
    elseif not M.is_stunned(obj) and type == DMG_ARM then
        obj.stunned = {
            t = 3.5,
            animation = assets.animations.stars
        }
    end

end

function M.update(dt, enemy)
    if updaters[enemy.enemy_type] then
        updaters[enemy.enemy_type](dt, enemy)
    end

end



function M.death_bounce(dt, enemy)
    local bump = world.bump_world
    local room = world.current_room
    local room_x = room.x * WIDTH
    local room_y = room.y * HEIGHT

    local goal_x = enemy.x + enemy.dx * dt
    local goal_y = enemy.y + enemy.dy * dt


    local ax, ay, items, len = bump:move(enemy, goal_x, goal_y, function (item, other)
        if enemy.y + enemy.cheight < other.y and enemy.dy > 0 then
                return (world.is_solid(other) or world.is_one_way(other)) and "touch"
        end
    end)


    local chance = 0.7
    if world.enemy_count() == 1 then
        chance = 0.25
    end

    for i = 1, len do
        local item = items[i]

        if love.math.random() > chance and item.normal.y == -1 then
            if love.math.random() <= 0.1  then enemy.dy = enemy.dy * -1 end
        else
            enemy.destroy = true
        end
    end

    if ax < room_x + 8 or ax + enemy.cwidth > room_x + WIDTH - 8 then
        enemy.dx = enemy.dx * -1
    end

    if ay < room_y + 8 or ay + enemy.cheight > room_y + HEIGHT - 8 then
        enemy.dy = enemy.dy * -1
    end

    enemy.x = ax
    enemy.y = ay
end


function M.is_stunned(obj)
    return obj.stunned and obj.stunned.t > 0 and not obj.dead
end

function M.draw(entity)
    if entity.stunned and entity.stunned.t > 0 and not entity.dead then
        gfx.draw_sprite(entity.stunned.sprite,entity.x - entity.cx, entity.y - entity.cy - 6)
        gfx.draw_sprite(entity.stunned_sprite, entity.x - entity.cx, entity.y - entity.cy)
    else
        gfx.draw_sprite(entity.sprite, entity.x - entity.cx, entity.y - entity.cy, entity.flip_x)
    end
end

return M