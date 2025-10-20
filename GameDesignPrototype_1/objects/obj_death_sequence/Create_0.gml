/// @description
/// @desc Death Sequence Controller - Create Event

// Sequence phases
phase = 0;
phase_timer = 0;

// Camera zoom settings
target_zoom = 2.0;  // Zoom in on player
zoom_speed = 0.03;

// Fade settings
fade_alpha = 0;
fade_speed = 0.015;
player_fade_alpha = 0;

// Display settings
show_stats = false;
stats_alpha = 0;
stats_fade_speed = 0.02;

// Get final stats
final_score = instance_exists(obj_game_manager) ? obj_game_manager.score_manager.GetScore() : 0;
final_time = instance_exists(obj_game_manager) ? obj_game_manager.time_manager.GetFormattedTime() : "00:00";

// Player reference
dead_player = instance_exists(obj_player) ? obj_player : noone;
player_x = dead_player != noone ? dead_player.x : room_width / 2;
player_y = dead_player != noone ? dead_player.y : room_height / 2;

// Music
death_song = noone;
music_fade_speed = 0.02;
death_music_volume = 0;

// Wait timer before menu
menu_wait_timer = 0;
can_go_to_menu = false;

// Layer references
game_layer_alpha = 1;

// Pause the game
if (instance_exists(obj_game_manager)) {
    obj_game_manager.pause_manager.Pause(PAUSE_REASON.GAME_OVER);
}

death_song = noone;
// Phase 0: Zoom to player (60 frames)
// Phase 1: Fade everything but player (60 frames) 
// Phase 2: Show stats and fade player (90 frames)
// Phase 3: Wait for input to menu (infinite)