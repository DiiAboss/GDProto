/// @description
/// @desc Draw bomb with wick

// Draw chest/bomb sprite
draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, 0, c_white, 1);

// Draw wick if lit
if (fuse_lit) {
    // Animate wick sparking
    var spark_alpha = 0.5 + sin(fuse_timer * 0.3) * 0.5;
    draw_set_color(c_orange);
    draw_set_alpha(spark_alpha);
    
    // Simple line wick (replace with sprite later)
    var wick_x = x + lengthdir_x(12, wick_angle);
    var wick_y = y + lengthdir_y(12, wick_angle) - 8;
    draw_circle(wick_x, wick_y, 2, false);
    
    draw_set_alpha(1);
}

// Debug radius
if (keyboard_check(vk_shift)) {
    draw_set_alpha(0.2);
    draw_set_color(c_red);
    draw_circle(x, y, explosion_radius, false);
    draw_set_alpha(1);
}