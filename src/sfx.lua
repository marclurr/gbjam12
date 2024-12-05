local config = require("config")

local db = {}
db.menu_move = {"data/sfx/menu_move.wav", "static", 2}
db.menu_accept = {"data/sfx/accept.wav", "static", 1}
db.jump = {"data/sfx/jump.wav", "static", 3}
db.dink = {"data/sfx/dink.wav", "static", 2}
db.activate = {"data/sfx/activate.wav", "static", 1}
db.player_die = {"data/sfx/player_die.wav", "static", 1}
db.throw = {"data/sfx/throw.wav", "static", 2}
db.collect = {"data/sfx/collect.wav", "static", 1}
db.hit = {"data/sfx/hit.wav", "static", 2}

for k,v in pairs(db) do
    local sources = {}
    local file, type, count = unpack(v)
    local source = love.audio.newSource(file, type)

    table.insert(sources, source)

    for i = 1, count - 1 do
        table.insert(sources, source:clone())
    end

    db[k] = sources
end


local playing

return function(name, force)
    if not db[name] then return end

    if playing and playing:isPlaying() then
        playing:stop()
    end
    local sources = db[name]
    local source = sources[1]
    source:setVolume(config.values.sfx / 9)
    playing = source
    local result = love.audio.play(source)

    print("playing ", name, result)
end
