local textureatlas = require("textureatlas")
local tilemap = require("tilemap")

local assets = {
    textures = {},
    sprites = {},
    animations = {},
    atlases = {},
    tilemaps = {},
    music = {},
    sfx = {}
}

assets.textures.splash = LoadImg("data/gfx/splash")
assets.textures.debug = LoadImg("data/gfx/debug")
assets.textures.font_score = LoadImg("data/gfx/font_score")
assets.textures.love_logo = LoadImg("data/gfx/love-logo")

------ SPRITES ------
assets.sprites.skelly_full_1 = NewSprite(assets.textures.debug, 64, 16, 16, 16, 1)

assets.sprites.skelly_die_1 = NewSprite(assets.textures.debug, 168, 32, 18, 16, 1)
assets.sprites.skelly_die_2 = NewSprite(assets.textures.debug, 186, 32, 18, 16, 1)
assets.sprites.skelly_die_3 = NewSprite(assets.textures.debug, 204, 32, 18, 16, 1)

assets.sprites.hand_1 = NewSprite(assets.textures.debug, 80, 24, 6, 6, 1)

assets.sprites.test = NewSprite(assets.textures.debug, 8, 0, 8, 8)

assets.sprites.ghost_face_1  = NewSprite(assets.textures.debug, 16, 16, 16, 16, 3)
assets.sprites.ghost_face_2  = NewSprite(assets.textures.debug, 32, 16, 16, 16, 3)
assets.sprites.ghost_face_3  = NewSprite(assets.textures.debug, 48, 16, 16, 16, 3)

assets.sprites.switch_block_off = NewSprite(assets.textures.debug, 144, 0, 8, 8)
assets.sprites.switch_block_on = NewSprite(assets.textures.debug, 152, 0, 8, 8)

assets.sprites.switch_block_inv_off = NewSprite(assets.textures.debug, 144, 8, 8, 8)
assets.sprites.switch_block_inv_on = NewSprite(assets.textures.debug, 152, 8, 8, 8)

assets.sprites.switch = NewSprite(assets.textures.debug, 160, 8, 10, 10)

assets.sprites.ghost_1 = NewSprite(assets.textures.debug, 0, 72, 16, 13, 1)
assets.sprites.ghost_2 = NewSprite(assets.textures.debug, 16, 72, 16, 13, 1)
assets.sprites.ghost_3 = NewSprite(assets.textures.debug, 32, 72, 16, 13, 1)
assets.sprites.ghost_4 = NewSprite(assets.textures.debug, 48, 72, 16, 13, 1)
assets.sprites.ghost_stunned = NewSprite(assets.textures.debug, 64, 72, 16, 13, 1)
assets.sprites.ghost_spin_1 = NewSprite(assets.textures.debug, 64, 88, 16, 13, 1)
assets.sprites.ghost_spin_2 = NewSprite(assets.textures.debug, 80, 88, 16, 13, 1)
assets.sprites.ghost_spin_3 = NewSprite(assets.textures.debug, 96, 88, 16, 13, 1)
assets.sprites.ghost_spin_4 = NewSprite(assets.textures.debug, 112, 88, 16, 13, 1)

assets.sprites.frank_1 = NewSprite(assets.textures.debug, 80, 72, 16, 16, 1)
assets.sprites.frank_2 = NewSprite(assets.textures.debug, 96, 72, 16, 16, 1)
assets.sprites.frank_stunned = NewSprite(assets.textures.debug, 112, 72, 16, 16, 1)
assets.sprites.frank_spin_1 = NewSprite(assets.textures.debug, 128, 72, 16, 16, 1)
assets.sprites.frank_spin_2 = NewSprite(assets.textures.debug, 144, 72, 16, 16, 1)
assets.sprites.frank_spin_3 = NewSprite(assets.textures.debug, 160, 72, 16, 16, 1)
assets.sprites.frank_spin_4 = NewSprite(assets.textures.debug, 176, 72, 16, 16, 1)

