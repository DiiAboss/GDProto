/// @description Death Sequence Handler
function DeathSequence(_self) constructor {
    
    active = false;
    phase = 0;
    timer = 0;
    fade_alpha = 0;
    stats_alpha = 0;
    player_fade = 0;
    
    final_score = 0;
    final_time = "";
    
    main_controller = _self;
    _self.death_sequence_active = false;
    // Highscore tracking
    made_highscore = false;
    highscore_rank = -1;
    show_highscores = false;
    
    static Trigger = function(_game_manager, _player_obj, _highscore_system) {
        if (active) return;
        main_controller.death_sequence_active = true;
        active = true;
        
		
		// CLEANUP FIRST - before anything else
    CleanupGameWorld();
		
		phase = 0;
        timer = 0;
        fade_alpha = 0;
        stats_alpha = 0;
        player_fade = 0;
        made_highscore = false;
        highscore_rank = -1;
        show_highscores = false;
        
        // Get stats from game manager
        if (_game_manager) {
            final_score = _game_manager.score_manager.GetScore();
            final_time = _game_manager.time_manager.GetFormattedTime();
            
            // Record in save system
            var kills = 0; // TODO: Track this in game_manager
            RecordRunEnd(_player_obj.character_class, final_score, final_time, kills);
            RecordDeath(_player_obj.character_class);
            
            // Check highscores
            if (_highscore_system) {
                _highscore_system.AddHighscore(final_score, ">");
                
                // Check if we made top 10
                var rank = _highscore_system.GetScoreRank(final_score);
                if (rank <= 10) {
                    made_highscore = true;
                    highscore_rank = rank;
                }
            }
        }
        
        // Audio fade
        main_controller._audio_system.FadeMusic(0.2, 90, FADE_TYPE.SMOOTH);
    }
	/// @function CleanupGameWorld()
static CleanupGameWorld = function() {
    // Stop enemy spawners
    with (obj_summoner_maggots) {
        active = false;
    }
    with (obj_summoner_demon) {
        activated = false;
    }
    
    // Destroy all enemies
    with (obj_enemy) {
        instance_destroy();
    }
    
    // Destroy all enemy projectiles
    with (obj_enemySpawner) {
        instance_destroy();
    }
    
    // Destroy hazards that could still damage
    with (obj_rolling_ball) {
        instance_destroy();
    }
    
    // Clear floating text/particles (optional - looks nice to keep some)
    // with (obj_floating_text) { instance_destroy(); }
    
    show_debug_message("Death cleanup: Removed all enemies and hazards");
}
    
    static Update = function(_input) {
        if (!active) return;
        
        timer++;
        
        switch(phase) {
            case 0: // Initial fade
                fade_alpha = min(fade_alpha + 0.02, 0.8);
                if (timer > 60) {
                    phase = 1;
                    timer = 0;
                }
                break;
                
            case 1: // Show player death
                player_fade = min(player_fade + 0.03, 1);
                if (timer > 30) {
                    phase = 2;
                    timer = 0;
                }
                break;
                
            case 2: // Fade in stats
                stats_alpha = min(stats_alpha + 0.03, 1);
                if (timer > 60) {
                    phase = 3;
                    timer = 0;
                    show_highscores = true;
                }
                break;
                
            case 3: // Wait for input
                if (timer > 60) {
                    // Use input system instead of keyboard checks
                    if (_input.Action || _input.FirePress) {
                        active = false;
                        //global.gameSpeed = 1;
						obj_main_controller.state = MENU_STATE.UNLOCKS;
                        room_goto(rm_main_menu);
                    }
                }
                break;
        }
    }
    
   static Draw = function(_w, _h, _cx, _cy, _highscore_system) {
    // Black fade overlay
    if (fade_alpha > 0) {
        drawAlphaRectangle(0, 0, _w, _h, fade_alpha);
    }
    
    // "YOU DIED" text
    if (phase >= 2 && stats_alpha > 0) {
        draw_set_alpha(stats_alpha);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        // YOU DIED
        draw_set_font(fnt_large);
        draw_set_color(c_red);
        draw_text(_cx, _cy - 80, "YOU DIED");
        
        // Score & Time
        draw_set_font(fnt_default);
        draw_set_color(c_white);
        draw_text(_cx, _cy - 20, "SCORE: " + string(final_score));
        draw_text(_cx, _cy + 10, "TIME: " + final_time);
        
        // Player Level
        var player_level = 1;
        if (instance_exists(obj_game_manager)) {
            player_level = obj_game_manager.player_level;
        }
        draw_set_color(c_yellow);
        draw_text(_cx, _cy + 50, "LEVEL: " + string(player_level));
        
        // Mods collected
        draw_set_color(c_aqua);
        var mod_count = 0;
        if (instance_exists(obj_player) && variable_instance_exists(obj_player, "mod_list")) {
            mod_count = array_length(obj_player.mod_list);
        }
        draw_text(_cx, _cy + 80, "MODS: " + string(mod_count));
        
        draw_set_color(c_white);
        draw_set_alpha(1);
    }
    
    // Return prompt
    if (phase >= 3 && timer > 60) {
        var pulse = 0.5 + sin(current_time * 0.005) * 0.5;
        draw_set_alpha(pulse);
        draw_set_halign(fa_center);
        draw_set_color(c_gray);
        draw_set_font(fnt_default);
        draw_text(_cx, _h - 80, "Press any key to continue...");
        draw_set_alpha(1);
    }
}
}