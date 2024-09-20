local config = require("config")
local gfx = require("graphics")
local sfx = require("sfx")
local input = require("input")
local print2 = require("print2")
local gamestate = require("gamestate")
local tweens = require("tweens")

local function print_centre(text, y, col)
    local x = WIDTH / 2 - (#text / 2) * 8
    print2(text, x, y, col)
end

local up_y = 92
local down_y = 109

local options = {
    { string.format("%-9s%s", "palette", "%d"), "palette", config.set_palette, 0, 3},
    { string.format("%-9s%s", "scale", "%d"), "scale", config.set_scale, 1, 6 },
    { string.format("%-9s%s", "music", "%d"), "music", config.set_music, 0, 9 },
    { string.format("%-9s%s", "sfx", "%d"), "sfx", config.set_sfx, 0, 9 },
}

if love.system.getOS() == "Web" then
    table.remove(options, 2)
end

local handlers = {
    function ()
        gamestate.switch(PlayingState, MODE_ARCADE)
    end,

    function ()
        gamestate.switch(PlayingState, MODE_CASUAL)
    end
}

local selected = 1
local left_pressed = 0
local right_pressed = 0
local locked = false

local M = {}



function M.enter()
    selected = 1
    locked = false
    M.palette = 0
end

function M.update(dt)
    tweens.update(dt)
    local left_pressed = 0
    local right_pressed = 0

    if locked then return end


    if input.is_just_pressed("up") then
        up_y = 90
        selected = selected - 1
        sfx("menu_move")
    elseif input.is_just_pressed("down") then
        down_y = 111
        selected = selected + 1
        sfx("menu_move")
    elseif input.is_just_pressed("left") then
        if selected <= #options then
            local _, field, setter, min, max = unpack(options[selected])
            setter(math.max(min, config.values[field] - 1))
        end
        sfx("menu_move")
    elseif input.is_just_pressed("right") then
        if selected <= #options then
            local _, field, setter, min, max = unpack(options[selected])
            setter(math.min(max, config.values[field] + 1))
        end
        sfx("menu_move")
    elseif selected == #options+1  and
        (input.is_just_pressed("start") or input.is_just_pressed("a")) then
        tweens.new_tween(M, "palette", 0, 4, 1).on_complete = function() gamestate.switch(TitleState) end
        locked = true
        config.persist()
        sfx("menu_accept")
    elseif input.is_just_pressed("b") then
        tweens.new_tween(M, "palette", 0, 4, 1).on_complete = function() gamestate.switch(TitleState) end
        locked = true
        config.persist()
        sfx("menu_accept")
    end



    if selected == 0 then selected = #options + 1 end
    if selected > #options + 1 then selected = 1 end
end

function M.draw()
    gfx.cls()

    local pal = pals[math.floor(M.palette) + 1]
    for i = 1, #pal do
        gfx.pal(i - 1, pal[i])
    end


    for i = 1, #options do
        local fmt, field = unpack(options[i])
        print_centre(string.format(fmt, config.values[field]), 44 + (i - 1) * 12)
    end

    print_centre("         :", 44 + ( #options) * 12)
    local cursor_y = 44 + (selected - 1) * 12
    print2("<", 104, cursor_y)
    print2(">", 120, cursor_y)


    gfx.pal()
end

return M

