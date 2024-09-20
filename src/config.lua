local gfx = require("graphics")

local M = {}

M.values = {
    palette = 3,
    scale = 5,
    sfx = 9,
    music = 9
}

function M.set_palette(p)
    M.values.palette = p
    gfx.set_palette(p)
end

function M.set_scale(scale)
    M.values.scale = scale
    love.window.setMode(scale * WIDTH, scale * HEIGHT)
end

function M.set_sfx(vol)
    M.values.sfx = vol
end

function M.set_music(vol)
    M.values.music = vol
end

function M.persist()

end

function M.load()

end

return M