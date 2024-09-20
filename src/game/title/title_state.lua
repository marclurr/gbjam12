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
    "arcade",
    "casual",
    "options",
    "credits"
}

local handlers = {
    function ()
        gamestate.switch(PlayingState, MODE_ARCADE)
    end,

    function ()
        gamestate.switch(PlayingState, MODE_CASUAL)
    end,

    function ()
        gamestate.switch(OptionsState)
    end,

    function ()
        gamestate.switch(CreditsState)
    end
}

local selected = 1
local locked = false

local M = {}



function M.enter()
    selected = 1
    locked = false
    M.palette = 0
end

function M.update(dt)
    tweens.update(dt)
    if locked then return end
    up_y = 92
    down_y = 109

    if input.is_just_pressed("up") then
        up_y = 90
        selected = selected - 1
        sfx("menu_move")
    elseif input.is_just_pressed("down") then
        down_y = 111
        selected = selected + 1
        sfx("menu_move")
    elseif input.is_just_pressed("start") or input.is_just_pressed("a") then
        tweens.new_tween(M, "palette", 0, 4, 1).on_complete = handlers[selected]
        locked = true
        sfx("menu_accept")
    end



    if selected == 0 then selected = #options end
    if selected > #options then selected = 1 end
end

function M.draw()
    gfx.cls()

    local pal = pals[math.floor(M.palette) + 1]
    for i = 1, #pal do
        gfx.pal(i - 1, pal[i])
    end

    gfx.rectangle("fill", 8, 8, WIDTH - 16, 64,  3)
    gfx.rectangle("line", 16, 16, WIDTH - 32, 64 -16,  0)
    print_centre("[", up_y)
    print_centre(options[selected], 100)
    print_centre("\\", down_y)


    gfx.pal()
end

return M

--[[
--------------------
   Palette    <1>
   Scale      <6>
   Music      <10>
   Sfx        <10>
   ]]