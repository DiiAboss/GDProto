/// @description Update position and check for player

// Follow parent object
if (follow_parent && instance_exists(parent_object)) {
    x = parent_object.x + offset_x;
    y = parent_object.y + offset_y;
} else if (!instance_exists(parent_object)) {
    // Parent destroyed, clean up
    instance_destroy();
    exit;
}

// Check if player is in range
player_in_range = false;
if (instance_exists(obj_player) && can_interact) {
	if (obj_player.can_interact > 0) exit;
    var dist = point_distance(x, y, obj_player.x, obj_player.y);
    player_in_range = (dist <= activation_radius);
}

// Update visibility
show_prompt = player_in_range;
target_alpha = show_prompt ? 1 : 0;
alpha = lerp(alpha, target_alpha, alpha_lerp_speed);

// Floating animation
if (show_prompt) {
    float_timer += float_speed;
    display_offset_y = sin(float_timer) * float_amplitude;
}

// Handle interaction input
if (player_in_range && can_interact) {
    if (instance_exists(obj_player)) {
        var input = obj_player.input;
        
        // Check for Action button press
        if (input.Action) {
            ExecuteAction();
        }
    }
}