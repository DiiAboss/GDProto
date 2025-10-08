/// obj_melee_parent Draw Event (Updated to match your style)

if (isSwinging) {
    // Draw motion trail
    var trail_alpha = 0.4 * (swing_progress / 100);
    var trail_offset = swing_arc * ((swing_progress / 100) - 0.5) * 0.7;
    var trail_angle = swing_direction + trail_offset;
    var trail_x = owner.x + lengthdir_x(32, trail_angle);
    var trail_y = owner.y + lengthdir_y(32, trail_angle);
    
    draw_sprite_ext(sprite_index, 0, trail_x, trail_y, 1, 1, trail_angle, c_white, trail_alpha);
    
    // Combo glow effect
    if (current_combo_hit > 0) {
        gpu_set_blendmode(bm_add);
        draw_sprite_ext(sprite_index, 0, x, y, 1.1, 1.1, image_angle, 
                       make_color_rgb(255, 200, 100), 0.3 * ((current_combo_hit + 1) / 5));
        gpu_set_blendmode(bm_normal);
    }
}

// Draw the weapon
draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale, image_angle, c_white, 1);

// Show combo counter
if (current_combo_hit > 0 && instance_exists(owner)) {
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_text(owner.x, owner.y - 40, "Combo x" + string(current_combo_hit + 1));
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}