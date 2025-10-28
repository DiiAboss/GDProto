/// @desc Draw chest on GUI layer with smooth transition

// Draw during transition and center states
if (state == ChestState.MOVING_CENTER || state == ChestState.BURSTING || state == ChestState.SHOWING_REWARDS) {
    var gui_center_x = display_get_gui_width() / 2;
    var gui_center_y = (display_get_gui_height() / 2) - 60;
    
    // Calculate current position based on transition progress
    var current_x = gui_center_x;
    var current_y = gui_center_y;
    
    if (state == ChestState.MOVING_CENTER) {
        // Smooth lerp from start position to center
        current_x = lerp(transition_start_x, gui_center_x, transition_progress);
        current_y = lerp(transition_start_y, gui_center_y, transition_progress);
        
        // Add a slight ease-out curve
        var ease_progress = 1 - power(1 - transition_progress, 3);
        current_x = lerp(transition_start_x, gui_center_x, ease_progress);
        current_y = lerp(transition_start_y, gui_center_y, ease_progress);
    }
    
    // Draw layered glow effect
    if (glow_intensity > 0.01) {
        // Outer glow ring
        var outer_glow_scale = current_scale * (1 + glow_intensity * 0.5);
        var outer_glow_alpha = glow_intensity * 0.3 * image_alpha;
        draw_sprite_ext(
            sprite_index, 
            image_index, 
            current_x, 
            current_y, 
            outer_glow_scale, 
            outer_glow_scale, 
            0, 
            c_orange, 
            outer_glow_alpha
        );
        
        // Middle glow
        var mid_glow_scale = current_scale * (1 + glow_intensity * 0.3);
        var pulse = 0.5 + sin(current_time * 0.008) * 0.5;
        draw_sprite_ext(
            sprite_index, 
            image_index, 
            current_x, 
            current_y, 
            mid_glow_scale, 
            mid_glow_scale, 
            0, 
            c_yellow, 
            glow_intensity * 0.5 * pulse * image_alpha
        );
        
        // Inner bright glow
        var inner_pulse = 0.6 + sin(current_time * 0.012) * 0.4;
        draw_sprite_ext(
            sprite_index, 
            image_index, 
            current_x, 
            current_y, 
            current_scale * 1.05, 
            current_scale * 1.05, 
            0, 
            c_white, 
            glow_intensity * 0.6 * inner_pulse * image_alpha
        );
    }
    
    //// Draw main chest sprite
    //draw_sprite_ext(
        //sprite_index, 
        //image_index, 
        //current_x, 
        //current_y, 
        //current_scale, 
        //current_scale, 
        //0, 
        //c_white, 
        //image_alpha
    //);
    
    // Extra burst effect during BURSTING state
    if (state == ChestState.BURSTING && burst_timer < 15) {
        var burst_glow_scale = current_scale * (1.3 + (burst_timer / 15) * 0.5);
        var burst_alpha = (1 - burst_timer / 15) * 0.5 * image_alpha;
        
        draw_sprite_ext(
            sprite_index, 
            image_index, 
            current_x, 
            current_y, 
            burst_glow_scale, 
            burst_glow_scale, 
            burst_timer * 10, // Slight rotation
            c_yellow, 
            burst_alpha
        );
    }
}