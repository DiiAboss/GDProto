/// @description Baseball Bat - Draw Event
event_inherited(); // Call parent draw

// Draw sweet spot indicator during swing
if (swinging && instance_exists(owner)) {
    var sweet_spot_timing = (swingProgress >= sweet_spot_active_start && 
                             swingProgress <= sweet_spot_active_end);
    
    if (sweet_spot_timing) {
        // Draw sweet spot circle
        draw_set_alpha(0.3);
        draw_set_color(c_yellow);
        draw_circle(sweet_spot_x, sweet_spot_y, sweet_spot_radius, false);
        draw_set_alpha(1.0);
        draw_set_color(c_white);
    }
}

// Draw "HOME RUN!" indicator
if (hit_sweet_spot && hit_sweet_spot_timer > 0) {
    //draw_set_font(fnt_damage); // Use your damage font
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var flash_alpha = (hit_sweet_spot_timer / 90);
    draw_set_alpha(flash_alpha);
    draw_set_color(c_yellow);
    
    draw_text_transformed(owner.x, owner.y - 50, "HOME RUN!", 1.5, 1.5, 0);
    
    draw_set_alpha(1.0);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}