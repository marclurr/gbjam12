local assets = require("game.assets")
local gfx = require("graphics")

local objects = {}
objects.player = {
    x = WIDTH / 2, y = HEIGHT / 2,
    dx = 0, dy = 0,
    cx = 2, cy = 0, cwidth = 7, cheight = 7,
    sprite = assets.sprites.skelly_full_1,
    animation = assets.animations.skelly_idle

}

objects.arm = {
    cx = 0, cy = 0, cwidth = 6, cheight = 6,
    dx = 0, dy = 0,
    type = COL_ARM,
}

objects.switch_block = {
    name = "switch_block",
    cx = 0, cy = 0, cwidth = 8, cheight = 8,
    type = COL_SWITCH_BLOCK,
    draw = function (self, world)
        if world.blocks_on then
            gfx.draw_sprite(assets.sprites.switch_block_on, self.x, self.y)
        else
            gfx.draw_sprite(assets.sprites.switch_block_off, self.x, self.y)
        end
    end
}

objects.switch_block_inv = {
    name = "switch_block_inv",
    cx = 0, cy = 0, cwidth = 8, cheight = 8,
    type = COL_SWITCH_BLOCK_INV,
    draw = function (self, world)
        if not world.blocks_on then
            gfx.draw_sprite(assets.sprites.switch_block_inv_on, self.x, self.y)
        else
            gfx.draw_sprite(assets.sprites.switch_block_inv_off, self.x, self.y)
        end
    end
}

objects.switch = {
    name = "switch",
    oy = -2,
    cx = 0, cy = 0, cwidth = 9, cheight = 8,
    type = COL_INTERACT,
    sprite = assets.sprites.switch,
    flash = 0,
    interact = function (self, world)
        world.blocks_on = not world.blocks_on
        self.flash = 4
    end,

    draw = function (self, world)
        gfx.pal()
        if self.flash > 0 then
            -- gfx.mpal(1, 2)
            gfx.pal(2, 3)
        end
        self.flash = math.max(0, self.flash - 1)
        gfx.draw_sprite(self.sprite, self.x-1, self.y)
        gfx.pal()
    end
}

objects.ghost = {
    cx = 5, cy = 2, cwidth = 11, cheight = 10,
    dx = 0, dy = 0,
    type = COL_ENEMY, enemy_type = "ghost",
    stunned_sprite = assets.sprites.ghost_stunned,
    sprite = assets.sprites.ghost_1,
    animation = assets.animations.ghost,
    dead_animation = assets.animations.ghost_spin,
}

objects.frank = {
    cx = 3, cy = 4, cwidth = 11, cheight = 12,
    oy = 4,
    dx = 0, dy = 0,
    type = COL_ENEMY, enemy_type = "frank",
    dir = 1,
    stunned_sprite = assets.sprites.frank_stunned,
    sprite = assets.sprites.frank_1,
    animation = assets.animations.frank,
    dead_animation = assets.animations.frank_spin,
}

objects.pumpkin = {
    cx = 1, cy = 1, cwidth = 14, cheight = 14,
    type = COL_PICKUP,
    sprite = assets.sprites.pumpkin_1,
    animation = assets.animations.pumpkin_spawn,
    age = 0, visible = true
}

local tile_mappings = {}
tile_mappings[COL_SWITCH_BLOCK] = "switch_block"
tile_mappings[COL_SWITCH_BLOCK_INV] = "switch_block_inv"
tile_mappings[COL_SWITCH] = "switch"
tile_mappings[COL_GHOST] = "ghost"
tile_mappings[COL_FRANK] = "frank"

local M = {}

function M.make_from_tile(type, x, y)
    return M.make(tile_mappings[type], x, y)
end

function M.make(type, x, y)
    if not objects[type] then return nil end
    local prototype = objects[type]
    local obj = table.copy(prototype, {})
    obj.x = x + (prototype.ox or 0)
    obj.y = y + (prototype.oy or 0)

    return obj
end

return M