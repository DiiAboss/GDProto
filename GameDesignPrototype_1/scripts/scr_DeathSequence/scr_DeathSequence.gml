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
    
    // Highscore tracking
    made_highscore = false;
    highscore_rank = -1;
    show_highscores = false;
    
    static Trigger = function(_game_manager, _player_obj, _highscore_system) {
        if (active) return;
        
        active = true;
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
                _highscore_system.AddHighscore(final_score, "DEMO");
                
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
                        global.gameSpeed = 1;
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
        
        // Player death sprite
        draw_sprite_ext(spr_vh_dead, 0, _cx, _cy - 50, 3, 3, 0, c_white, fade_alpha);
        
        // Stats display
        if (phase >= 2 && stats_alpha > 0) {
            draw_set_alpha(stats_alpha);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_white);
            
            // Title
            draw_set_font(fnt_large);
            draw_text(_cx, _cy - 180, "GAME OVER");
            
            draw_set_font(fnt_default);
            
            // Highscore notification
            if (made_highscore) {
                var pulse = 0.8 + sin(current_time * 0.01) * 0.2;
                draw_set_color(merge_color(c_yellow, c_white, pulse));
                draw_text(_cx, _cy - 120, "NEW HIGHSCORE!");
                draw_set_color(c_yellow);
                draw_text(_cx, _cy - 100, "RANK #" + string(highscore_rank));
            }
            
            draw_set_color(c_white);
            
            // Final stats
            draw_text(_cx, _cy - 60, "FINAL SCORE: " + string(final_score));
            draw_text(_cx, _cy - 30, "TIME SURVIVED: " + final_time);
            
            // Style stats (if available)
            if (instance_exists(obj_game_manager)) {
                var stats = obj_game_manager.score_manager.GetStyleStats();
                draw_set_color(c_gray);
                draw_set_font(fnt_small);
                
                var stat_y = _cy + 10;
                if (stats.perfect_timing_kills > 0) {
                    draw_text(_cx, stat_y, "Perfect Kills: " + string(stats.perfect_timing_kills));
                    stat_y += 20;
                }
                if (stats.highest_chain > 1) {
                    draw_text(_cx, stat_y, "Best Chain: x" + string(stats.highest_chain));
                    stat_y += 20;
                }
                if (stats.highest_combo > 1) {
                    draw_text(_cx, stat_y, "Best Combo: x" + string_format(stats.highest_combo, 1, 1));
                    stat_y += 20;
                }
            }
            
            draw_set_font(fnt_default);
            draw_set_color(c_white);
            draw_set_alpha(1);
        }
        
        // Highscore table
        if (phase >= 3 && show_highscores && _highscore_system) {
            _highscore_system.DrawCompactHighscores(_w, _h, made_highscore ? highscore_rank - 1 : -1);
        }
        
        // Thank you message
        if (phase >= 2 && stats_alpha > 0) {
            draw_set_alpha(stats_alpha);
            draw_set_color(c_yellow);
            draw_set_halign(fa_center);
            draw_text(_cx, _cy + 140, "Thanks for playing the");
            draw_set_font(fnt_large);
            draw_text(_cx, _cy + 170, "TARLHS GAME DEMO");
            draw_set_font(fnt_default);
            draw_set_alpha(1);
        }
        
        // Return prompt
        if (phase >= 3 && timer > 60) {
            var pulse = 0.5 + sin(current_time * 0.005) * 0.5;
            draw_set_alpha(pulse);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_white);
            
            draw_text(_cx, _h - 80, "Press ENTER/SPACE or Click to return to Main Menu");
            
            draw_set_alpha(1);
        }
    }
}