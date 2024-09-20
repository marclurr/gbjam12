local stack = {}

local function get_current()
    return stack[#stack]
end

local function enter_current(...)
    local current = get_current()
    if not current or not current.enter then return end
    current.enter(...)
end

local function exit_current()
    local current = get_current()
    if not current or not current.exit then return end
    current.exit()
end

local function pause_current()
    local current = get_current()
    if not current or not current.pause then return end
    current.pause()
end

local function resume_current()
    local current = get_current()
    if not current or not current.resume then return end
    current.resume()
end

local M = {}

function M.switch(new, ...)
    exit_current()
    stack = {}
    table.insert(stack, new)
    enter_current(...)
end

function M.push(new, ...)
    pause_current()
    table.insert(stack, new)
    enter_current(...)
end

function M.pop()
    exit_current()
    table.remove(stack, #stack)
    resume_current()
end

function M.update(dt)
    local current = get_current()
    if current and current.update then
        current.update(dt)
    end
end

function M.draw()
    local current = get_current()
    if current and current.draw then
        current.draw()
    end
end


return M