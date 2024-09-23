local config = require("config")
local tweens = require("tweens")

local M = {}

local current_track

function M.play(track)
    M.stop()

    current_track = track
    current_track:setVolume(config.values.music / 9)
    current_track:setLooping(true)
    love.audio.play(current_track)
end

function M.stop()
    if current_track and current_track:isPlaying() then
        current_track:stop()
    end
end

function M.fadeout(t)
    tweens.new_tween(current_track, current_track.setVolume, current_track:getVolume(), 0, t)
end

return M