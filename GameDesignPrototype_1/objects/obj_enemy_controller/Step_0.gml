// ==========================================
// ENEMY CONTROLLER - STEP EVENT
// ==========================================

// Early exit if paused
if (global.gameSpeed <= 0) exit;

// ==========================================
// CACHE SHARED VALUES (ONCE PER FRAME)
// ==========================================
cached_delta = game_speed_delta();
cached_player_exists = instance_exists(obj_player);
if (cached_player_exists) {
    cached_player_instance = obj_player;
    cached_player_x = obj_player.x;
    cached_player_y = obj_player.y;
}

// ==========================================
// REBUILD ENEMY LIST (if needed)
// ==========================================
// Only rebuild if count changed - avoids constant with() lookups
var current_count = instance_number(obj_enemy);
if (current_count != enemy_count) {
    ds_list_clear(enemy_list);
    with (obj_enemy) {
        if (!marked_for_death) {
            ds_list_add(other.enemy_list, id);
        }
    }
    enemy_count = ds_list_size(enemy_list);
}

// ==========================================
// UPDATE LIVING ENEMIES
// ==========================================
for (var i = 0; i < enemy_count; i++) {
    var _enemy = enemy_list[| i];
    
    if (!instance_exists(_enemy)) continue;
    
    // Enemy updates using cached values
    _enemy.controller_step(
        cached_delta,
        cached_player_exists,
        cached_player_x,
        cached_player_y,
        cached_player_instance
    );
}

// ==========================================
// UPDATE DEAD ENEMIES (separate pass)
// ==========================================
ds_list_clear(dead_list);
with (obj_enemy) {
    if (marked_for_death) {
        ds_list_add(other.dead_list, id);
    }
}
dead_count = ds_list_size(dead_list);

for (var i = 0; i < dead_count; i++) {
    var _enemy = dead_list[| i];
    if (instance_exists(_enemy)) {
        _enemy.controller_step_dead(cached_delta);
    }
}