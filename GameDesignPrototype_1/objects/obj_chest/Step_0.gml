if (state == ChestState.IDLE) {
    if (!interactable) exit;
    
    // Check player distance
    if (instance_exists(obj_player)) {
        var dist = point_distance(x, y, obj_player.x, obj_player.y);
        
        if (dist <= interact_range) {
            target_scale = base_scale * 1.1;
            
            if (keyboard_check_pressed(ord("E"))) {
                // Check if player has bomb mod
                if (HasBombMod(obj_player)) {
                    state = ChestState.CHOICE_PROMPT;
                    ShowChoicePrompt();
                } else {
                    // Go straight to opening
                    BeginOpening();
                }
            }
        } else {
            target_scale = base_scale;
        }
    }
    
    current_scale = lerp(current_scale, target_scale, 0.15);
}

else if (state == ChestState.CHOICE_PROMPT) {
    // Simple keyboard choice (you can make this fancier)
    if (keyboard_check_pressed(ord("1"))) {
        // Open chest
        choice_prompt_active = false;
        BeginOpening();
    }
    else if (keyboard_check_pressed(ord("2"))) {
        // Convert to bomb
        choice_prompt_active = false;
        ConvertToBomb();
    }
}

else if (state == ChestState.ACTIVATING) {
    activation_timer++;
    
    // Pulse effect
    pulse_scale = 1 + sin(activation_timer * 0.4) * 0.15;
    current_scale = base_scale * pulse_scale;
    
    // Glow builds up
    glow_intensity = lerp(glow_intensity, 1, 0.08);
    
    // Slow down game speed
    var slowdown_progress = activation_timer / activation_duration;
    global.gameSpeed = lerp(1.0, 0.0, slowdown_progress);
    
    // Pushback at start
    if (activation_timer == 10) {
        PushbackEnemies(x, y, pushback_radius, pushback_force);
        DestroyAllProjectiles();
    }
    
    // Transition to next state
    if (activation_timer >= activation_duration) {
        state = ChestState.MOVING_CENTER;
        move_timer = 0;
        transition_progress = 0;
        
        // Capture screen position at this moment for smooth transition
        // Convert world position to GUI position
        if (instance_exists(obj_player) && instance_exists(obj_player.camera)) {
            var cam = obj_player.camera;
            // Get camera view position
            var view_x = camera_get_view_x(view_camera[0]);
            var view_y = camera_get_view_y(view_camera[0]);
            
            // Convert chest world position to GUI position
            transition_start_x = (x - view_x) * (display_get_gui_width() / camera_get_view_width(view_camera[0]));
            transition_start_y = (y - view_y) * (display_get_gui_height() / camera_get_view_height(view_camera[0]));
        } else {
            // Fallback if no camera
            transition_start_x = display_get_gui_width() / 2;
            transition_start_y = display_get_gui_height() / 2;
        }
    }
}

else if (state == ChestState.MOVING_CENTER) {
    move_timer++;
    
    // Progress the transition (0 to 1)
    transition_progress = min(transition_progress + 0.05, 1);
    
    // Scale up slightly during this phase
    current_scale = lerp(current_scale, base_scale * 1.3, 0.1);
    
    // Intensify glow
    glow_intensity = lerp(glow_intensity, 1.5, 0.1);
    
    // Transition after reaching center
    if (transition_progress >= 0.99 || move_timer >= 30) {
        state = ChestState.BURSTING;
        burst_timer = 0;
        
        // Camera shake based on rarity
        if (instance_exists(obj_player)) {
            var shake_amount = GetChestShakeIntensity(chest_rewards);
            obj_player.camera.add_shake(shake_amount);
        }
    }
}

else if (state == ChestState.MOVING_CENTER) {
    move_timer++;
    
    // Don't actually move the chest, just prepare for GUI drawing
    // The chest will be drawn on the GUI layer in the center
    
    // Scale up slightly during this phase
    current_scale = lerp(current_scale, base_scale * 2.5, 0.1);
    
    // Transition after delay
    if (move_timer >= 30) {
        state = ChestState.BURSTING;
        burst_timer = 0;
        
        // Camera shake based on rarity
        if (instance_exists(obj_player)) {
            var shake_amount = GetChestShakeIntensity(chest_rewards);
            obj_player.camera.add_shake(shake_amount);
        }
    }
}

else if (state == ChestState.BURSTING) {
    burst_timer++;
    
    // Pop animation
    if (burst_timer < 15) {
        current_scale = lerp(current_scale, base_scale * 4.0, 0.2);
    } else if (burst_timer == 15) {
        // Burst!
        // Optional: create burst particles here
        
        // Show rewards popup
        ShowRewardsPopup();
        state = ChestState.SHOWING_REWARDS;
    }
}

else if (state == ChestState.SHOWING_REWARDS) {
    // Waiting for popup to finish
    // Check if popup is done
    if (!variable_global_exists("chest_popup") || global.chest_popup == undefined) {
        // Popup finished, start closing
        state = ChestState.CLOSING;
        closing_timer = 0;
    }
}

else if (state == ChestState.CLOSING) {
    closing_timer++;
    
    // Fade out quickly
    image_alpha = lerp(image_alpha, 0, 0.2);
    current_scale = lerp(current_scale, 0, 0.2);
    glow_intensity = lerp(glow_intensity, 0, 0.25); // Fade glow too
    
    // Restore game speed
    global.gameSpeed = lerp(global.gameSpeed, 1.0, 0.15);
    
    if (closing_timer > 20 || image_alpha < 0.05) {
        global.gameSpeed = 1.0; // Force restore
        instance_destroy();
    }
}