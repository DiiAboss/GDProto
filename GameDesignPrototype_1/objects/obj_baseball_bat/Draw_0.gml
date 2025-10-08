/// @description
/// obj_baseball_bat Draw Event
if (isSwinging) {
    // Draw motion trail
    var trail_alpha = 0.4 * (swing_progress / 100);
    var trail_angle = swing_direction + (swing_arc * ((swing_progress / 100) - 0.5) * 0.7);
    var trail_dist = 32;
    var trail_x = owner.x + lengthdir_x(trail_dist, trail_angle);
    var trail_y = owner.y + lengthdir_y(trail_dist, trail_angle);
    
    draw_sprite_ext(sprite_index, 0, trail_x, trail_y, 1, 1, trail_angle, c_white, trail_alpha);
    
    // Draw sweet spot indicator (only during active window)
    var sweet_spot_timing = (swing_progress >= sweet_spot_active_start * 100 && 
                             swing_progress <= sweet_spot_active_end * 100);
    
    if (sweet_spot_timing) {
        // Draw pulsing circle at sweet spot
        var pulse = 0.5 + 0.5 * sin(current_time * 0.02);
        draw_circle_color(sweet_spot_x, sweet_spot_y, sweet_spot_radius * pulse, 
                         c_yellow, c_orange, true);
        draw_circle_color(sweet_spot_x, sweet_spot_y, sweet_spot_radius * pulse + 2, 
                         c_yellow, c_orange, true);
    }
}

// Draw the bat
draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale, image_angle, c_white, 1);

// Show combo
if (current_combo_hit > 0 && instance_exists(owner)) {
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_text(owner.x, owner.y - 40, "Combo x" + string(current_combo_hit + 1));
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}

// Show "HOME RUN!" effect briefly
if (hit_sweet_spot) {
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_set_font(fnt_large); // Make sure you have a large font
    draw_text_transformed(owner.x, owner.y - 60, "HOME RUN!", 1.5, 1.5, 0);
    draw_set_font(-1);
    draw_set_halign(fa_left);
    draw_set_color(c_white);
    
    //// Reset after a moment
    //if (swing_progress > 90) {
        //hit_sweet_spot = false;
    //}
}