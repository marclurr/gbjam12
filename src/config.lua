local gfx = require("graphics")

local M = {}

M.values = {
    palette = 3,
    scale = love.system.getOS() == "Web" and 3 or 5,
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
    local content = love.data.pack("string", "bbbb", M.values.palette, M.values.scale, M.values.sfx, M.values.music)
    love.filesystem.write("config.dat", content)
end

function M.load()
    if not love.filesystem.getInfo("config.dat") then M.persist() end
    local content = love.filesystem.read("config.dat")
    local pal, scale, sfx, music = love.data.unpack("bbbb", content)
    M.set_palette(math.min(3, pal))
    M.set_scale(math.min(6, scale))
    M.set_music(math.min(9, music))
    M.set_sfx(math.min(9, sfx))
end

return M