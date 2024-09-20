local world = require("game.playing.world")
local objects = require("game.playing.objects")
local enemy = require("game.playing.enemy")

local assets = require("game.assets")
local gfx = require("graphics")

local ST_THROWN = 1
local ST_IDLE = 2

local M = {}

local rebound_height = 1.5 * 8
local rebound_duration = 0.25
local gravity = (2 * rebound_height) / (rebound_duration * rebound_duration)
local rebound_velocity = -math.sqrt(2 * gravity * rebound_height)

function M.throw(x, y, dir)
    if world.game_state.arm_count > 0 then
        local arm = objects.make("arm", x, y)
        arm.dx = dir * 128
        arm.dy = 0
        arm.state = ST_THROWN

        world.add_arm(arm)
        world.game_state.arm_count = world.game_state.arm_count - 1
    end
end

function M.update(dt, arm)
    local bump = world.bump_world

    if arm.state == ST_IDLE then
        arm.dx = arm.dx * 0.95
        arm.dy = arm.dy + gravity * dt
    end

    local goal_x, goal_y = arm.x + arm.dx * dt, arm.y + arm.dy * dt

    local ax, ay, items, len = bump:move(arm, goal_x, goal_y, function (item, other)
        if  (item.state == ST_THROWN and other.type == COL_ENEMY and not enemy.is_stunned(other))
            or (item.state == ST_THROWN and other.type == COL_INTERACT)
            or world.is_solid(other) or (other.type == COL_ONEWAY and item.state == ST_IDLE)
            or (item.state == ST_IDLE and other.state == ST_IDLE) then
            return "slide"
        end
    end)
    arm.x, arm.y = ax, ay
    if len > 0 then
        for i = 1, len do
            local item = items[i]
            if arm.state == ST_THROWN then
                arm.state = ST_IDLE
                arm.dx = item.normal.x * 32
                arm.dy = rebound_velocity

                local other = item.other

                if other.type == COL_INTERACT and other.interact then
                    other:interact(world)
                elseif other.type == COL_ENEMY then
                    enemy.take_damage(other, math.sign(other.x - arm.x), DMG_ARM)
                end
                -- TODO damager/interact with things
            elseif arm.state == ST_IDLE  then
                local dot = math.dot(arm.dx, arm.dy, item.normal.x, item.normal.y)
                local rx = (2 * item.normal.x * dot) - arm.dx
                local ry = (2 * item.normal.y * dot) - arm.dy
                arm.dx = -rx * 0.3
                arm.dy = -ry * 0.3
                if item.other.type == COL_ARM then
                    item.other.dx = item.other.dx + -arm.dx  * 0.5
                    item.other.dy = item.other.dy + -arm.dy * 0.5

                end

            end

    end

    end
    arm.destroy = arm.destroy or not world.is_current_room(ax, ay)
end

function M.draw(arm)
    gfx.draw_sprite(assets.sprites.hand_1, arm.x, arm.y)
end

return M