/// scr_ui_system.gml

#region UI Enums

enum UI_BADGE_TYPE {
    DOUBLE_KILL,
    TRIPLE_KILL,
    MULTI_KILL,
    OVERKILL,
    ENVIRONMENTAL_KILL,
    PERFECT_DODGE,
    BOSS_SLAIN,
    COMBO_MASTER,
    HEADSHOT,
    REVENGE
}

#endregion

#region UI Manager Constructor

function UIManager() constructor {
    // Positioning
    screen_width = display_get_gui_width();
    screen_height = display_get_gui_height();
    center_x = screen_width / 2;
    
    // UI SCALE - Adjust this value to resize entire UI
    ui_scale = 1.0;
    
    // Top left corner - HP/XP/Level
    top_left_x = 15 * ui_scale;
    top_left_y = 15 * ui_scale;
    
    // HP/Level/XP (top left corner)
    level_x = top_left_x;
    level_y = top_left_y;
    level_width = 50 * ui_scale;
    level_height = 35 * ui_scale;
    
    hp_x = level_x + level_width + 10 * ui_scale;
    hp_y = level_y;
    hp_width = 200 * ui_scale;
    hp_height = 35 * ui_scale;
    
    exp_bar_x = level_x;
    exp_bar_y = level_y + level_height + 8 * ui_scale;
    exp_bar_width = level_width + hp_width + 10 * ui_scale;
    exp_bar_height = 24 * ui_scale;
    
    // Weapons (right side, above mouse buttons)
    weapon_size = 60 * ui_scale;
    weapon_vertical_spacing = 10 * ui_scale;
    weapon_x = screen_width - weapon_size - 30 * ui_scale;
    weapon_y = screen_height - 200 * ui_scale; // Adjust this to position above mouse buttons
    
    // Score (top center)
    score_y = 20 * ui_scale;
    
    // Time/Score box (top right)
    time_box_width = 200 * ui_scale;
    time_box_height = 80 * ui_scale;
    time_box_x = screen_width - time_box_width - 20 * ui_scale;
    time_box_y = 20 * ui_scale;
    
    // Gold (bottom left)
    gold_x = 30 * ui_scale;
    gold_y = screen_height - 60 * ui_scale;
    
    // Modifiers box (bottom center)
    mod_box_width = 400 * ui_scale;
    mod_box_height = 60 * ui_scale;
    mod_box_x = (screen_width - mod_box_width) / 2;
    mod_box_y = screen_height - mod_box_height - 20 * ui_scale;
    max_visible_mods = 10;
    
    // Mouse buttons (bottom right)
    mouse_button_size = 50 * ui_scale;
    mouse_button_spacing = 15 * ui_scale;
    mouse_button_x = screen_width - (mouse_button_size * 2) - mouse_button_spacing - 30 * ui_scale;
    mouse_button_y = screen_height - mouse_button_size - 30 * ui_scale;
    
    // Badge system (below HP/XP area)
    badges = [];
    badge_start_x = 40 * ui_scale;
    badge_start_y = exp_bar_y + exp_bar_height + 40 * ui_scale;
    badge_spacing = 70 * ui_scale;
    badge_float_speed = 1.2 * ui_scale;
    badge_fade_start_y = badge_start_y + (200 * ui_scale);
    
    // Score animation
    displayed_score = 0;
    target_score = 0;
    score_lerp_speed = 0.15;
    
    // Player reference
    player = obj_player;
    
    /// @method update()
    static update = function() {
        if (!instance_exists(player)) {
            player = instance_find(obj_player, 0);
            if (!instance_exists(player)) return;
        }
        
        // Smooth score counting
        if (displayed_score != target_score) {
            var diff = target_score - displayed_score;
            if (abs(diff) < 10) {
                displayed_score = target_score;
            } else {
                displayed_score += diff * score_lerp_speed;
            }
        }
        
        // Update badges
        for (var i = array_length(badges) - 1; i >= 0; i--) {
            var badge = badges[i];
            
            badge.y_offset += badge_float_speed;
            var current_y = badge_start_y + (i * badge_spacing) + badge.y_offset;
            
            if (current_y > badge_fade_start_y) {
                var fade_range = 150 * ui_scale;
                var fade_progress = (current_y - badge_fade_start_y) / fade_range;
                badge.alpha = max(0, 1 - fade_progress);
            }
            
            if (badge.alpha <= 0 || current_y > screen_height) {
                array_delete(badges, i, 1);
            }
        }
    }
    
    /// @method draw()
static draw = function() {
    if (!instance_exists(player)) return;
    
    draw_set_font(fnt_default);
    
    // Draw UI elements
    draw_weapons();
    draw_level_hp_xp();
    draw_score();
    draw_time_box();
    draw_style_stats();     // NEW
    draw_combo_meter();     // NEW (optional)
    draw_gold();
    draw_modifiers_box();
    draw_mouse_buttons();
    draw_badges();
    draw_totems();
}

    
    /// @method draw_weapons()
    static draw_weapons = function() {
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        // Draw 2 weapon slots stacked vertically
        for (var i = 0; i < 2; i++) {
            var draw_x = weapon_x;
            var draw_y = weapon_y - (i * (weapon_size + weapon_vertical_spacing));
            
            // Slot background
            var is_active = (i == player.current_weapon_index);
            draw_set_color(c_white);
            draw_set_alpha(1);
            draw_circle(draw_x + weapon_size / 2, draw_y + weapon_size / 2, weapon_size / 2, true);
            
            // Active indicator
            if (is_active) {
                draw_set_color(c_black);
                draw_circle(draw_x + weapon_size / 2, draw_y + weapon_size / 2, weapon_size / 2, false);
            }
            
            // Weapon text
            draw_set_color(is_active ? c_white : c_dkgray);
            var weapon_name = "weapon";
            if (i == 1) weapon_name = "weapon 2";
            draw_text(draw_x + weapon_size / 2, draw_y + weapon_size / 2, weapon_name);
        }
        
        draw_set_alpha(1);
    }
    
    /// @method draw_level_hp_xp()
    static draw_level_hp_xp = function() {
        // Level box
        draw_set_color(c_white);
        draw_rectangle(level_x, level_y, level_x + level_width, level_y + level_height, true);
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_text(level_x + level_width / 2, level_y + level_height / 2 - 8, string(player.player_level));
        
        draw_set_halign(fa_center);
        draw_text(level_x + level_width / 2, level_y + level_height / 2 + 8, "LV");
        
        // HP box
        draw_set_color(c_white);
        draw_rectangle(hp_x, hp_y, hp_x + hp_width, hp_y + hp_height, true);
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        var hp_text = "HP/MaxHp";
        if (instance_exists(player)) {
            hp_text = string(floor(player.hp)) + "/" + string(player.maxHp);
        }
        draw_text(hp_x + 10, hp_y + hp_height / 2, hp_text);
        
        // XP bar
        draw_set_color(c_white);
        draw_rectangle(exp_bar_x, exp_bar_y, exp_bar_x + exp_bar_width, exp_bar_y + exp_bar_height, true);
        
        // XP fill
        var exp_percent = 0;
        if (player.exp_to_next_level > 0) {
            exp_percent = player.experience_points / player.exp_to_next_level;
        }
        
        draw_set_color(c_lime);
        var fill_width = exp_bar_width * exp_percent;
        draw_rectangle(exp_bar_x + 2, exp_bar_y + 2, exp_bar_x + fill_width - 2, exp_bar_y + exp_bar_height - 2, false);
        
        // XP label
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_text(exp_bar_x + 10, exp_bar_y + exp_bar_height / 2, "XP");
        
        // Experience Bar label
        draw_set_halign(fa_center);
        draw_set_color(c_black);
        draw_text(exp_bar_x + exp_bar_width / 2, exp_bar_y + exp_bar_height / 2, "Experience Bar");
    }
    
    /// @method draw_score()
static draw_score = function() {
    // Get score from game manager
    if (!instance_exists(obj_game_manager)) return;
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    
    // Get current score from manager
    target_score = obj_game_manager.score_manager.GetScore();
    
    // Smooth counting animation
    if (displayed_score != target_score) {
        var diff = target_score - displayed_score;
        if (abs(diff) < 10) {
            displayed_score = target_score;
        } else {
            displayed_score += diff * score_lerp_speed;
        }
    }
    
    // Format score with leading zeros
    var score_text = "SCORE: " + string_format(floor(displayed_score), 6, 0);
    score_text = string_replace_all(score_text, " ", "0");
    
    draw_set_font(fnt_large);
    draw_text(center_x, score_y, score_text);
    
    // Draw combo multiplier below score
    var combo = obj_game_manager.score_manager.GetComboMultiplier();
    if (combo > 1.0) {
        draw_set_font(fnt_default);
        draw_set_color(c_yellow);
        
        var combo_text = "COMBO x" + string_format(combo, 1, 1);
        draw_text(center_x, score_y + 35, combo_text);
        
        draw_set_color(c_white);
    }
    
    draw_set_font(fnt_default);
}
    
    /// @method draw_time_box()
static draw_time_box = function() {
    // Get time from game manager
    if (!instance_exists(obj_game_manager)) return;
    
    // Box outline
    draw_set_color(c_white);
    draw_rectangle(time_box_x, time_box_y, 
                   time_box_x + time_box_width, 
                   time_box_y + time_box_height, true);
    
    // Title
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_font(fnt_default);
    draw_text(time_box_x + time_box_width / 2, time_box_y + 10, "TIME SURVIVED");
    
    // Get formatted time from manager
    var time_string = obj_game_manager.time_manager.GetFormattedTime();
    
    // Display time (large)
    draw_set_font(fnt_large);
    draw_text(time_box_x + time_box_width / 2, time_box_y + 35, time_string);
    
    draw_set_font(fnt_default);
    draw_set_color(c_white);
}
	
	/// @method draw_style_stats()
static draw_style_stats = function() {
    // Draw style kill stats in corner
    if (!instance_exists(obj_game_manager)) return;
    
    var stats = obj_game_manager.score_manager.GetStyleStats();
    
    // Only show if player has style kills
    if (stats.perfect_timing_kills == 0 && 
        stats.chain_kills == 0 && 
        stats.overkill_kills == 0) return;
    
    var stats_x = screen_width - 150;
    var stats_y = 100;
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(fnt_default);
    
    // Title
    draw_set_color(c_yellow);
    draw_text(stats_x, stats_y, "STYLE KILLS");
    stats_y += 20;
    
    // Perfect timing kills
    if (stats.perfect_timing_kills > 0) {
        draw_set_color(c_yellow);
        draw_text(stats_x, stats_y, "Perfect: " + string(stats.perfect_timing_kills));
        stats_y += 15;
    }
    
    // Overkill kills
    if (stats.overkill_kills > 0) {
        draw_set_color(c_red);
        draw_text(stats_x, stats_y, "Overkill: " + string(stats.overkill_kills));
        stats_y += 15;
    }
    
    // Chain kills
    if (stats.chain_kills > 0) {
        draw_set_color(c_aqua);
        draw_text(stats_x, stats_y, "Chains: " + string(stats.chain_kills));
        stats_y += 15;
    }
    
    // Highest chain
    if (stats.highest_chain > 1) {
        draw_set_color(c_lime);
        draw_text(stats_x, stats_y, "Best Chain: x" + string(stats.highest_chain));
        stats_y += 15;
    }
    
    draw_set_color(c_white);
}
    
    /// @method draw_gold()
    static draw_gold = function() {
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        
        // Circle background
        draw_set_color(c_white);
        draw_circle(gold_x + 25, gold_y, 30, true);
        
        // GOLD text
        draw_set_color(c_white);
        draw_text(gold_x + 60, gold_y, "GOLD");
    }
    
    /// @method draw_modifiers_box()
    static draw_modifiers_box = function() {
        // Box outline
        draw_set_color(c_white);
        draw_rectangle(mod_box_x, mod_box_y, mod_box_x + mod_box_width, mod_box_y + mod_box_height, true);
        
        // Modifiers label
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(mod_box_x + mod_box_width / 2, mod_box_y + mod_box_height / 2, "Modifiers");
    }
    
    /// @method draw_mouse_buttons()
    static draw_mouse_buttons = function() {
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_color(c_white);
        
        // RMB / LMB label
        draw_text(mouse_button_x + mouse_button_size + mouse_button_spacing / 2, mouse_button_y - 25, "RMB / LMB");
        
        // Left button
        draw_roundrect(mouse_button_x, mouse_button_y, 
                      mouse_button_x + mouse_button_size, mouse_button_y + mouse_button_size, true);
        
        // Right button
        draw_roundrect(mouse_button_x + mouse_button_size + mouse_button_spacing, mouse_button_y,
                      mouse_button_x + (mouse_button_size * 2) + mouse_button_spacing, mouse_button_y + mouse_button_size, true);
    }
    
    /// @method draw_badges()
    static draw_badges = function() {
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_font(fnt_large);
        
        for (var i = 0; i < array_length(badges); i++) {
            var badge = badges[i];
            
            var draw_x = badge_start_x;
            var draw_y = badge_start_y + (i * badge_spacing) + badge.y_offset;
            
            draw_set_alpha(badge.alpha);
            
            var text_width = string_width(badge.text) * ui_scale;
            var text_height = string_height(badge.text) * ui_scale;
            var panel_padding = 20 * ui_scale;
            
            // Background panel
            draw_set_color(c_black);
            draw_rectangle(
                draw_x - panel_padding,
                draw_y - panel_padding,
                draw_x + text_width + panel_padding,
                draw_y + text_height + panel_padding,
                false
            );
            
            // Border
            draw_set_color(badge.color);
            draw_set_alpha(badge.alpha * 0.8);
            draw_rectangle(
                draw_x - panel_padding,
                draw_y - panel_padding,
                draw_x + text_width + panel_padding,
                draw_y + text_height + panel_padding,
                true
            );
            draw_set_alpha(badge.alpha);
            
            // Text
            draw_set_color(badge.color);
            draw_text_transformed(draw_x, draw_y, badge.text, ui_scale, ui_scale, 0);
            
            // Reward text
            if (badge.show_reward) {
                draw_set_color(c_yellow);
                draw_set_alpha(badge.alpha * 0.9);
                draw_set_font(fnt_default);
                var reward_text = "+" + string(badge.exp_reward) + " EXP  +" + string(badge.coin_reward) + " GOLD";
                draw_text_transformed(draw_x, draw_y + text_height + (5 * ui_scale), reward_text, ui_scale * 0.7, ui_scale * 0.7, 0);
                draw_set_font(fnt_large);
            }
        }
        
        draw_set_alpha(1);
        draw_set_font(fnt_default);
    }
    
    /// @method draw_totems()
    static draw_totems = function() {
        var active_count = GetActiveTotemCount();
        if (active_count == 0) return;
        
        var hud_x = 20;
        var hud_y = 100;
        var icon_size = 32;
        var spacing = 40;
        
        draw_set_font(fnt_default);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_white);
        
        draw_text(hud_x, hud_y, "Active Totems:");
        
        var index = 0;
        
        // Draw each active totem icon
        if (global.TotemDefinitions.Chaos.active) {
            draw_set_color(c_red);
            draw_circle(hud_x + index * spacing, hud_y + 20, icon_size / 2, false);
            draw_set_color(c_white);
            draw_text(hud_x + index * spacing - 8, hud_y + 30, "C");
            index++;
        }
        
        if (global.TotemDefinitions.Horde.active) {
            draw_set_color(c_orange);
            draw_circle(hud_x + index * spacing, hud_y + 20, icon_size / 2, false);
            draw_set_color(c_white);
            draw_text(hud_x + index * spacing - 8, hud_y + 30, "H");
            index++;
        }
        
        if (global.TotemDefinitions.Champion.active) {
            draw_set_color(c_purple);
            draw_circle(hud_x + index * spacing, hud_y + 20, icon_size / 2, false);
            draw_set_color(c_white);
            draw_text(hud_x + index * spacing - 8, hud_y + 30, "C");
            index++;
        }
        
        if (global.TotemDefinitions.Greed.active) {
            draw_set_color(c_yellow);
            draw_circle(hud_x + index * spacing, hud_y + 20, icon_size / 2, false);
            draw_set_color(c_white);
            draw_text(hud_x + index * spacing - 8, hud_y + 30, "G");
            index++;
        }
        
        if (global.TotemDefinitions.Fury.active) {
            draw_set_color(c_fuchsia);
            draw_circle(hud_x + index * spacing, hud_y + 20, icon_size / 2, false);
            draw_set_color(c_white);
            draw_text(hud_x + index * spacing - 8, hud_y + 30, "F");
            index++;
        }
        
        // Score multiplier
        var multiplier = GetScoreMultiplier();
        draw_set_color(c_yellow);
        draw_text(hud_x, hud_y + 60, "Score Multiplier: " + string(multiplier) + "x");
    }
    
    /// @method add_score(amount)
    static add_score = function(_amount) {
        target_score += _amount;
    }
    
    /// @method get_badge_rewards(type)
    static get_badge_rewards = function(_type) {
        switch (_type) {
            case UI_BADGE_TYPE.DOUBLE_KILL:
                return [20, 5, 200];
            case UI_BADGE_TYPE.TRIPLE_KILL:
                return [50, 15, 500];
            case UI_BADGE_TYPE.MULTI_KILL:
                return [100, 30, 1000];
            case UI_BADGE_TYPE.OVERKILL:
                return [150, 50, 1500];
            case UI_BADGE_TYPE.ENVIRONMENTAL_KILL:
                return [30, 10, 300];
            case UI_BADGE_TYPE.PERFECT_DODGE:
                return [25, 8, 250];
            case UI_BADGE_TYPE.BOSS_SLAIN:
                return [500, 100, 5000];
            case UI_BADGE_TYPE.COMBO_MASTER:
                return [80, 25, 800];
            case UI_BADGE_TYPE.HEADSHOT:
                return [40, 12, 400];
            case UI_BADGE_TYPE.REVENGE:
                return [60, 20, 600];
            default:
                return [10, 5, 100];
        }
    }
    
    /// @method show_badge(type)
    static show_badge = function(_type) {
        var badge_text = "";
        var badge_color = c_yellow;
        
        switch (_type) {
            case UI_BADGE_TYPE.DOUBLE_KILL:
                badge_text = "DOUBLE KILL!";
                badge_color = c_yellow;
                break;
            case UI_BADGE_TYPE.TRIPLE_KILL:
                badge_text = "TRIPLE KILL!";
                badge_color = c_orange;
                break;
            case UI_BADGE_TYPE.MULTI_KILL:
                badge_text = "MULTI KILL!";
                badge_color = c_red;
                break;
            case UI_BADGE_TYPE.OVERKILL:
                badge_text = "OVERKILL!";
                badge_color = c_purple;
                break;
            case UI_BADGE_TYPE.ENVIRONMENTAL_KILL:
                badge_text = "ENVIRONMENTAL!";
                badge_color = c_lime;
                break;
            case UI_BADGE_TYPE.PERFECT_DODGE:
                badge_text = "PERFECT DODGE!";
                badge_color = c_aqua;
                break;
            case UI_BADGE_TYPE.BOSS_SLAIN:
                badge_text = "BOSS SLAIN!";
                badge_color = c_yellow;
                break;
            case UI_BADGE_TYPE.COMBO_MASTER:
                badge_text = "COMBO MASTER!";
                badge_color = c_fuchsia;
                break;
            case UI_BADGE_TYPE.HEADSHOT:
                badge_text = "HEADSHOT!";
                badge_color = c_red;
                break;
            case UI_BADGE_TYPE.REVENGE:
                badge_text = "REVENGE!";
                badge_color = c_orange;
                break;
        }
        
        var rewards = get_badge_rewards(_type);
        var exp_reward = rewards[0];
        var coin_reward = rewards[1];
        var score_bonus = rewards[2];
        
        if (instance_exists(player)) {
            player.experience_points += exp_reward;
            player.gold += coin_reward;
            add_score(score_bonus);
        }
        
        array_push(badges, {
            text: badge_text,
            color: badge_color,
            alpha: 1.0,
            y_offset: 0,
            show_reward: true,
            exp_reward: exp_reward,
            coin_reward: coin_reward
        });
    }
	
	/// @method draw_combo_meter()
