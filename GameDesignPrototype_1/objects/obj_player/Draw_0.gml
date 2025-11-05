// Draw shadow (hide during fall)
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
    // NORMAL DRAW
    spriteHandler.DrawSprite(self, currentSprite);
}

// HP bar
if (hp < maxHp || timers.IsActive("hp_bar")) {
    draw_player_hp_bar(x, y, hp, maxHp);
}

// Invincibility flash (only when not falling)
if (invincibility.ShouldFlash() && !is_falling_in_pit) {
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_red, 0.5);
}

// CLASS-SPECIFIC VISUALS (only when not falling)
if (!is_falling_in_pit) {
    class_component.Draw(x, y);
}

// Timing visuals (only when not falling)
if (timing_circle_alpha > 0.05 && !is_falling_in_pit) {
    var circle_color = GetTimingCircleColor();
    var circle_radius = 20 * timing_circle_scale;
    
    draw_set_alpha(timing_circle_alpha);
    draw_circle_color(x, y, circle_radius, circle_color, circle_color, true);
    draw_set_alpha(timing_circle_alpha * 0.3);
    draw_circle_color(x, y, circle_radius - 2, circle_color, circle_color, false);
    draw_set_alpha(1);
}

if (perfect_flash_timer > 0 && !is_falling_in_pit) {
    var flash_alpha = perfect_flash_timer / 8;
    draw_set_alpha(flash_alpha);
    
    var flash_size = 24 + ((8 - perfect_flash_timer) * 4);
    draw_circle_color(x, y, flash_size, c_yellow, c_orange, true);
    draw_circle_color(x, y, 12, c_yellow, c_yellow, false);
    
    draw_set_alpha(1);
}

// Debug
if (keyboard_check(vk_tab)) {
    var info = class_component.GetDisplayInfo();
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    var debug_y = y - 50;
    
    draw_text(x - 60, debug_y, info.name + " - " + info.special);
    draw_text(x - 60, debug_y - 12, "HP: " + string(floor(hp)) + "/" + string(maxHp));
}