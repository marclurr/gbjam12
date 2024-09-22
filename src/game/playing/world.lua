local bump = require("lib.bump")
local tweens = require("tweens")
local objects = require("game.playing.objects")
local levels = require("game.playing.levels")

local M = {}

local transitions = {}

local transition_dur = 1 --.35


local function init_map_collision()
    local map = M.map
    local collision_layer = map.tile_layers.collision
    for i = 0, #collision_layer.data - 1 do
        local x = i % map.width
        local y = math.floor(i / map.width)

        local tile = {}
        tile.x = x * map.tile_width
        tile.y = y * map.tile_height
        tile.width = map.tile_width
        tile.height = map.tile_height
        tile.type = collision_layer.data[i + 1]

        if tile.type == COL_ONEWAY_ROPE then
            tile.type = COL_ONEWAY
            M.bump_world:add(tile, tile.x, tile.y, tile.width, tile.height)

            tile = {}
            tile.x = x * map.tile_width + 2
            tile.y = y * map.tile_height
            tile.width = 4
            tile.height = map.tile_height
            tile.type = COL_ROPE

             M.bump_world:add(tile, tile.x, tile.y, tile.width, tile.height)
        elseif tile.type ~= COL_NONE then
            if tile.type == COL_ROPE then
                tile.x = tile.x + 2
                tile.width = 4
            end
            M.bump_world:add(tile, tile.x, tile.y, tile.width, tile.height)
        end
    end
end

local function init_rooms()
    M.rooms = {}
    M.h_rooms = M.map.width / 20
    M.v_rooms = M.map.height / 18

    for y = 0, M.v_rooms - 1 do
        for x = 0, M.h_rooms - 1 do
            local room = {}
            room.id = 1 + x + y * M.h_rooms
            room.x = x
            room.y = y
            room.objects = {} -- uninitialised objects

            table.insert(M.rooms, room)
        end
    end

    local objects = M.map.object_layers.objects
    local map_width = M.get_dimensions()

    for i = 1, #objects do
        local object = objects[i]
        local room_x = math.floor(object.x / WIDTH)
        local room_y = math.floor(object.y / HEIGHT)
        local room_i = 1 + room_x + room_y * M.h_rooms

        object.room_id = room_i
        object.y = object.y - 8

        if object.gid == COL_PLAYER_START then
            local room = M.rooms[room_i]
            room.spawn_point = {
                x = object.x,
                y = object.y
            }
        else
            table.insert(M.rooms[room_i].objects, object)
        end
    end

    levels.init(M)
end

local function init_room_entities()
    local room = M.current_room

    for i = 1, #room.objects do
        local object = room.objects[i]
        local entity = objects.make_from_tile(object.gid, object.x, object.y)
        entity.room = room
        if entity then M.add_entity(entity) end
    end
end

local function finish_transition()
    for i = #M.entities, 1, -1 do
        local entity = M.entities[i]
        -- if entity.room_id ~= M.current_room.id then
        if entity.room ~= M.current_room then
            M.remove_entity_by_id(i)
        end
    end
    M.ready = true
    M.blocks_on = true
    -- update player collision box as the transition doesn't
    M.bump_world:update(M.player, M.player.x, M.player.y)
end

function M.trigger_gameover()
    M.gameover = true
    M.gameover_t = 1
    M.gameover_fadein = 0
    tweens.new_tween(M, "gameover_fadein", 0, 3, 1)
end

function M.trigger_win()
    if M.win then return end
    M.win = true
    M.gameover_t = 1
    M.gameover_fadein = 0
    tweens.new_tween(M, "gameover_fadein", 0, 3, 1)
end

function M.init(map, mode)

    M.overlay = {
       x = 1, y = 0,
       width = 0, height = HEIGHT
    }
    M.gameover = false
    M.gameover_t = 1
    M.gameover_fadein = 0
    M.map = map
    M.mode = mode or MODE_ARCADE
    M.bump_world = bump.newWorld()
    M.blocks_on = true
    M.level = 1
    M.player_lives = 3
    M.player_score = 0
    init_map_collision()
    init_rooms()
    M.current_room = levels.get(M.level)

    M.camera = { x = M.current_room.x * WIDTH, y = M.current_room.y * HEIGHT }

    M.game_state = {

        arm_count = 2
    }

    M.player = objects.make("player", M.current_room.spawn_point.x, M.current_room.spawn_point.y)

    M.entities = {}
    M.player_arms = {}



    M.add_obj_collision(M.player)

    init_room_entities()

    M.ready = true
