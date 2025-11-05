/// @description Optimized Enemy Spawner - Spread Over Frames
if (global.gameSpeed <= 0) exit;
// Initialize in CREATE event if not already done
if (!variable_instance_exists(id, "spawn_search_active")) {
    spawn_search_active = false;
    spawn_attempts_this_frame = 0;
    spawn_total_attempts = 0;
    tile_layer_id = layer_get_id("Tiles_2");
    tilemap_id = layer_tilemap_get_id(tile_layer_id);
}

if (spawner_timer > 0) {
    spawner_timer--;
    
    // Only search if not already searching
    if (!spawn_search_active) {
        spawn_search_active = true;
        spawn_total_attempts = 0;
        summon_timer = 60;
    }
}



// SPREAD SEARCH OVER FRAMES (only 3 attempts per frame)
if (spawn_search_active) {
    var attempts_per_frame = 3; // Low number = less lag
    var max_total_attempts = 30;
    
    var min_distance_from_player = 100;
    var spawn_radius = 256;
    
    for (var i = 0; i < attempts_per_frame; i++) {
        spawn_total_attempts++;
        
        // CLAMP TO ROOM BOUNDS (prevent outside room spawning)
        var x_min = clamp(obj_player.x - spawn_radius, 0, room_width);
        var y_min = clamp(obj_player.y - spawn_radius, 0, room_height);
        var x_max = clamp(obj_player.x + spawn_radius, 0, room_width);
        var y_max = clamp(obj_player.y + spawn_radius, 0, room_height);
        
        // Random position within clamped bounds
        var test_x = irandom_range(x_min, x_max);
        var test_y = irandom_range(y_min, y_max);
        
        // Quick distance check first (cheapest)
        var dist_to_player = point_distance(test_x, test_y, obj_player.x, obj_player.y);
        if (dist_to_player < min_distance_from_player) continue;
        
        // Tile check (moderate cost)
        var tile = tilemap_get_at_pixel(tilemap_id, test_x, test_y);
        if (tile > 446 || tile == 0) continue; // Not safe
        
        // Wall check (most expensive, do last)
        if (place_meeting(test_x, test_y, obj_obstacle)) continue;
        
        // SUCCESS - Found safe spot!
        spawn_search_active = false;
        nextX = test_x;
        nextY = test_y;
        return; // Exit early, spawn next frame
    }
    
    // Give up after max attempts
    if (spawn_total_attempts >= max_total_attempts) {
        spawn_search_active = false;
        
        // Fallback: Ring spawn around player
        var safe_dir = random(360);
        var safe_dist = min_distance_from_player + 20;
        nextX = clamp(obj_player.x + lengthdir_x(safe_dist, safe_dir), 0, room_width);
        nextY = clamp(obj_player.y + lengthdir_y(safe_dist, safe_dir), 0, room_height);
        
        show_debug_message("Spawner fallback used after " + string(spawn_total_attempts) + " attempts");
    }
}

// SPAWN ENEMY
if (!spawn_search_active && summon_timer > 0) {
    summon_timer--;
    
    if (summon_timer <= 0) {
        // Update spawn pool based on game time
        if (instance_exists(obj_game_manager)) {
            var game_time = obj_game_manager.time_manager.game_time_seconds;
            
            // Progressive enemy unlocks
            if (game_time < 60) {
                // 0-60 seconds: Basic enemies only
                current_spawn_pool = [obj_enemy, obj_maggot]; // Weight basic enemy
            }
            else if (game_time < 90) {
                // 60-90 seconds: Add triangles and flies
                current_spawn_pool = [obj_enemy, obj_maggot, obj_enemy_triangle, obj_enemy_fly];
            }
            else if (game_time < 120) {
                // 90-120 seconds: Add dashers
                current_spawn_pool = [obj_enemy, obj_enemy_triangle, obj_enemy_fly, obj_enemy_dasher];
            }
            else {
                // 120+ seconds: Everything including bombers
                current_spawn_pool = [obj_enemy, obj_enemy_triangle, obj_enemy_fly, obj_enemy_dasher, obj_enemy_bomber];
            }
        }
        
        // Pick random enemy from current pool
        var _enemy = current_spawn_pool[irandom(array_length(current_spawn_pool) - 1)];
        
        // Final safety check
        var spawn_tile = tilemap_get_at_pixel(tilemap_id, nextX, nextY);
        
        if (spawn_tile <= 446 && spawn_tile > 0 && !place_meeting(nextX, nextY, obj_obstacle)) {
            var enemy = instance_create_depth(nextX, nextY, depth, _enemy);
            if (instance_exists(obj_enemy_controller)) {
                obj_enemy_controller.ApplyDifficultyToEnemy(enemy);
            }
        }
        
        spawner_timer = 300;
    }
}