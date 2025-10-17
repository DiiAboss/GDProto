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

// Performance tracking (optional)
enemy_count = 0;
dead_count = 0;