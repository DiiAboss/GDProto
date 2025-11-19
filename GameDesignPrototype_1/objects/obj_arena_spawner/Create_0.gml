/// @description Insert description here
// You can write your code in this editor
/// @desc obj_arena_spawner Create Event

// Reference to arena controller
arena_controller = obj_arena_controller;

// Spawn settings
spawn_cooldown = 0;
spawn_cooldown_max = 30; // Faster spawning than normal

// Tilemap
tile_layer_id = layer_get_id("Tiles_2");
tilemap_id = layer_tilemap_get_id(tile_layer_id);

/// @function SpawnArenaEnemy()
function SpawnArenaEnemy() {
    var spawn_x = 0;
    var spawn_y = 0;
    var attempts = 0;
    var max_attempts = 20;
    
    // Find safe spawn point
    while (attempts < max_attempts) {
        spawn_x = random_range(100, room_width - 100);
        spawn_y = random_range(100, room_height - 100);
        
        // Check if safe
        var tile = tilemap_get_at_pixel(tilemap_id, spawn_x, spawn_y);
        var is_safe = (tile <= 446 && tile != 0);
        var far_from_player = point_distance(spawn_x, spawn_y, obj_player.x, obj_player.y) > 150;
        
        if (is_safe && far_from_player && !place_meeting(spawn_x, spawn_y, obj_obstacle)) {
            break;
        }
        attempts++;
    }
    
    // Pick enemy based on wave
    var enemy_type = PickEnemyForWave(arena_controller.current_wave);
    
    // Spawn
    var enemy = instance_create_depth(spawn_x, spawn_y, -100, enemy_type);
    
    // Apply difficulty
    if (instance_exists(obj_enemy_controller)) {
        obj_enemy_controller.ApplyDifficultyToEnemy(enemy);
    }
    
    // Spawn VFX
    repeat(10) {
        var p = instance_create_depth(spawn_x, spawn_y, -9999, obj_particle);
        p.direction = random(360);
        p.speed = random_range(2, 4);
        p.particle_color = c_red;
    }
}

/// @function PickEnemyForWave(_wave_num)
function PickEnemyForWave(_wave_num) {
    // Early waves - basic enemies
    if (_wave_num <= 3) {
        return choose(obj_enemy, obj_maggot, obj_enemy_2);
    }
    // Mid waves - add variety
    else if (_wave_num <= 6) {
        return choose(obj_enemy, obj_enemy_triangle, obj_enemy_fly, obj_enemy_2);
    }
    // Late waves - add dangerous enemies
    else if (_wave_num <= 9) {
        return choose(obj_enemy_triangle, obj_enemy_fly, obj_enemy_dasher, obj_enemy_bomber);
    }
    // Final wave - everything
    else {
        return choose(obj_enemy_dasher, obj_enemy_bomber, obj_miniboss_berserker);
    }
}