static draw_combo_meter = function() {
    if (!instance_exists(obj_game_manager)) return;
    
    var combo = obj_game_manager.score_manager.GetComboMultiplier();
    if (combo <= 1.0) return; // Don't show at 1x
    
    // Position (bottom center, above modifiers box)
    var meter_x = screen_width / 2;
    var meter_y = mod_box_y - 60;
    var meter_width = 200;
    var meter_height = 20;
    
    // Background
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_rectangle(meter_x - meter_width/2, meter_y, 
                   meter_x + meter_width/2, meter_y + meter_height, false);
    draw_set_alpha(1);
    
    // Combo fill (1.0 to 5.0 range)
    var combo_percent = (combo - 1.0) / 4.0; // 0 to 1
    var fill_width = meter_width * combo_percent;
    
    // Color based on combo level
    var fill_color = c_white;
    if (combo >= 4.0) fill_color = c_red;
    else if (combo >= 3.0) fill_color = c_orange;
    else if (combo >= 2.0) fill_color = c_yellow;
    else fill_color = c_lime;
    
    draw_set_color(fill_color);
    draw_rectangle(meter_x - meter_width/2, meter_y, 
                   meter_x - meter_width/2 + fill_width, meter_y + meter_height, false);
    
    // Border
    draw_set_color(c_white);
    draw_rectangle(meter_x - meter_width/2, meter_y, 
                   meter_x + meter_width/2, meter_y + meter_height, true);
    
    // Combo text
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(fnt_default);
    draw_text(meter_x, meter_y + meter_height/2, "x" + string_format(combo, 1, 1));
}
}

#endregion