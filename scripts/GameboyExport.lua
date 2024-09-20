local sprite = app.activeSprite


assert(app.params.filename, "set filename with --script-param filename=name")

local function exportFrame(frm)
    if frm == nil then
        frm = 1
    end

    local img = Image(sprite)

    local getpx = function(i)
        if i >= sprite.width*sprite.height then return 0 end
        local x = i % sprite.width
        local y = math.floor(i / sprite.width)
        return img:getPixel(x, y)
    end

    local result = {}


    local res = ""
    for i = 0, (sprite.width*sprite.height) -1, 4 do
        local a = getpx(i)
        local b = getpx(i + 1)
        local c = getpx(i + 2)
        local d = getpx(i + 3)

        local val = (a << 6) | (b << 4) | (c << 2) | d

        res = res .. string.format("0x%02x", val) .. ","
    end

    io.write(string.format("return { width = %d, height = %d, data = { %s }}", sprite.width, sprite.height, res))

    return result
end

local all = {}
for m in string.gmatch(sprite.filename, "[^.]+") do
    table.insert(all, m)
end
table.remove(all, #all)

local filename = table.concat(all, ".")

print(string.format("Generating [%s] from [%s]", app.params.filename, sprite.filename ))

local f = io.open(app.params.filename, "w")
io.output(f)

exportFrame(app.activeFrame)

io.close(f)

