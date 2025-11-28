/// @description Insert description here
// You can write your code in this editor
/// @desc Float and collect

timer++;

if (speed > 1)
{
	speed = speed * 0.9;
}
else
{
	speed = 0;
}

// Float physics
if (!being_collected) {
    z += z_velocity;
    z_velocity += gravity_z;
    
    if (z > 0) {
        z = 0;
        z_velocity = -z_velocity * 0.5; // Bounce
    }
    
    // Check for player collection
    if (instance_exists(obj_player)) {
        var dist = point_distance(x, y, obj_player.x, obj_player.y);
        
        if (dist < collect_radius) {
            being_collected = true;
        }
    }
} else {
    // Magnet to player
    if (instance_exists(obj_player)) {
        var dir = point_direction(x, y, obj_player.x, obj_player.y);
        x += lengthdir_x(magnet_speed, dir);
        y += lengthdir_y(magnet_speed, dir);
        
        var dist = point_distance(x, y, obj_player.x, obj_player.y);
        if (dist < 16) {
            // Collected!
            AddSouls(soul_value);
            
            // Spawn collection effect
            if (instance_exists(obj_game_manager) && variable_instance_exists(obj_game_manager, "_audio_system")) {
                obj_game_manager._audio_system.PlaySFX(snd_menu_hover); // Use coin/collect sound
            }
            
            
            
            instance_destroy();
        }
    }
}

// Fade out near end of life
if (timer > lifetime - 60) {
    alpha = (lifetime - timer) / 60;
}

// Destroy after lifetime
if (timer >= lifetime && !being_collected) {
    instance_destroy();
}