/// @desc Draw Event
// Draw falling sprite
draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

// Draw shadow on ground
if (!landed) {
    draw_sprite_ext(spr_shadow, 0, shadow_x, shadow_y, 
        shadow_scale, shadow_scale, 0, c_black, shadow_alpha);
}

// Warning indicator
if (show_warning && warning_timer > 0) {
    var pulse = abs(sin(warning_timer * 0.1)) * 0.5 + 0.5;
    draw_sprite_ext(spr_warning_target, 0, shadow_x, shadow_y,
        1, 1, 0, c_red, pulse);
}