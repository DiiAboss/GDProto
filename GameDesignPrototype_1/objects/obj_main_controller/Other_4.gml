/// @desc Main Controller - Room Start Event

// Reset visual vars for menu
logo_scale = 0;
menu_alpha = 0;

// Reset pause menu flags
show_controls = false;
show_stats = false;
show_pause_menu = false;

// CRITICAL: Always reset death sequence on room start
death_sequence_active = false;
death_phase = 0;
death_timer = 0;
death_fade_alpha = 0;
death_stats_alpha = 0;
death_player_fade = 0;

// Handle room-specific setup
switch(room) {
    case rm_main_menu:
        // Ensure menu music is playing
        if (!audio_is_playing(Sound1) || current_music != Sound1) {
            PlayMusic(Sound1, true);
        }
        
        // Reset menu state
        menu_state = MENU_STATE.MAIN;
        selected_option = 0;
        
        // CRITICAL: Unpause game if coming from gameplay
        if (instance_exists(obj_game_manager)) {
            obj_game_manager.pause_manager.ResumeAll();
        }
        
        
    case rm_demo_room:
        // Start gameplay music
        if (!audio_is_playing(Sound2)) {
            PlayMusic(Sound2, true);
        }
        
        // Reset menu state to neutral
        menu_state = MENU_STATE.MAIN;
	break;	
}