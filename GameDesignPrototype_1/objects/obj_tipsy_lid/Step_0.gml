// @description obj_tipsy_lid - Step Event

if (falling) {
    // Fall with acceleration
    fall_speed += fall_acceleration * game_speed_delta();
    y += fall_speed * game_speed_delta();
    
    // Rotate while falling
    image_angle += 10 * game_speed_delta();
    
    // Land
    if (y >= fall_target_y) {
        y = fall_target_y;
        falling = false;
        image_angle = 0;
        
        // Point at player and start rolling
        if (instance_exists(obj_player)) {
            myDir = point_direction(x, y, obj_player.x, obj_player.y);
        }
        mySpeed = 6;
    }
} else if (returning_to_parent && instance_exists(parent_tipsy)) {
    // Return to parent - inherit rolling ball movement
    event_inherited();
    
    var dist = point_distance(x, y, parent_tipsy.x, parent_tipsy.y);
    if (dist < 10) {
        instance_destroy();
    }
} else {
    // Normal rolling ball behavior
    event_inherited();
}