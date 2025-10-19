/// @description Draw weapon with float and shadow

// Draw shadow
draw_sprite_ext(
    spr_shadow,
    0,
    x,
    base_y + 4, // Shadow stays on ground
    shadow_scale,
    shadow_scale,
    0,
    c_white,
    shadow_alpha
);

// Draw glow
gpu_set_blendmode(bm_add);
draw_sprite_ext(
    weapon_sprite,
    0,
    x,
    y,
    1.0 + (glow_pulse * 0.1),
    1.0 + (glow_pulse * 0.1),
    0,
    c_yellow,
    glow_pulse * 0.3
);
gpu_set_blendmode(bm_normal);

// Draw weapon sprite
draw_sprite(weapon_sprite, 0, x, y);

// Draw prompt
if (show_prompt) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_font(fnt_default);
    
    var text = "[E] " + weapon_name;
    var text_w = string_width(text) + 16;
    var text_h = string_height(text) + 8;
    
    // Background
    draw_set_color(c_black);
    draw_set_alpha(0.7);
    draw_rectangle(x - text_w/2, y - sprite_height - text_h - 10,
                   x + text_w/2, y - sprite_height - 10, false);
    draw_set_alpha(1);
    
    // Texta
    draw_set_color(c_white);
    draw_text(x, y - sprite_height - 12, text);
    
    draw_set_color(c_white);
}