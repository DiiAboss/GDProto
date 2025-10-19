/// @description
// ==========================================
// ENEMY CONTROLLER - CREATE EVENT
// ==========================================

// Enemy tracking
enemy_list = ds_list_create();
dead_list = ds_list_create();

// Cached values (updated once per frame)
cached_delta = 0;
cached_player_exists = false;
cached_player_x = 0;
cached_player_y = 0;
cached_player_instance = noone;


// NEW: Bomb caching
bomb_list = ds_list_create();
armed_bomb_count = 0;
bomb_check_frequency = 10; // Check every 10 frames
bomb_check_timer = 0;

// Performance tracking (optional)
enemy_count = 0;
dead_count = 0;