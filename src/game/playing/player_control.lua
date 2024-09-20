local animator = require("animator")
local assets = require("game.assets")
local input = require("input")
local gfx = require("graphics")

local world = require("game.playing.world")

local arm_control = require("game.playing.arm_control")
local enemy = require("game.playing.enemy")

local COLLIDE_LEFT = 1
local COLLIDE_RIGHT = 2
local COLLIDE_UP = 4
local COLLIDE_DOWN = 8

local fall_through = 0
local jump_height = 2.5 * 8
local jump_duration = 0.27
local gravity = (2 * jump_height) / (jump_duration * jump_duration)
local jump_velocity = -math.sqrt(2 * gravity * jump_height)

local ix, iy = 0, 0

local ST_IDLE = 1
local ST_RUN = 2
local ST_JUMP = 3
local ST_FALL = 4
local ST_CLIMB = 5
local ST_THROW_LEFT = 6
local ST_THROW_RIGHT = 7
local ST_DIE = 8
local ST_RESPAWN = 9

local current_state = nil
local movement_speed = 56
local jump_buffer = 0
local fall_buffer = 0
local climb_cooldown = 0
local invincibility = 0
local dir_disabled_timer = 0
local respawn_timer = 0

local function do_movement(dt, player)
    local bump = world.bump_world

    local filter = function (obj, other)

        if world.is_one_way(other) and fall_through == 0 and current_state ~= ST_CLIMB then
            if obj.dy > 0 and obj.y + obj.cheight <= other.y then
                return "slide"
            end
        elseif world.is_solid(other) then
            return "slide"
        end
    end

    local world_width, world_height = world.get_dimensions()

    local goal_x = player.x + player.dx * dt
    local goal_y = player.y + player.dy * dt

    local ax, ay, cols, len = bump:move(world.player, goal_x, goal_y, filter)

    local result = 0
    local up, down, left, right = false, false, false, false

    for i = 1, len do
        local col = cols[i]

        if col.normal.x < 0 then
            result = bit.bor(result, COLLIDE_LEFT)
            player.dx = 0
        end
        if col.normal.x > 0 then
            result = bit.bor(result, COLLIDE_RIGHT)
            player.dx = 0
        end
        if col.normal.y > 0 then
            result = bit.bor(result, COLLIDE_UP)
            player.dy = 0
        end
        if col.normal.y < 0 then
            result = bit.bor(result, COLLIDE_DOWN)
            player.dy = 0
        end
    end

    -- if ay > HEIGHT then
    --     ay = ay - HEIGHT
    --     bump:update(player, ax, ay)
    -- elseif ay < 0 then
    --     ay = ay + HEIGHT
    --     bump:update(player, ax, ay)
    -- end

    player.x, player.y = ax, ay

    return result
end

local function is_grounded(col_result)
    return bit.band(col_result, COLLIDE_DOWN) > 0
end


local function ground_movement(player)
    if dir_disabled_timer > 0 then return end
    player.dx = ix * movement_speed
end

local function apply_gravity(dt, player)
    player.dy = player.dy + gravity * dt
end

local function can_jump_down(player)
    local bump = world.bump_world
    local x, y, w, h = bump:getRect(player)
    local items, len = bump:queryRect(x, y + 2, w, h, function (item)
        return item.type == COL_SOLID or item.type == COL_ONEWAY
    end)

    for i = 1, len do
        if items[i].type ~= COL_ONEWAY then return false end
    end
    return len > 0
end

local function can_climb(player, oy)
    -- if world.game_state.arm_count < 2 then return false end
    oy = oy or 0
    if climb_cooldown > 0 then return false end
    local bump = world.bump_world
    local x, y, w, h = bump:getRect(player)
    local items, len = bump:queryRect(x, y + oy, w, h, FilterByType(COL_ROPE))
    if len > 0 then
        local rx, _, rw = bump:getRect(items[1])
        return rx + rw / 2 - player.cwidth / 2
    end

    return false

end

