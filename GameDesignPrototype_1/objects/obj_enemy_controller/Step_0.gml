/// @description Enemy Controller with Scoring Integration

// ==========================================
// ENEMY CONTROLLER - STEP EVENT (UPDATED)
// ==========================================

// Early exit if paused
if (global.gameSpeed <= 0) exit;


// ==========================================
// DIFFICULTY SCALING
// ==========================================

difficulty_timer++;

// Level up enemies every 30 seconds
if (difficulty_timer >= difficulty_interval) {
    difficulty_timer = 0;
    difficulty_level++;
    
    // Update multipliers
    enemy_damage_mult = 1.0 + (damage_increase_per_level * (difficulty_level - 1));
    enemy_speed_mult = 1.0 + (speed_increase_per_level * (difficulty_level - 1));
    enemy_hp_mult = 1.0 + (hp_increase_per_level * (difficulty_level - 1));
    
    // Apply to ALL existing enemies
    with (obj_enemy) {
        // Boost damage (if they have an attack)
        if (variable_instance_exists(self, "base_damage")) {
            // Store original if not already stored
            if (!variable_instance_exists(self, "original_damage")) {
                original_damage = base_damage;
            }
            base_damage = original_damage * obj_enemy_controller.enemy_damage_mult;
        }
        
        // Boost speed
        if (!variable_instance_exists(self, "original_speed")) {
            original_speed = moveSpeed;
        }
        moveSpeed = original_speed * obj_enemy_controller.enemy_speed_mult;
        baseSpeed = moveSpeed;
        
        // Boost HP (current and max)
        if (!variable_instance_exists(self, "original_max_hp")) {
            original_max_hp = maxHp;
        }
        var hp_percent = hp / maxHp;
        maxHp = ceil(original_max_hp * obj_enemy_controller.enemy_hp_mult);
        hp = ceil(maxHp * hp_percent); // Maintain HP percentage
        damage_sys.max_hp = maxHp;
        damage_sys.hp = hp;
    }
    
    // Visual feedback for difficulty increase
    if (instance_exists(obj_player)) {
        var popup = instance_create_depth(obj_player.x, obj_player.y - 80, -9999, obj_floating_text);
        popup.text = "DIFFICULTY INCREASED!";
        popup.color = c_red;
        popup.lifetime = 120;
        popup.rise_speed = 0.5;
        popup.scale = 1.5;
    }
    
    show_debug_message("=== DIFFICULTY LEVEL UP ===");
    show_debug_message("Level: " + string(difficulty_level));
    show_debug_message("Damage: " + string(enemy_damage_mult) + "x");
    show_debug_message("Speed: " + string(enemy_speed_mult) + "x");
    show_debug_message("HP: " + string(enemy_hp_mult) + "x");
}

// ==========================================
// SUMMONER SPAWNING
// ==========================================

summoner_spawn_timer--;

if (summoner_spawn_timer <= 0) {
    var current_summoners = instance_number(obj_summoner_demon) + instance_number(obj_summoner_maggots);
    
    if (current_summoners < max_summoners && instance_exists(obj_player)) {
        // Spawn summoner away from player
        var spawn_distance = 400;
        var spawn_dir = random(360);
        var spawn_x = obj_player.x + lengthdir_x(spawn_distance, spawn_dir);
        var spawn_y = obj_player.y + lengthdir_y(spawn_distance, spawn_dir);
        
        // Choose random summoner type
        var summoner_type = choose(obj_summoner_demon, obj_summoner_maggots);
        
        // Check if position is valid
        var tile_layer_id = layer_get_id("Tiles_2");
        if (layer_exists(tile_layer_id)) {
            var tilemap_id = layer_tilemap_get_id(tile_layer_id);
            var spawn_tile = tilemap_get_at_pixel(tilemap_id, spawn_x, spawn_y);
            
            // Only spawn if safe
            if (spawn_tile <= 446 && spawn_tile != 0 && !place_meeting(spawn_x, spawn_y, obj_obstacle)) {
                instance_create_depth(spawn_x, spawn_y, 0, summoner_type);
                
                // Visual feedback
                var popup = instance_create_depth(spawn_x, spawn_y - 40, -9999, obj_floating_text);
                popup.text = "SUMMONER APPEARED!";
                popup.color = c_purple;
                popup.lifetime = 90;
                popup.rise_speed = 1.0;
                popup.scale = 1.2;
                
                show_debug_message("New summoner spawned at difficulty level " + string(difficulty_level));
            }
        }
    }
    
    // Reset timer
    summoner_spawn_timer = summoner_spawn_interval;
}



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
// CACHE ARMED BOMBS (periodic check)
// ==========================================

