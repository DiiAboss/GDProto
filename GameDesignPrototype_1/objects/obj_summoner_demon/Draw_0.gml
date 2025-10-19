/// @description Draw summoner with health bar

// Hit flash effect - just change blend color
if (hitFlashTimer > 0) {
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_red, 0.5);
}

// Draw self normally
draw_self();

// Draw health bar when damaged
if (hp < maxHp) {
    var bar_width = 48;
    var bar_height = 6;
    var bar_x = x - bar_width / 2;
    var bar_y = y - sprite_height / 2 - 12;
    
    // Background
    draw_set_color(c_black);
    draw_rectangle(bar_x - 1, bar_y - 1, bar_x + bar_width + 1, bar_y + bar_height + 1, false);
    
    // Red background
    draw_set_color(c_red);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);
    
    // Green health
    var hp_percent = hp / maxHp;
    draw_set_color(c_lime);
    draw_rectangle(bar_x, bar_y, bar_x + (bar_width * hp_percent), bar_y + bar_height, false);
    
    // Border
    draw_set_color(c_white);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, true);
    
    draw_set_color(c_white);
}