local function bump_enemy(player, old_x, old_y)
    local bump = world.bump_world
    local rx, ry, rw, rh = bump:getRect(player)

    local items, len = bump:queryRect(rx,ry, rw, rh, function (item)
        return item.type == COL_ENEMY and enemy.is_stunned(item)
    end)

    if len == 0 then
        -- print("nothing to bump")
        return false
    end

    local obj = items[1]

    if old_y + rh < obj.y or (ry + rh) - obj.y < 3 then
        obj.got_bumped = true
        enemy.take_damage(obj, 0, DMG_BONK)
        return true
    end
    return false
end

local function collect_arms(player)
    local bump = world.bump_world
    local rx, ry, rw, rh = bump:getRect(player)
    local items, len = bump:queryRect(rx, ry, rw, rh, FilterByType(COL_ARM))

    for i = 1, len do
        if items[i].state == 2 then -- tODO something better
            world.arm_collected(items[i])
        end
    end

end

local function enter_state(player, state, ...)
    if state == ST_DIE then
        animator.play(player, assets.animations.skelly_die)
        respawn_timer = 1.5
        local dir = unpack({...})
        player.dx = dir * 64
        player.dy = jump_velocity
    elseif state == ST_RESPAWN then
        if world.player_lives <= 0 then
            world.trigger_gameover()
            respawn_timer = 1.5
        else
            invincibility = 1.5
            animator.play(player, assets.animations.skelly_respawn)
            respawn_timer = 0.4
        end
        -- dir_disabled_timer = 0.3
        -- player.dx = dir * 56
    -- enter_state(player, ST_JUMP, jump_velocity * 0.8)
    elseif state == ST_JUMP then
        jump_buffer = 0
        local vel = unpack({...}) or jump_velocity
        player.dy = vel
        if current_state == ST_CLIMB then
            climb_cooldown = 8 * 0.0167
        end
    elseif state == ST_CLIMB then
        player.dx = 0
        player.dy = 0
        local oy = unpack({...}) or 0
        player.x = can_climb(player, oy)
        player.y = player.y + oy
        world.bump_world:update(player, player.x, player.y)
    elseif state == ST_FALL and current_state == ST_RUN then
        fall_buffer = 6 * 0.0167
    end

    current_state = state
end

local M = {}

M.prototype = {
    x = WIDTH / 2, y = HEIGHT / 2,
    dx = 0, dy = 0,
    cx = 2, cy = 0, cwidth = 7, cheight = 7
}


function M.init(player)
    enter_state(player, ST_IDLE)
end

