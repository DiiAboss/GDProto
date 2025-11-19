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

var roomtype = "";


switch(room) {
    case rm_main_menu:
        input_caller = self;
        // Use the new audio system for menu music
        if (_audio_system.GetCurrentMusic() != audio_get_name(Sound1)) {
            _audio_system.CrossfadeMusic(Sound1, true, 60); // 1 second crossfade
        }
        
        // Reset menu state
        menu_state = MENU_STATE.MAIN;
        selected_option = 0;
        
        // Unpause if needed
        if (instance_exists(obj_game_manager)) {
            obj_game_manager.pause_manager.ResumeAll();
        }
        break;
        
    case rm_demo_room:
        
        var game_manager = instance_create_layer(x, y, "Instances", obj_game_manager);
        alarm[0] = 1;
    
        // Start gameplay music with fade in
        _audio_system.PlayMusic(Sound2, true, 120); // 2 second fade in
        
        // Play ambient sounds for atmosphere
        // audio_system.PlayAmbient(snd_wind_ambient, 0.3);
        // audio_system.PlayAmbient(snd_cave_drip, 0.2);
        
        menu_state = MENU_STATE.MAIN;
        break;
		
	case rm_forest_challenge:
        
        var game_manager = instance_create_layer(x, y, "Instances", obj_game_manager);
        alarm[0] = 1;
    
        // Start gameplay music with fade in
        _audio_system.PlayMusic(Sound2, true, 120); // 2 second fade in
        
        // Play ambient sounds for atmosphere
        // audio_system.PlayAmbient(snd_wind_ambient, 0.3);
        // audio_system.PlayAmbient(snd_cave_drip, 0.2);
        
        menu_state = MENU_STATE.MAIN;
    break;
	
	default:
	var game_manager = instance_create_layer(x, y, "Instances", obj_game_manager);
        alarm[0] = 1;
    
        // Start gameplay music with fade in
        _audio_system.PlayMusic(Sound2, true, 120); // 2 second fade in
        
        // Play ambient sounds for atmosphere
        // audio_system.PlayAmbient(snd_wind_ambient, 0.3);
        // audio_system.PlayAmbient(snd_cave_drip, 0.2);
        
        menu_state = MENU_STATE.MAIN;
    break;
}