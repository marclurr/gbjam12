local M = {}

local paused_sources

function M.pause_all()
    print("pausing everything")
    paused_sources = love.audio.pause()
end

function M.resume_all()
    love.audio.play(paused_sources)
    paused_sources = nil
end

return M