
// ENEMY CONTROLLER - CREATE EVENT


// Enemy tracking
enemy_list = ds_list_create();
dead_list = ds_list_create();

// Cached values (updated once per frame)
cached_delta = 0;
cached_player_exists = false;
cached_player_x = 0;
cached_player_y = 0;
cached_player_instance = noone;

// Bomb caching
bomb_list = ds_list_create();
armed_bomb_count = 0;
bomb_check_frequency = 10;
bomb_check_timer = 0;

// Performance tracking
enemy_count = 0;
dead_count = 0;


// DIFFICULTY SCALING SYSTEM


difficulty_level = 1;
difficulty_timer = 0;
difficulty_interval = 30 * 60; // 30 seconds in frames (60fps)

// Scaling multipliers
enemy_damage_mult = 1.0;
enemy_speed_mult = 1.0;
enemy_hp_mult = 1.0;

// Summoner spawning
summoner_spawn_timer = 60 * 60; // 1 minute
summoner_spawn_interval = 60 * 60;
max_summoners = 6; // Cap at 6 summoners

// Stat increases per level
damage_increase_per_level = 0.10; // +10% damage
speed_increase_per_level = 0.05;  // +5% speed
hp_increase_per_level = 0.15;     // +15% hp

/// @function ApplyDifficultyToEnemy(_enemy)
function ApplyDifficultyToEnemy(_enemy) {
    with (_enemy) {
        // Store originals
        original_speed = moveSpeed;
        original_max_hp = maxHp;
        
        // Apply multipliers
        moveSpeed = original_speed * obj_enemy_controller.enemy_speed_mult;
        baseSpeed = moveSpeed;
        
        maxHp = ceil(original_max_hp * obj_enemy_controller.enemy_hp_mult);
        hp = maxHp;
        damage_sys.max_hp = maxHp;
        damage_sys.hp = hp;
        
        // If they have damage
        if (variable_instance_exists(self, "base_damage")) {
            original_damage = base_damage;
            base_damage = original_damage * obj_enemy_controller.enemy_damage_mult;
        }
    }
}