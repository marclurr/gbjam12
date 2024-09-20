love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineStyle("rough")
love.graphics.setLineWidth(1)

local font = love.graphics.newImageFont("data/gfx/font.png", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789!?%()[]\"'`/\\+-,$")
love.graphics.setFont(font)

local canvas = love.graphics.newCanvas(WIDTH, HEIGHT)
local palettes_data = love.image.newImageData("data/gfx/palettes.png")
local palette_order_data = love.image.newImageData(4, 1)
palette_order_data:setPixel(0, 0, 0.125 + (0 / 4), 0, 0)
palette_order_data:setPixel(1, 0, 0.125 + (1 / 4), 0, 0)
palette_order_data:setPixel(2, 0, 0.125 + (2 / 4), 0, 0)
palette_order_data:setPixel(3, 0, 0.125 + (3 / 4), 0, 0)

local palettes = love.graphics.newImage(palettes_data)
local palette_order = love.graphics.newImage(palette_order_data)

local shader = love.graphics.newShader [[
    uniform Image palettes;
    uniform Image palette_order;
    uniform float palette;
    uniform float pal_count;
    uniform int transparent_colour;

    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
        vec4 lup = Texel(tex, texture_coords);
        float idx = lup.r;
        float colour_id = Texel(palette_order, vec2(idx, 0)).r ;

        int id = int(colour_id * 4.0);

        if (id == transparent_colour || int(idx * 4.0) == transparent_colour) { discard; }

        vec4 colour = Texel(palettes, vec2(colour_id , palette / pal_count));
        return colour;
    }

]]

local current_pal = 0

shader:send("pal_count", palettes:getHeight())
shader:send("palette", current_pal)
shader:send("palettes", palettes)
shader:send("palette_order", palette_order)
shader:send("transparent_colour", -1)

local function lookup_colour(col)
    local index = palette_order_data:getPixel(col, 0);
    return {palettes_data:getPixel(math.floor(index * 4), current_pal)}
end


local M = {}

M.draw = love.graphics.draw

function M.draw_sprite(sprite, x, y, flip_x, flip_y)
    M.palt(sprite.mask)
    local sx = flip_x and -1 or 1
    local sy = flip_y and -1 or 1

    local ox = sprite.width / 2
    local oy = sprite.height / 2

    M.draw(sprite.texture, sprite.quad, math.round(x + ox), math.round(y ), 0, sx, sy, ox)
end

function M.set_palette(id)
    current_pal = math.min(palettes:getHeight() - 1, id or 0)
    shader:send("palette", current_pal)
end

function M.pal(from, to)
    if M.disable_pals then  return end

    if from and to then
        palette_order_data:setPixel(from, 0, 0.125 + (to / 4), 0, 0)
    else
        palette_order_data:setPixel(0, 0, 0.125 + (0 / 4), 0, 0)
        palette_order_data:setPixel(1, 0, 0.125 + (1 / 4), 0, 0)
        palette_order_data:setPixel(2, 0, 0.125 + (2 / 4), 0, 0)
        palette_order_data:setPixel(3, 0, 0.125 + (3 / 4), 0, 0)
    end

    palette_order:replacePixels(palette_order_data)
end

function M.palt(col)
    col = col or -1
    shader:send("transparent_colour", col)
end

function M.begin()
    love.graphics.setCanvas(canvas)
    love.graphics.setShader(shader)
end

function M.cls(col)
    col = math.max(0, math.min(3, col or 0))
    love.graphics.clear(lookup_colour(col))
end

local function set_colour(col)
    col = col or 0
    love.graphics.setColor(lookup_colour(col or 3))
end

function M.print(text, x ,y, col)
    set_colour(col)
    love.graphics.setShader()
    love.graphics.print(text, x, y)
    love.graphics.setShader(shader)
    love.graphics.setColor(1, 1, 1, 1)
end


function M.circle(style, x, y, radius, col)
    set_colour(col)
    love.graphics.setShader()
    love.graphics.circle(style, x, y, radius)
    love.graphics.setShader(shader)
    love.graphics.setColor(1, 1, 1, 1)
end

function M.rectangle(style, x, y, width, height, col)
    set_colour(col)
    love.graphics.setShader()
    love.graphics.rectangle(style, x, y, width, height)
    love.graphics.setShader(shader)
    love.graphics.setColor(1, 1, 1, 1)
end

function M.finish()
    love.graphics.setCanvas()
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1, 1)

    local scale = math.floor(math.min(love.graphics.getWidth() / WIDTH, love.graphics.getHeight() / HEIGHT))

    love.graphics.draw(canvas, 0, 0, 0, scale, scale)
end



return M