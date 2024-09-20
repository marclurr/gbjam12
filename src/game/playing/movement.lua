local world = require("game.playing.world")

local M = {}

local function move_x(obj, dx)
    local x_dir = math.sign(dx)
    dx = math.abs(dx)

    while dx > 0 do
        local step = math.min(1, dx)
        local nx = obj.x + x_dir * step
        dx = dx - step

        if world.is_solid(nx, obj.y, obj.cwidth, obj.cheight) then
            if x_dir < 0 then
                obj.x = math.floor(obj.x)
            elseif x_dir > 0 then
                obj.x = math.floor(obj.x)
            end
            return
        end
        obj.x = nx
    end
end

local function move_y(obj, dy)
    local y_dir = math.sign(dy)
    dy = math.abs(dy)

    while dy > 0 do
        local step = math.min(1, dy)
        local ny = obj.y + y_dir * step
        dy = dy - step

        if y_dir < 0 then
            if world.is_solid(obj.x, ny, obj.cwidth, obj.cheight) then
                obj.y = math.floor(obj.y)
                return
            end
        elseif y_dir > 0 then
            local stop_on_one_way = world.is_all_oneway(obj.x, ny, obj.cwidth, obj.cheight)
                and not world.is_all_oneway(obj.x, obj.y, obj.cwidth, obj.cheight)
            if stop_on_one_way or  world.is_solid(obj.x, ny, obj.cwidth, obj.cheight) then
                -- obj.y = math.floor(obj.y)
                return
            end
        end
        obj.y = ny
    end
end


function M.move_obj(dt, obj)
    local dx, dy = obj.dx, obj.dy

    move_x(obj, dx)
    move_y(obj, dy)
end

return M