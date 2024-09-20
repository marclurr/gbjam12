WIDTH = 160
HEIGHT = 144

MODE_ARCADE = 1
MODE_CASUAL = 2

COL_NONE = 0
COL_ENEMY = 1
COL_INTERACT = 2
COL_ARM = 3
COL_DOOR = 5
COL_PICKUP = 6
COL_SWITCH_BLOCK = 19
COL_SWITCH_BLOCK_INV = 51
COL_SWITCH = 53
COL_GHOST = 290
COL_FRANK = 299

COL_SOLID = 1025
COL_ONEWAY = 1026
COL_ROPE = 1027
COL_ONEWAY_ROPE = 1028
COL_PLAYER_START = 1029

DMG_ARM = 1
DMG_BONK = 2

if not bit then
    bit = require("bitop")
end

function FilterByType(type)
    return function(item)
        return item.type == type
    end
end

function RequirePrototype(name)
    return require(name).prototype
end

function NewSprite(texture, x, y, width, height, mask)
    return {
        ["texture"] = texture,
        ["mask"] = mask or 0,
        ["width"] = width,
        ["height"] = height,
        quad = love.graphics.newQuad(x, y, width, height, texture)
    }
end

function NewAnimation(frame_time, loop, ...)
    return {
        ["frame_time"] = frame_time,
        ["loop"] = loop,
        frames = {...}
    }
end

function NewAnimator(animation)
    local result = {}
    result.animation = animation
    result.t = 0
    return result
end

function LoadImg(name)
    local imgfile = require(name)
    local imgc = imgfile.data

    local img = {}
    for i = 0, #imgc - 1 do
        local v = imgc[i + 1]
        local a = bit.rshift(bit.band(0xC0, v), 6)
        local b = bit.rshift(bit.band(0x30, v), 4)
        local c = bit.rshift(bit.band(0x0C, v), 2)
        local d = bit.rshift(bit.band(0x03, v), 0)

        table.insert(img, a)
        table.insert(img, b)
        table.insert(img, c)
        table.insert(img, d)
    end

    local imgd = love.image.newImageData(imgfile.width, imgfile.height)

    for y = 0, imgfile.height - 1 do
        for x = 0,  imgfile.width - 1 do
            local i = x + y * imgfile.width
            imgd:setPixel(x, y, 0.125 + img[i + 1] / 4, 0, 0)
        end
    end

    local tex = love.graphics.newImage(imgd)
    imgd:release()
    return tex
end

function math.sign(x)
    if x < 0 then return -1 end
    if x > 0 then return 1 end
    return 0
end

function math.round(x)
    return math.floor(x + 0.5)
end

function math.rem(x)
    return x - math.floor(x)
end

function math.clamp(x, a, b)
    return math.max(a, math.min(b, x))
end

function math.length(x, y)
    return math.sqrt(x * x + y * y)
end

function math.dot(x1, y1, x2, y2)
    return x1 *  x2 + y1 * y2
end

function math.norm(x, y)
    local len = math.length(x, y)
    if len == 0 then return 0, 0 end
    return x / len, y / len
end

function math.lerp(a, b, x)
    return a + (b - a) * x
end

function math.rects_overlap(ax1, ay1, aw, ah, bx1, by1, bw, bh)
    local ax2, ay2 = ax1 + aw, ay1 + ah
    local bx2, by2 = bx1 + bw , by1 + bh

    return not (ax2 < bx1) and
        not (ax1 >= bx2) and
        not (ay2 < by1) and
        not (ay1 >= by2)
end

function table.copy(src, dest)
    for key, value in pairs(src) do
        dest[key] = value
    end

    return dest
end