assets.sprites.stars_1 = NewSprite(assets.textures.debug, 0, 88, 16, 12, 1)
assets.sprites.stars_2 = NewSprite(assets.textures.debug, 16, 88, 16, 12, 1)
assets.sprites.stars_3 = NewSprite(assets.textures.debug, 32, 88, 16, 12, 1)

assets.sprites.heart_full = NewSprite(assets.textures.debug, 48, 0, 9, 8)
assets.sprites.heart_empty = NewSprite(assets.textures.debug, 57, 0, 9, 8)

assets.sprites.pumpkin_1 = NewSprite(assets.textures.debug, 176, 16, 16, 16, 1)
assets.sprites.pumpkin_2 = NewSprite(assets.textures.debug, 192, 16, 16, 16, 1)
assets.sprites.pumpkin_3 = NewSprite(assets.textures.debug, 208, 16, 16, 16, 1)

assets.sprites.spark_1 = NewSprite(assets.textures.debug, 168, 48, 16, 16)
assets.sprites.spark_2 = NewSprite(assets.textures.debug, 184, 48, 16, 16)
assets.sprites.spark_3 = NewSprite(assets.textures.debug, 200, 48, 16, 16)
assets.sprites.spark_4 = NewSprite(assets.textures.debug, 216, 48, 16, 16)
assets.sprites.spark_5 = NewSprite(assets.textures.debug, 232, 48, 16, 16)
assets.sprites.spark_6 = NewSprite(assets.textures.debug, 232, 64, 16, 16, 1)

------ /SPRITES ------

------ ANIMATIONS  ------
assets.animations.skelly_idle = NewAnimation(1000, true, assets.sprites.skelly_full_1)
assets.animations.skelly_die = NewAnimation(0.1, false,assets.sprites.skelly_die_1, assets.sprites.skelly_die_2, assets.sprites.skelly_die_3)
assets.animations.skelly_respawn = NewAnimation(0.1, false,assets.sprites.skelly_die_3, assets.sprites.skelly_die_2, assets.sprites.skelly_die_1,assets.sprites.skelly_full_1 )


assets.animations.stars = NewAnimation(0.15, true, assets.sprites.stars_1, assets.sprites.stars_2, assets.sprites.stars_3)
assets.animations.ghost = NewAnimation(0.2, true, assets.sprites.ghost_1, assets.sprites.ghost_2, assets.sprites.ghost_3, assets.sprites.ghost_4)
assets.animations.ghost_spin = NewAnimation(0.15, true, assets.sprites.ghost_spin_1, assets.sprites.ghost_spin_2, assets.sprites.ghost_spin_3, assets.sprites.ghost_spin_4)

assets.animations.frank = NewAnimation(0.3, true, assets.sprites.frank_1, assets.sprites.frank_2)
assets.animations.frank_spin = NewAnimation(0.15, true, assets.sprites.frank_spin_1, assets.sprites.frank_spin_2, assets.sprites.frank_spin_3, assets.sprites.frank_spin_4)

assets.animations.pumpkin_spawn = NewAnimation(0.1, false, assets.sprites.pumpkin_1, assets.sprites.pumpkin_2, assets.sprites.pumpkin_3)
assets.animations.spark = NewAnimation(0.1, false, assets.sprites.spark_1, assets.sprites.spark_2, assets.sprites.spark_3, assets.sprites.spark_4, assets.sprites.spark_5, assets.sprites.spark_6)

------- /ANIMATIONS ------

assets.atlases.debug_atlas = textureatlas.new(assets.textures.debug, 8, 8)
assets.atlases.font_score = textureatlas.new(assets.textures.font_score, 8, 8)

assets.tilemaps.debug_map = function ()
    return tilemap.load("data/tilemaps/debug.lua", assets.atlases.debug_atlas)
end
assets.tilemaps.levels = function ()
    return tilemap.load("data/tilemaps/levels.lua", assets.atlases.debug_atlas)
end

return assets