/// @description
/// @desc Totem shop interaction

if (!interactable) exit;

// Glow animation
glow_timer += 0.05 * game_speed_delta();
glow_alpha = 0.5 + sin(glow_timer) * 0.3;

if (instance_exists(obj_player)) {
    var dist = point_distance(x, y, obj_player.x, obj_player.y);
    
    if (dist <= interact_range) {
        // Show menu toggle
        if (keyboard_check_pressed(ord("E"))) {
            show_menu = !show_menu;
            if (show_menu) {
                selected_index = 0;
            }
        }
        
        // Menu navigation
        if (show_menu) {
            if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
                selected_index = max(0, selected_index - 1);
            }
            if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
                selected_index = min(array_length(available_totems) - 1, selected_index + 1);
            }
            
            // Purchase totem
            if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
                var totem_type = available_totems[selected_index];
                var success = ActivateTotem(totem_type, obj_player);
                
                if (success) {
                    // Optional: close menu after purchase
                    // show_menu = false;
                }
            }
            
            // Close menu
            if (keyboard_check_pressed(vk_escape)) {
                show_menu = false;
            }
        }
    } else {
        // Too far, close menu
        if (show_menu) {
            show_menu = false;
        }
    }
}

depth = -y;