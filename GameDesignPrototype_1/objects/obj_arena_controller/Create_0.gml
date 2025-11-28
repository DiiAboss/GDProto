/// @desc obj_arena_controller Create Event

arena_zone = MAP_ZONE.FOREST;
arena_type = ROOM_TYPE.ARENA;

// Wave system
current_wave = 0;
max_waves = 10;
wave_active = false;
wave_complete = false;

enemies_to_spawn = 0;
enemies_spawned = 0;
spawn_timer = 0;
spawn_interval = 60;

// Between wave timer
wave_break_timer = 0;
wave_break_duration = 180; // 3 seconds

// Random drops between waves
drops_per_break = 3;

// START SEQUENCE
intro_banner = noone;
game_started = false; // NEW - prevents waves until ready

// Completion
arena_complete = false;

// Start with banner
alarm[0] = 1;

spawn = instance_create_depth(x, y, depth, obj_arena_spawner);

/// @function StartNextWave()
function StartNextWave() {
    current_wave++;
    
    if (current_wave > max_waves) {
        CompleteArena();
        return;
    }
    
    wave_active = true;
    wave_complete = false;
    
    // Calculate enemies (scales with wave)
    enemies_to_spawn = 5 + (current_wave * 2);
    enemies_spawned = 0;
    spawn_timer = 0;
}

/// @function SpawnWaveEnemy()
function SpawnWaveEnemy() {
    // Use existing spawner logic
    if (instance_exists(obj_enemySpawner)) {
        with (obj_enemySpawner) {
            // Trigger immediate spawn
            spawner_timer = 0;
            summon_timer = 0;
        }
    }
}

/// @function CompleteWave()
function CompleteWave() {
    wave_active = false;
    wave_complete = true;
    wave_break_timer = wave_break_duration;
    
    // Drop random items
    DropRandomItems();
}

/// @function DropRandomItems()
function DropRandomItems() {
    repeat(drops_per_break) {
        var drop_x = random_range(100, room_width - 100);
        var drop_y = random_range(100, room_height - 100);
        
        var drop_obj = choose(obj_barrel, obj_rock, obj_wood_chunk);
        
        var faller = instance_create_depth(drop_x, -80, -9999, obj_falling_object);
        faller.spawn_on_land = drop_obj;
        faller.shadow_x = drop_x;
        faller.shadow_y = drop_y;
    }
}

/// @function CompleteArena()
function CompleteArena() {
    arena_complete = true;
    
    
    // Unlock permanently
    obj_main_controller.UnlockDoor(arena_zone, arena_type);
    
    // Show completion screen after 2 seconds
    alarm[1] = 120;
}



