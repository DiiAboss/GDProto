/// @desc Step Event
var _delta = game_speed_delta();

if (warning_timer > 0) {
    warning_timer -= _delta;
    // Object stays at top during warning
    return;
}

if (!landed) {
    fall_speed += fall_acceleration * _delta;
    y += fall_speed * _delta;
    
    // Check ground collision (tile or y position)
    var tile = tilemap_get_at_pixel(tilemap_id, shadow_x, shadow_y);
    var is_ground = (tile <= 446 && tile != 0);
    
    if (y >= shadow_y && is_ground) {
        landed = true;
        
        // Spawn actual object
        instance_create_depth(shadow_x, shadow_y, -100, spawn_on_land);
        
        // Impact VFX
        spawn_death_particles(x, y, [c_red, c_white]);
        
        // Shake
        if (instance_exists(obj_player)) {
            obj_player.camera.add_shake(4);
        }
        
        instance_destroy();
    }
}
