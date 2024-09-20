local config = require("config")

local db = {}
db.menu_move = {"data/sfx/menu_move.wav", "static"}
db.menu_accept = {"data/sfx/accept.wav", "static"}

for k,v in pairs(db) do
    db[k] = love.audio.newSource(unpack(v))
end



return function(name)
    if not db[name] then return end
    local src = db[name]:clone()
    src:setVolume(config.values.sfx / 9)
    love.audio.play(src)
end