if (instance_exists(obj_bomb)) {
    bomb_check_timer--;
    
    if (bomb_check_timer <= 0) {
        bomb_check_timer = bomb_check_frequency;
        // ==========================================
// BOMB AVOIDANCE (similar to enemy separation)
// ==========================================
with (obj_enemy)
	{
		// Check for nearby armed bombs
var bomb = instance_nearest(x, y, obj_bomb);

if (instance_exists(bomb) && bomb.is_armed) {
    var bomb_dist = point_distance(x, y, bomb.x, bomb.y);
    var avoidance_radius = 128; // How far enemies start avoiding
    
    if (bomb_dist < avoidance_radius) {
        // Calculate danger level based on timer
        var danger_multiplier = 1.0;
        
        if (bomb.timer <= bomb.timer_critical_threshold) {
            danger_multiplier = 3.0; // PANIC in critical phase
        } else if (bomb.timer <= bomb.timer_warning_threshold) {
            danger_multiplier = 2.0; // Urgent in warning phase
        }
        
        // Stronger push force as bomb gets closer and timer runs out
        var distance_factor = 1.0 - (bomb_dist / avoidance_radius);
        var push_strength = 1.5 * danger_multiplier * distance_factor;
        
        // Push away from bomb
        var avoid_dir = point_direction(bomb.x, bomb.y, x, y);
        var avoid_x = lengthdir_x(push_strength, avoid_dir);
        var avoid_y = lengthdir_y(push_strength, avoid_dir);
        
        // Apply avoidance with wall checking (same as separation)
        if (!place_meeting(x + avoid_x, y + avoid_y, obj_wall)) {
            x += avoid_x;
            y += avoid_y;
        } else {
            // Slide along walls
            if (!place_meeting(x + avoid_x, y, obj_wall)) {
                x += avoid_x;
            }
            if (!place_meeting(x, y + avoid_y, obj_wall)) {
                y += avoid_y;
            }
        }
        
        // Optional: Visual panic indicator
        if (danger_multiplier >= 2.0) {
            // Enemy looks "scared" - could add particle or animation state
        }
    }
}
}
	}

}
// ==========================================
// REBUILD ENEMY LIST (if needed)
// ==========================================
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
    
    // Check if marked BEFORE update
    var was_not_marked = (!_enemy.marked_for_death);
    
    // Enemy updates
    _enemy.controller_step(
        cached_delta,
        cached_player_exists,
        cached_player_x,
        cached_player_y,
        cached_player_instance
    );
    
    // Check if JUST got marked for death this frame
    if (was_not_marked && _enemy.marked_for_death && !_enemy.scored_this_death) {
        HandleEnemyDeath(_enemy);
        _enemy.scored_this_death = true;
    }
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

// ==========================================
// SCORING FUNCTION
// ==========================================

/// @function HandleEnemyDeath(_enemy)
/// @param {Id.Instance} _enemy The enemy that just died
function HandleEnemyDeath(_enemy) {
    if (!instance_exists(obj_game_manager)) return;
    if (!cached_player_exists) return;
    
    // Get damage info
    var damage_dealt = _enemy.maxHp;
    
    // Check if we tracked actual damage
    if (variable_instance_exists(_enemy, "total_damage_taken")) {
        damage_dealt = _enemy.total_damage_taken;
    }
    
    // Register kill with score manager
    var score_earned = obj_game_manager.score_manager.RegisterKill(
        _enemy,
        damage_dealt,
        cached_player_instance
    );
    
    // Create score popup
    CreateScorePopup(_enemy.x, _enemy.y - 40, score_earned);
    
    // Create style popups
    CreateStylePopups(_enemy, damage_dealt);
}

/// @function CreateScorePopup(_x, _y, _score)
function CreateScorePopup(_x, _y, _score) {
    if (!instance_exists(obj_floating_text)) return;
    
    var popup = instance_create_depth(_x, _y, -9999, obj_floating_text);
    popup.text = "+" + string(floor(_score));
    popup.color = c_white;
    popup.lifetime = 60;
    popup.rise_speed = 1.5;
    popup.scale = 1.0;
}

/// @function CreateStylePopups(_enemy, _damage_dealt)
function CreateStylePopups(_enemy, _damage_dealt) {
    if (!instance_exists(obj_floating_text)) return;
    if (!instance_exists(obj_game_manager)) return;
    
    var y_offset = -60;
    
    // Perfect timing
    if (cached_player_exists && 
        variable_instance_exists(cached_player_instance, "last_timing_quality") &&
        cached_player_instance.last_timing_quality == "perfect") {
        
        var popup = instance_create_depth(_enemy.x, _enemy.y + y_offset, -9999, obj_floating_text);
        popup.text = "PERFECT!";
        popup.color = c_yellow;
        popup.lifetime = 90;
        popup.rise_speed = 0.8;
        popup.scale = 1.3;
        y_offset -= 20;
    }
    
    // Overkill
    if (_damage_dealt > _enemy.maxHp * 2) {
        var overkill_mult = floor(_damage_dealt / _enemy.maxHp);
        
        var popup = instance_create_depth(_enemy.x, _enemy.y + y_offset, -9999, obj_floating_text);
        popup.text = "OVERKILL x" + string(overkill_mult);
        popup.color = c_red;
        popup.lifetime = 90;
        popup.rise_speed = 0.8;
        popup.scale = 1.2;
        y_offset -= 20;
    }
    
    // Chain kill
    var chain_count = obj_game_manager.score_manager.kills_this_chain;
    if (chain_count > 1) {
        var popup = instance_create_depth(_enemy.x, _enemy.y + y_offset, -9999, obj_floating_text);
        popup.text = "CHAIN x" + string(chain_count);
        popup.color = c_aqua;
        popup.lifetime = 90;
        popup.rise_speed = 0.8;
        popup.scale = 1.2;
        y_offset -= 20;
    }
    
    // High combo
    var combo = obj_game_manager.score_manager.GetComboMultiplier();
    if (combo >= 2.0) {
        var popup = instance_create_depth(_enemy.x, _enemy.y + y_offset, -9999, obj_floating_text);
        popup.text = "COMBO x" + string_format(combo, 1, 1);
        popup.color = c_lime;
        popup.lifetime = 90;
        popup.rise_speed = 0.8;
        popup.scale = 1.1;
    }
}

