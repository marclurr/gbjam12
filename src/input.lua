
local state = {}
local prev_state = {}
state.up = false
state.down = false
state.left = false
state.right = false
state.a = false
state.b = false
state.start = false
state.select = false


local keys_lut = {
    up = "up",
    down = "down",
    left = "left",
    right = "right",
    x = "b",
    c = "a",

    w = "up",
    s = "down",
    a = "left",
    d = "right",
    j = "b",
    k = "a",
    ["return"] = "start",
    backspace = "select"
}

local gamepad_lut = {
    dpup = "up",
    dpdown = "down",
    dpleft = "left",
    dpright = "right",
    b = "a",
    a = "b",
    x = "a",
    y = "b",
    start = "start",
    back = "select"
}

local function press(action)
    if not action then return end
    state[action] = true
end

local function release(action)
    if not action then return end
    state[action] = false
end

local M = {}

function M.update()
    for k,v in pairs(state) do
        prev_state[k] = v
    end
end

function M.discard()
    for k in pairs(state) do
        state[k] = false
        prev_state[k] = false
    end
end

function M.is_pressed(action)
    return state[action]
end

function M.is_pressed_int(action)
    return M.is_pressed(action) and 1 or 0
end

function M.is_just_pressed(action)
    return state[action] and not prev_state[action]
end

function M.is_just_released(action)
    return not state[action] and prev_state[action]
end

function love.keypressed(key, scancode)
    if debug and scancode == "escape" then return love.event.quit() end
    press(keys_lut[scancode])
end

function love.keyreleased(key, scancode)
    release(keys_lut[scancode])
end

function love.gamepadpressed(pad, button)
    press(gamepad_lut[button])
end

function love.gamepadreleased(pad, button)
    release(gamepad_lut[button])
end

return M