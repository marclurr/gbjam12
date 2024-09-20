local cols, rows = 10, 10

local levels = {}
local M = {}

function M.init(world)
    local mappings = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
        20, 19, 18, 17, 16, 15, 14, 13, 12, 11,
        21, 22, 23, 24, 25, 26, 27, 28, 29, 30
    }
    levels = {}
    for i = 1, #mappings do
        table.insert(levels, world.rooms[mappings[i]])
    end


end

function M.get(i)
    return levels[i]
end

function M.count()
    return #levels
end

return M