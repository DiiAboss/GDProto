/// @description
/// @desc Death Sequence Controller - Step Event

phase_timer++;
show_debug_message("Death sequence phase: " + string(phase) + " timer: " + string(phase_timer));

switch (phase) {
    case 0: // ZOOM TO PLAYER (60 frames)
        if (dead_player != noone && instance_exists(dead_player)) {
            // Lock camera on player
            if (variable_instance_exists(dead_player, "camera")) {
                dead_player.camera.lock_at(player_x, player_y);
                dead_player.camera.set_zoom(target_zoom);
            }
        }
        
        
        if (phase_timer >= 60) {
            phase = 1;
            phase_timer = 0;
            
            // Start death music
            death_song = audio_play_sound(Sound1, 1, true, 0);
        }
        break;
        
    case 1: // FADE EVERYTHING BUT PLAYER (60 frames)
        // Fade alpha up
        fade_alpha = min(fade_alpha + fade_speed, 1);
        
        
        
        if (phase_timer >= 60) {
            phase = 2;
            phase_timer = 0;
            show_stats = true;
        }
        break;
        
    case 2: // SHOW STATS AND FADE PLAYER (90 frames)
        // Fade stats in
        stats_alpha = min(stats_alpha + stats_fade_speed, 1);
        
        // Start fading player after 30 frames
        if (phase_timer > 30) {
            player_fade_alpha = min(player_fade_alpha + 0.015, 1);
        }
        
        if (phase_timer >= 90) {
            phase = 3;
            phase_timer = 0;
            can_go_to_menu = true;
			
        }
        break;
        
   case 3: // WAIT FOR INPUT
    menu_wait_timer++;
    
    // Allow return to menu after 60 frames
    if (menu_wait_timer > 60 && (keyboard_check_pressed(vk_enter) || 
        keyboard_check_pressed(vk_space) || 
        keyboard_check_pressed(vk_escape))) {
        	//AddHighscore(obj_main_controller.highscore_table, obj_game_manager.score_manager.GetScore(), string(final_time));
        
        	// Unpause 
			obj_game_manager.pause_manager.Resume(PAUSE_REASON.GAME_OVER);

	        // Go to main menu
	        room_goto(rm_main_menu);
    }
    break;
}