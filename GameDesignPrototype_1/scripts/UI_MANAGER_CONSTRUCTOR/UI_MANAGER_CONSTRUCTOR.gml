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
    ui_scale = 1.3;
    
    // Top bar - streamlined
    top_bar_height = 80 * ui_scale;
    top_margin = 25 * ui_scale;
    
    // Score (top center)
    score_y = top_margin;
    
    // EXP bar (full width, below score)
    exp_bar_y = top_margin + 35 * ui_scale;
    exp_bar_margin = 20 * ui_scale; // Margin from screen edges
    exp_bar_height = 24 * ui_scale;
    
    // HP (top left)
    hp_x = 25 * ui_scale;
    hp_y = top_margin;
    
    // Bottom bar - weapons and mods only
    bottom_bar_height = 110 * ui_scale;
    bottom_margin = screen_height - (90 * ui_scale);
    
    // Weapons (bottom left, larger)
    weapon_x = 30 * ui_scale;
    weapon_y = bottom_margin;
    weapon_size = 70 * ui_scale;
    weapon_spacing = 85 * ui_scale;
    
    // Modifiers (bottom right, smaller, scrolling)
    mod_start_x = screen_width - (30 * ui_scale);
    mod_y = bottom_margin;
    mod_size = 45 * ui_scale;
    mod_spacing = 55 * ui_scale;
    max_visible_mods = 10; // Show more, they're smaller
    
    // Badge system (top-left list)
    badges = [];
    badge_start_x = 40 * ui_scale;
    badge_start_y = top_bar_height + (30 * ui_scale);
    badge_spacing = 70 * ui_scale;
    badge_float_speed = 1.2 * ui_scale;
    badge_fade_start_y = badge_start_y - (150 * ui_scale);
    
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
            
            badge.y_offset -= badge_float_speed;
            var current_y = badge_start_y + (i * badge_spacing) + badge.y_offset;
            
            if (current_y < badge_fade_start_y) {
                var fade_range = badge_fade_start_y - (badge_fade_start_y - (150 * ui_scale));
                var fade_progress = (badge_fade_start_y - current_y) / fade_range;
                badge.alpha = max(0, 1 - fade_progress);
            }
            
            if (badge.alpha <= 0 || current_y < -50) {
                array_delete(badges, i, 1);
            }
        }
    }
    
    /// @method draw()
    static draw = function() {
        if (!instance_exists(player)) return;
        
        // Draw black bars
        draw_black_bars();
        
        draw_set_font(fnt_default);
        
        // Top content
        draw_score();
        draw_hp();
        draw_exp_bar();
        
        // Badges
        draw_badges();
        
        // Bottom content
        draw_weapons();
        draw_modifiers();

		var active_count = GetActiveTotemCount();
		if (active_count == 0) exit;
		
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
    
    /// @method draw_black_bars()
    static draw_black_bars = function() {
        draw_set_color(c_black);
        draw_set_alpha(0.7);
        
        // Top bar
        draw_rectangle(0, 0, screen_width, top_bar_height, false);
        
        // Bottom bar
        draw_rectangle(0, screen_height - bottom_bar_height, screen_width, screen_height, false);
        
        draw_set_alpha(1);
        
        // Border lines
        draw_set_color(c_dkgray);
        draw_line_width(0, top_bar_height, screen_width, top_bar_height, 3 * ui_scale);
        draw_line_width(0, screen_height - bottom_bar_height, screen_width, screen_height - bottom_bar_height, 3 * ui_scale);
        
        draw_set_color(c_white);
    }
    
    /// @method draw_score()
    static draw_score = function() {
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_color(c_white);
        
        var score_text = "SCORE: " + string_format(floor(displayed_score), 6, 0);
        score_text = string_replace_all(score_text, " ", "0");
        
        // Shadow
        draw_set_alpha(0.3);
        draw_text_transformed(center_x + 2, score_y + 2, score_text, ui_scale, ui_scale, 0);
        draw_set_alpha(1);
        
        // Main text
        draw_set_font(fnt_large);
        draw_text_transformed(center_x, score_y, score_text, ui_scale, ui_scale, 0);
        draw_set_font(fnt_default);
    }
    
    /// @method draw_hp()
    static draw_hp = function() {
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        
        // Color based on HP percentage
        var hp_percent = player.hp / player.maxHp;
        var hp_color = c_white;
        if (hp_percent < 0.3) {
            hp_color = c_red;
        } else if (hp_percent < 0.6) {
            hp_color = c_orange;
        }
        
        draw_set_color(hp_color);
        var hp_text = "HP: " + string(floor(player.hp)) + "/" + string(player.maxHp);
        draw_text_transformed(hp_x, hp_y, hp_text, ui_scale, ui_scale, 0);
    }
    
    /// @method draw_exp_bar()
    static draw_exp_bar = function() {
        // Full width bar
        var bar_x = exp_bar_margin;
        var bar_width = screen_width - (exp_bar_margin * 2);
        var bar_y = exp_bar_y;
        
        // Calculate EXP percentage
        var exp_percent = 0;
        if (player.exp_to_next_level > 0) {
            exp_percent = (player.experience_points / player.exp_to_next_level) * 100;
        }
        
        // Background
        draw_set_color(c_black);
        draw_set_alpha(0.7);
        draw_rectangle(bar_x - 2, bar_y - 2, bar_x + bar_width + 2, bar_y + exp_bar_height + 2, false);
        draw_set_alpha(1);
        
        // Empty bar
        draw_set_color(c_dkgray);
        draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + exp_bar_height, false);
        
        // Filled bar
        var fill_width = (bar_width * exp_percent) / 100;
        draw_set_color(c_orange);
        draw_rectangle(bar_x, bar_y, bar_x + fill_width, bar_y + exp_bar_height, false);
        
        // Highlight
        draw_set_color(c_yellow);
        draw_set_alpha(0.5);
        draw_rectangle(bar_x, bar_y, bar_x + fill_width, bar_y + exp_bar_height / 2, false);
        draw_set_alpha(1);
        
        // Outline
        draw_set_color(c_white);
        draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + exp_bar_height, true);
        
        // Level text CENTERED ON BAR in contrasting color
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        // Draw level with outline for readability
        var level_text = "LV " + string(player.player_level);
        var text_x = bar_x + bar_width / 2;
        var text_y = bar_y + exp_bar_height / 2;
        
        // Black outline
        draw_set_color(c_black);
        for (var ox = -1; ox <= 1; ox++) {
            for (var oy = -1; oy <= 1; oy++) {
                if (ox != 0 || oy != 0) {
                    draw_text_transformed(text_x + ox, text_y + oy, level_text, ui_scale, ui_scale, 0);
                }
            }
        }
        
        // Main text in contrasting color (cyan/white)
        draw_set_color(c_aqua);
        draw_text_transformed(text_x, text_y, level_text, ui_scale, ui_scale, 0);
    }
    
    /// @method draw_weapons()
    static draw_weapons = function() {
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        // Draw 3 weapon slots (larger)
        for (var i = 0; i < 3; i++) {
            var draw_x = weapon_x + (i * weapon_spacing);
            var draw_y = weapon_y;
            
            // Slot background
            var is_active = (i == player.current_weapon_index);
            draw_set_color(is_active ? c_yellow : c_dkgray);
            draw_set_alpha(0.5);
            draw_rectangle(draw_x, draw_y, draw_x + weapon_size, draw_y + weapon_size, false);
            draw_set_alpha(1);
            
            // Slot outline
            draw_set_color(is_active ? c_white : c_gray);
            draw_rectangle(draw_x, draw_y, draw_x + weapon_size, draw_y + weapon_size, true);
            
            // Active glow
            if (is_active) {
                draw_set_color(c_yellow);
                draw_set_alpha(0.3);
                draw_rectangle(draw_x - 4, draw_y - 4, draw_x + weapon_size + 4, draw_y + weapon_size + 4, false);
                draw_set_alpha(1);
            }
            
            // Weapon icon
            draw_set_color(c_white);
            var weapon_name = "?";
            if (i < array_length(player.weapons) && player.weapons[i] != noone) {
                weapon_name = string(i + 1);
            }
            
            draw_text_transformed(draw_x + weapon_size / 2, draw_y + weapon_size / 2, weapon_name, ui_scale * 1.2, ui_scale * 1.2, 0);
            
            // Key number
            draw_set_color(c_ltgray);
            draw_text_transformed(draw_x + weapon_size / 2, draw_y + weapon_size + (12 * ui_scale), string(i + 1), ui_scale * 0.7, ui_scale * 0.7, 0);
        }
    }
    
    /// @method draw_modifiers()
    static draw_modifiers = function() {
        if (!variable_instance_exists(player, "mod_list")) return;
        
        var active_count = array_length(player.mod_list);
        if (active_count == 0) return;
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        // Draw modifiers (smaller, unlimited)
        var visible_count = min(active_count, max_visible_mods);
        
        for (var i = 0; i < visible_count; i++) {
            var draw_x = mod_start_x - (i * mod_spacing);
            var draw_y = mod_y + mod_size / 2;
            
            // Mod slot background
            draw_set_color(c_dkgray);
            draw_set_alpha(0.5);
            draw_circle(draw_x - mod_size / 2, draw_y, mod_size / 2, false);
            draw_set_alpha(1);
            
            // Mod icon outline
            draw_set_color(c_orange);
            draw_circle(draw_x - mod_size / 2, draw_y, mod_size / 2, true);
            
            // Mod icon
            draw_set_color(c_white);
            draw_text_transformed(draw_x - mod_size / 2, draw_y, "M", ui_scale * 0.7, ui_scale * 0.7, 0);
        }
        
        // Show overflow indicator if more than max visible
        if (active_count > max_visible_mods) {
            var overflow_x = mod_start_x - (max_visible_mods * mod_spacing);
            var overflow_y = mod_y + mod_size / 2;
            
            draw_set_halign(fa_center);
            draw_set_color(c_yellow);
            draw_text_transformed(overflow_x - mod_size, overflow_y, "+" + string(active_count - max_visible_mods), ui_scale * 0.6, ui_scale * 0.6, 0);
        }
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
}

#endregion