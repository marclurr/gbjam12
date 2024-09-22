local system = require("love.system")
require("const")

function love.conf(t)
    local scale = love.system.getOS() == "Web" and 3 or 1
    t.identity = "skellys_skirmish"
    t.window.title = "gbjam12"
    t.window.width = WIDTH * scale
    t.window.height = HEIGHT * scale
    t.window.vsync = 1
    t.window.resizeable = false
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop"

end