end

function M.lose_life()
    if M.mode == MODE_ARCADE then
        M.player_lives = M.player_lives - 1
    end
end

function M.next_level()
    M.level = M.level + 1
    if M.level > levels.count() then
        M.trigger_win()
    else
        M.transition_rooms(levels.get(M.level))
    end
end

function M.get_dimensions()
    return M.map.width * M.map.tile_width, M.map.height * M.map.tile_height
end

function M.get_room(x, y)
    x = math.floor(x / WIDTH)
    y = math.floor(y / HEIGHT)
    local i = 1 + x  + y * M.h_rooms
    return M.rooms[i]
end

function M.is_current_room(x, y)
    local room = M.get_room(x, y)
    return room and room.id == M.current_room.id
end

function M.enemy_count()
    local c = 0
    for i = 1, #M.entities do
        if M.entities[i].type == COL_ENEMY then
            c = c + 1
        end
    end
    return c
end

function M.pickup_count()
    local c = 0
    for i = 1, #M.entities do
        if M.entities[i].type == COL_PICKUP then
            c = c + 1
        end
    end
    return c
end

function M.transition_rooms(new_room)
    local new_cam_x = new_room.x * WIDTH
    local new_cam_y = new_room.y * HEIGHT

    tweens.new_tween(M.camera, "x", M.camera.x, new_cam_x, transition_dur).on_complete = finish_transition
    tweens.new_tween(M.camera, "y", M.camera.y, new_cam_y, transition_dur)
    tweens.new_tween(M.player, "x", M.player.x, new_room.spawn_point.x, transition_dur)
    tweens.new_tween(M.player, "y", M.player.y, new_room.spawn_point.y, transition_dur)

    M.current_room = new_room
    init_room_entities()

    M.ready = false
end

function M.add_entity(entity)
    if not entity then return end
    M.add_obj_collision(entity)
    table.insert(M.entities, entity)
end

function M.add_arm(arm)
    M.add_obj_collision(arm)
    table.insert(M.player_arms, arm)
    -- game_state.arm_count = game_state.arm_count - 1
end

function M.arm_collected(arm)
    for i = 1, #M.player_arms do
        if M.player_arms[i] == arm then
            M.bump_world:remove(arm)
            table.remove(M.player_arms, i)
            M.game_state.arm_count = M.game_state.arm_count + 1
            return
        end
    end
end

function M.remove_entity_by_id(id)
    local obj = M.entities[id]
    if obj then
        if M.bump_world:hasItem(obj) then M.bump_world:remove(obj) end
        table.remove(M.entities, id)
    end
end

function M.add_obj_collision(obj)
    if obj.x and obj.y and obj.cwidth and obj.cheight then
        M.bump_world:add(obj, obj.x, obj.y, obj.cwidth, obj.cheight)
    end
end

function M.is_solid(x, y, width, height)
    for i = math.floor(x / M.map.tile_width), math.floor((x + width ) /  M.map.tile_width) do
        for j = math.floor(y / M.map.tile_height), math.floor((y + height ) /  M.map.tile_height) do
            local ii = i + j * M.map.width + 1
            local tile = M.collision[ii]

            if tile.type == COL_SOLID then
                return true
            end
        end
    end
end

function M.overlapping_entities_by_type(x, y, w, h, type)
    return M.bump_world:queryRect(x, y, w, h, function (item)
        return item.type == type
    end)
end

function M.is_solid(tile)
    return tile.type == COL_SOLID
        or (tile.type == COL_SWITCH_BLOCK and M.blocks_on)
        or (tile.type == COL_SWITCH_BLOCK_INV and not M.blocks_on)
end

function M.is_one_way(tile)
    return  tile.type == COL_ONEWAY or tile.type == COL_ONEWAY_ROPE
end


function M.update(dt)

end

return M