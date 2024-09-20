local M = {}

function M.play(obj, animation)
    if obj.animation == animation then return end
    obj.animation = animation
    obj.animation_t = 0
    obj.animation_frame = 1
end

function M.update(dt, obj)
    if not obj.animation then return end
    obj.animation_frame = obj.animation_frame or 1
    obj.animation_t = (obj.animation_t or 0) + dt

    if obj.animation_t >= obj.animation.frame_time then
        obj.animation_t = obj.animation_t - obj.animation.frame_time
        if obj.animation.loop then
            obj.animation_frame = (obj.animation_frame % #obj.animation.frames) + 1
        else
            obj.animation_frame = math.min(#obj.animation.frames, obj.animation_frame + 1)
        end
    end

    obj.sprite = obj.animation.frames[obj.animation_frame]
end


return M