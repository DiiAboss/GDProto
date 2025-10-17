// ==========================================
// STEP EVENT
// ==========================================

switch (state) {
    case ChestState.IDLE:
        // Check player distance
        if (interactable && instance_exists(obj_player)) {
            var dist = point_distance(x, y, obj_player.x, obj_player.y);
            
            if (dist <= interact_range) {
                target_scale = base_scale * 1.1;
                
                if (keyboard_check_pressed(ord("E"))) {
                    // Check for bomb mod choice
                    if (HasBombMod(obj_player)) {
                        state = ChestState.CHOICE_PROMPT;
                    } else {
                        BeginOpening();
                    }
                }
            } else {
                target_scale = base_scale;
            }
        }
        
        current_scale = lerp(current_scale, target_scale, 0.15);
        break;
        
    case ChestState.CHOICE_PROMPT:
        // Simple choice: 1 = Open, 2 = Bomb
        if (keyboard_check_pressed(ord("1"))) {
            BeginOpening();
        } else if (keyboard_check_pressed(ord("2"))) {
            ConvertToBomb();
        }
        break;
        
    case ChestState.OPENING:
        // Just visual effects - game manager handles timing
        current_scale = lerp(current_scale, base_scale * 1.5, 0.1);
        glow_intensity = lerp(glow_intensity, 1.5, 0.1);
        
        // After a short delay, show rewards
        // (or let game_manager tell us when via a trigger)
        // For now, simple timer:
        if (!variable_instance_exists(id, "open_timer")) {
            open_timer = 0;
        }
        open_timer++;
        
        if (open_timer >= 30) { // 0.5 seconds
            ShowRewards();
        }
        break;
        
    case ChestState.SHOWING_REWARDS:
        // Wait for popup to finish
        if (!variable_global_exists("chest_popup") || global.chest_popup == undefined) {
            CloseChest();
        }
        break;
        
    case ChestState.CLOSING:
        // Fade out
        image_alpha = lerp(image_alpha, 0, 0.2);
        current_scale = lerp(current_scale, 0, 0.2);
        glow_intensity = lerp(glow_intensity, 0, 0.25);
        
        if (!variable_instance_exists(id, "close_timer")) {
            close_timer = 0;
        }
        close_timer++;
        
        if (close_timer > 20 || image_alpha < 0.05) {
            instance_destroy();
        }
        break;
}

depth = -y;