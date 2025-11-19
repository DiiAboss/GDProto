// Draw shadow (hide during fall)

if (instance_exists(obj_death_sequence)) exit;


if (!is_falling_in_pit) {
    draw_sprite_shadow(self, spr_shadow, image_index, x, y+8, 0, 1, 0.2);
}

// Draw player sprite
if (is_falling_in_pit) {
    // FALLING ANIMATION - Manual draw with rotation and scale
    draw_sprite_ext(
        currentSprite,
        image_index,
        x,
        y,
        image_xscale, // Shrinking
        image_yscale, // Shrinking
        image_angle,  // Spinning
        c_white,
        image_alpha   // Fading
    );
} else {
    // Invincibility flash (only when not falling)
if (invincibility.ShouldFlash() && !is_falling_in_pit && just_hit > 0) {
    
}
	else {
		spriteHandler.DrawSprite(self, currentSprite);
	}
    
}

// HP bar
if (hp < maxHp || timers.IsActive("hp_bar")) {
    draw_player_hp_bar(x, y, hp, maxHp);
}

if (variable_struct_exists(weaponCurrent, "sprite"))
{
	draw_sprite_ext(weaponCurrent.sprite, 0, x, y, 1, img_xscale, mouseDirection, c_white, 1);
}
