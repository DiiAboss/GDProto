/// obj_player - Draw Event

// Draw the player sprite using your sprite handler
spriteHandler.DrawSprite(self, currentSprite);

// Draw mini HP bar (only when damaged or timer active)
if (hp < maxHp || hp_bar_visible_timer > 0) {
    draw_player_hp_bar(x, y, hp, maxHp);
}

// Flash when invincible
if (invincible && (invincible_timer div invincible_flash_speed) mod 2 == 0) {
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_red, 0.5);
}

// === TIMING SYSTEM VISUALS ===
// Draw timing circle at player feet (only when on cooldown)
if (timing_circle_alpha > 0.05) {
    var circle_color = GetTimingCircleColor();
    var circle_radius = 20 * timing_circle_scale;
    
    draw_set_alpha(timing_circle_alpha);
    
    // Outer ring
    draw_circle_color(x, y, circle_radius, circle_color, circle_color, true);
    
    // Inner fill (subtle)
    draw_set_alpha(timing_circle_alpha * 0.3);
    draw_circle_color(x, y, circle_radius - 2, circle_color, circle_color, false);
    
    draw_set_alpha(1);
}

// Perfect hit flash effect
if (perfect_flash_timer > 0) {
    var flash_alpha = perfect_flash_timer / 8;
    draw_set_alpha(flash_alpha);
    
    // Expanding ring
    var flash_size = 24 + ((8 - perfect_flash_timer) * 4);
    draw_circle_color(x, y, flash_size, c_yellow, c_orange, true);
    
    // Bright center flash
    draw_circle_color(x, y, 12, c_yellow, c_yellow, false);
    
    draw_set_alpha(1);
}

// === DEBUG INFO (Hold TAB) ===
if (keyboard_check(vk_tab)) {
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    var debug_y = y - 50;
    
    draw_text(x - 60, debug_y, "Timing: " + last_timing_quality);
    draw_text(x - 60, debug_y - 12, "Multiplier: " + string(timing_bonus_multiplier) + "x");
    draw_text(x - 60, debug_y - 24, "Perfect Hits: " + string(perfect_hits_count));
    draw_text(x - 60, debug_y - 36, "Good Hits: " + string(good_hits_count));
    draw_text(x - 60, debug_y - 48, "Early Hits: " + string(early_hits_count));
    
    // Show weapon cooldown if exists
    if (variable_struct_exists(weaponCurrent, "attack_cooldown")) {
        draw_text(x - 60, debug_y - 60, "Cooldown: " + string(weaponCurrent.attack_cooldown));
    }
    
    draw_set_color(c_white);
    draw_set_halign(fa_left);
}