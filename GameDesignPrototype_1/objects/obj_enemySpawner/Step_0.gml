/// @description Enemy Spawner with Safe Tile & Distance Checking

if (spawner_timer > 0) {
    x_min = obj_player.x - 256;
    y_min = obj_player.y - 256;
    x_max = obj_player.x + 256;
    y_max = obj_player.y + 256;
    
    spawner_timer--;
    
    // Find safe spawn position
    var found_safe_spot = false;
    var attempts = 0;
    var max_attempts = 20; // Try 20 times to find a safe spot
    
    var min_distance_from_player = 100; // Don't spawn too close to player
    
    // Tilemap reference
    var tile_layer_id = layer_get_id("Tiles_2");
    var tilemap_id = layer_tilemap_get_id(tile_layer_id);
    
    while (!found_safe_spot && attempts < max_attempts) {
        attempts++;
        
        // Random position
        var test_x = irandom_range(x_min, x_max);
        var test_y = irandom_range(y_min, y_max);
        
        // Check distance from player
        var dist_to_player = point_distance(test_x, test_y, obj_player.x, obj_player.y);
        
        if (dist_to_player < min_distance_from_player) {
            continue; // Too close, try again
        }
        
        // Check if tile is safe (not pit, not 0)
        var tile = tilemap_get_at_pixel(tilemap_id, test_x, test_y);
        var is_safe_tile = (tile <= 446 && tile != 0);
        
        if (!is_safe_tile) {
            continue; // Pit detected, try again
        }
        
        // Check for wall collision
        if (place_meeting(test_x, test_y, obj_obstacle)) {
            continue; // Wall detected, try again
        }
        
        // All checks passed!
        found_safe_spot = true;
        nextX = test_x;
        nextY = test_y;
    }
    
    // If no safe spot found after max attempts, spawn at player position + offset
    if (!found_safe_spot) {
        var safe_dir = random(360);
        nextX = obj_player.x + lengthdir_x(min_distance_from_player, safe_dir);
        nextY = obj_player.y + lengthdir_y(min_distance_from_player, safe_dir);
        show_debug_message("WARNING: Could not find safe spawn spot, using fallback position");
    }
    
    summon_timer = 60;
}
else {
    if (summon_timer > 0) {
        summon_timer--;
    }
    else {
        nextType = irandom(4);
        var _enemy = obj_enemy;
        
        switch(nextType) {
            case ENEMY_TYPE.CIRCLE:
                _enemy = obj_enemy;
                break;
            
            case ENEMY_TYPE.TRIANGLE:
                _enemy = obj_enemy_triangle;
                break;
            
            case ENEMY_TYPE.JUMPER:
                _enemy = obj_enemy_fly;
                break;
            
            case ENEMY_TYPE.DASHER:
                _enemy = obj_enemy_dasher;
                break;
            
            case ENEMY_TYPE.BOMBER:
                _enemy = obj_enemy_bomber;
                break;
        }
        
        // Final safety check before spawning
        var tile_layer_id = layer_get_id("Tiles_2");
        var tilemap_id = layer_tilemap_get_id(tile_layer_id);
        var spawn_tile = tilemap_get_at_pixel(tilemap_id, nextX, nextY);
        
        // Only spawn if tile is safe
        if (spawn_tile <= 446 && spawn_tile != 0 && !place_meeting(nextX, nextY, obj_obstacle)) {
            var enemy = instance_create_depth(nextX, nextY, depth, _enemy);
            show_debug_message("Spawned " + object_get_name(_enemy) + " at safe position");
        } else {
            show_debug_message("WARNING: Spawn position became unsafe, skipping spawn");
        }
        
        spawner_timer = 300;
    }
}