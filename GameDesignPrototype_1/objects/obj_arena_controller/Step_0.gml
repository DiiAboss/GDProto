/// @desc obj_arena_controller Step Event
if (global.gameSpeed <= 0) exit;

if (!game_started) {
    if (!instance_exists(obj_challenge_banner)) {
        game_started = true;
        StartNextWave(); // Start wave 1
    }
    return;
}

if (arena_complete) exit;

var _delta = game_speed_delta();

// Between wave break
if (wave_break_timer > 0) {
    wave_break_timer -= _delta;
    
    if (wave_break_timer <= 0) {
        StartNextWave();
    }
    return;
}

// Active wave - check completion
if (wave_active) {
    // Wave complete when all enemies spawned AND killed
    if (enemies_spawned >= enemies_to_spawn) {
        var enemies_alive = instance_number(obj_enemy) + instance_number(obj_enemy_triangle) + 
                           instance_number(obj_enemy_fly) + instance_number(obj_enemy_dasher) +
                           instance_number(obj_enemy_bomber) + instance_number(obj_miniboss_berserker);
        
        if (enemies_alive == 0) {
            CompleteWave();
        }
    }
}
