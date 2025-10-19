/// @description Draw totem with glow and prompt

// Draw base totem
draw_self();

// Draw glow if active
if (active) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(
        sprite_index,
        image_index,
        x,
        y,
        pulse_scale,
        pulse_scale,
        0,
        totem_data.color,
        0.5
    );
    gpu_set_blendmode(bm_normal);
}

// Draw interaction prompt
if (show_prompt && !active) {
    var cost = totem_data.GetScaledCost(obj_player.player_level);
    var can_afford = obj_player.gold >= cost;
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_font(fnt_default);
    
    // Background
    var text = "[E] " + totem_data.name + " - " + string(cost) + "g";
    var text_w = string_width(text) + 20;
    var text_h = string_height(text) + 10;
    
    draw_set_color(c_black);
    draw_set_alpha(0.7);
    draw_rectangle(x - text_w/2, y - sprite_height/2 - text_h - 5, 
                   x + text_w/2, y - sprite_height/2 - 5, false);
    draw_set_alpha(1);
    
    // Text
    draw_set_color(can_afford ? c_white : c_red);
    draw_text(x, y - sprite_height/2 - 10, text);
    
    draw_set_color(c_white);
}