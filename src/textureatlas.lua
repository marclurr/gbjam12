local gfx = require("graphics")

local M = {}

function M.new(texture, tile_width, tile_height, region_x, region_y, region_width, region_height)
    region_x = region_x or 0
    region_y = region_y or 0
    region_width = region_width or texture:getWidth()
    region_height = region_height or texture:getHeight()

    local columns = region_width / tile_width
    local rows = region_height / tile_height

    local quads = {}

    for row = 0, rows - 1 do
        for col = 0, columns - 1 do
            local tx = region_x + (col * tile_width)
            local ty = region_y + (row * tile_height)

            table.insert(quads, love.graphics.newQuad(tx, ty, tile_width, tile_height, texture))
        end
    end

    local result = {}
    result.quads = quads
    result.texture = texture
    result.tile_width = tile_width
    result.tile_height = tile_height

    return result
end

function M.draw(atlas, id, x, y)
    if id < 1 then return end
    local q = atlas.quads[id]

    if q then
        gfx.draw(atlas.texture, q, x, y)
    end
end

return M