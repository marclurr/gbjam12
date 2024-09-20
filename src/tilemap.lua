local gfx = require("graphics")
local textureatlas = require("textureatlas")

local M = {}

function M.load(path, atlas)
    local fn = love.filesystem.load(path)
    local map = fn()

    local result = {}
    result.atlas = atlas
    result.width = map.width
    result.height = map.height
    result.tile_width = map.tilewidth
    result.tile_height = map.tileheight
    result.tile_layer_order = {}
    result.tile_layers = {}
    result.object_layers = {}

    for i, layer in ipairs(map.layers) do
        if layer.type == "tilelayer" then
            local name = layer.name or string.format("tile_layer_%d", i)

            result.tile_layers[name] = layer
            table.insert(result.tile_layer_order, name)
        elseif layer.type == "objectgroup" then
            result.object_layers[layer.name or string.format("object_layer_%d", i)] = layer.objects
        end
    end

    return result
end

function M.draw_layer(map, layer)
    if not layer then return end
    if not map.tile_layers[layer] then return end

    local tile_layer = map.tile_layers[layer]

    gfx.palt(-1)
    for row = 0, map.height - 1 do
        for col = 0, map.width - 1 do
            local x = col * map.tile_width
            local y = row * map.tile_height
            local i = 1 + col + row * map.width
            local tile_id = tile_layer.data[i]

            textureatlas.draw(map.atlas, tile_id, x, y)
        end
    end
end

function M.draw(map)
    for i = 1, #map.tile_layer_order do
        local layer = map.tile_layer_order[i]
        M.draw_layer(map, layer)
    end
end

return M