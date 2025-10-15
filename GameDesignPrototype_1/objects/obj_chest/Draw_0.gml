// Draw in world for IDLE, CHOICE_PROMPT, ACTIVATING states
if (state == ChestState.IDLE || state == ChestState.CHOICE_PROMPT || state == ChestState.ACTIVATING) {
    // Draw glow layer if active
    if (glow_intensity > 0.01) {
        var glow_scale = current_scale * (1 + glow_intensity * 0.3);
        var glow_alpha = glow_intensity * 0.4 * image_alpha;
        
        // Outer glow
        draw_sprite_ext(sprite_index, image_index, x, y, glow_scale, glow_scale, 0, c_yellow, glow_alpha);
        
        // Pulsing inner glow
        var pulse_glow = 0.5 + sin(current_time * 0.01) * 0.3;
        draw_sprite_ext(sprite_index, image_index, x, y, current_scale * 1.1, current_scale * 1.1, 0, c_white, glow_alpha * pulse_glow);
    }
    
    // Draw main sprite
    draw_sprite_ext(sprite_index, image_index, x, y, current_scale, current_scale, 0, c_white, image_alpha);
    
    // Draw interact prompt
    if (state == ChestState.IDLE && !choice_prompt_active && instance_exists(obj_player)) {
        var dist = point_distance(x, y, obj_player.x, obj_player.y);
        if (dist <= interact_range) {
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_font(fnt_default);
            draw_set_color(c_white);
            
            var prompt = "Press E";
            if (chest_type == ChestType.PREMIUM) {
                var cost = GetChestCost(obj_game_manager.chests_opened);
                prompt += " (" + string(cost) + " gold)";
            }
            
            draw_text(x, y - sprite_height * current_scale - 16, prompt);
        }
    }
    
    // Draw choice prompt
    if (choice_prompt_active) {
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(fnt_default);
        draw_set_color(c_white);
        
        draw_text(x, y - 40, "[1] Open Chest");
        draw_text(x, y - 20, "[2] Set Bomb Trap");
    }
}