function M.update(dt, player)
    if not current_state then M.init(player) end

    jump_buffer = math.max(0, jump_buffer - dt)
    fall_buffer = math.max(0, fall_buffer - dt)
    climb_cooldown = math.max(0, climb_cooldown - dt)
    fall_through = math.max(0, fall_through - dt)
    invincibility = math.max(0, invincibility - dt)
    dir_disabled_timer = math.max(0, dir_disabled_timer - dt)
    respawn_timer = math.max(0, respawn_timer - dt)

    ix, iy = 0, 0
    if input.is_pressed("left") then ix = ix - 1 end
    if input.is_pressed("right") then ix = ix + 1 end
    if input.is_pressed("up") then iy = iy - 1 end
    if input.is_pressed("down") then iy = iy + 1 end
    if input.is_just_pressed("a") then jump_buffer = 3 * 0.0167 end
    if input.is_just_pressed("b") then arm_control.throw(player.x, player.y, player.flip_x and -1 or 1) end
    local climb_requested = input.is_pressed("up")

    collect_arms(player)
    animator.update(dt, player)
    -- if world.player_lives == 0 then return end
    if current_state == ST_DIE then
        apply_gravity(dt, player)

        local result = do_movement(dt, player)
        if is_grounded(result) then player.dx = player.dx * 0.9 end
        if respawn_timer == 0 and player.dy == 0 then
            enter_state(player, ST_RESPAWN)
        end
        return
    elseif current_state == ST_RESPAWN then
        if respawn_timer == 0 then
            if world.player_lives > 0 then
                enter_state(player, ST_IDLE)
            else
            end
            return
        end
    elseif current_state == ST_IDLE then
        ground_movement(player)
        apply_gravity(dt, player)

        local result = do_movement(dt, player)

        if can_climb(player) and iy == -1 then return enter_state(player, ST_CLIMB) end
        if can_climb(player, 2) and iy == 1 then return enter_state(player, ST_CLIMB, 2) end
        if not is_grounded(result) then enter_state(player, ST_FALL) end
        if can_jump_down(player) and jump_buffer > 0 and iy == 1 then jump_buffer = 0; fall_through = 8 * 0.0167; return end
        if jump_buffer > 0 then return enter_state(player, ST_JUMP) end
        if player.dx ~= 0 then return enter_state(player, ST_RUN) end
    elseif current_state == ST_RUN then
        ground_movement(player)
        apply_gravity(dt, player)

        local result = do_movement(dt, player)

        if can_climb(player) and iy == -1 then return enter_state(player, ST_CLIMB) end
        if can_climb(player, 2) and iy == 1 then return enter_state(player, ST_CLIMB, 2) end
        if not is_grounded(result) then return enter_state(player, ST_FALL) end
        if player.dx == 0 then return enter_state(player, ST_IDLE) end
        if can_jump_down(player) and jump_buffer > 0 and iy == 1 then jump_buffer = 0; fall_through = 8 * 0.0167; return end
        if jump_buffer > 0 then return enter_state(player, ST_JUMP) end
    elseif current_state == ST_JUMP then
        ground_movement(player)
        apply_gravity(dt, player)

        local old_x, old_y = player.x, player.y
        local result = do_movement(dt, player)

        -- if bump_enemy(player, old_x, old_y) then enter_state(player, ST_JUMP) end
        if player.dy >= 0 then return enter_state(player, ST_FALL) end
        if can_climb(player) and iy == -1 then return enter_state(player, ST_CLIMB) end
    elseif current_state == ST_FALL then
        ground_movement(player)
        apply_gravity(dt, player)

        local old_x, old_y = player.x, player.y
        local result = do_movement(dt, player)

        if bump_enemy(player, old_x, old_y) then enter_state(player, ST_JUMP) end

        if jump_buffer > 0 and fall_buffer > 0 then return enter_state(player, ST_JUMP) end
        if can_climb(player) and iy == -1 then return enter_state(player, ST_CLIMB) end
        if is_grounded(result) and player.dx == 0  then return enter_state(player, ST_IDLE) end
        if is_grounded(result) and player.dx ~= 0  then return enter_state(player, ST_RUN) end
    elseif current_state == ST_CLIMB then
        player.dy = iy * 40

        local result = do_movement(dt, player)
        -- if jump_buffer > 0  dthen return enter_state(player, ST_FALL) end
        if jump_buffer > 0 then return enter_state(player, ST_JUMP, jump_velocity * 0.8) end
        if not can_climb(player) then return enter_state(player, ST_FALL) end
    end

    if ix ~= 0 then player.flip_x = ix < 0 end

end

function M.take_damage(player, power, dir)
    if current_state == ST_DIE or current_state == ST_RESPAWN then return end
    if invincibility == 0  then
        enter_state(player, ST_DIE, dir)
        world.lose_life()
    end
end

-- player has some weird specific things to do with its rendering
local visible = true
function M.draw(player)
    if GlobalT % 5 == 0 then visible = not visible end

    if invincibility == 0 or visible then
        gfx.draw_sprite(player.sprite, world.player.x - 4, world.player.y - 8, world.player.flip_x)
        -- gfx.draw_sprite(assets.sprites.skelly_full_1, world.player.x - 4, world.player.y - 8 - HEIGHT, world.player.flip_x)
        -- gfx.draw_sprite(assets.sprites.skelly_full_1, world.player.x - 4, world.player.y - 8 + HEIGHT, world.player.flip_x)
    end
end

function M.draw_debug(player)
    gfx.print(tostring(current_state) .. "\n" .. tostring(can_jump_down(player)), 0, 0, 3)
end

return M