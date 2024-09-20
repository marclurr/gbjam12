local textureatlas = require("textureatlas")
local assets = require("game.assets")



return function (text, x, y, col)
    text = string.upper(text)
    local atlas = assets.atlases.debug_atlas

    for i = 1, #text do
        local char = string.byte(text:sub(i, i)) - 65
        local id = 545 + char
        -- if char == -32 then id = 573 end
        textureatlas.draw(atlas, id, x + (i - 1) * 8, y)
    end
end

