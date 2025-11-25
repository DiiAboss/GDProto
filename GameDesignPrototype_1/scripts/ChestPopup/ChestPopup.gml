/// @desc Enhanced chest popup with card styling
function ChestPopup(_x, _y, _rewards, _chest_cost, _on_select, _on_skip) constructor {
    x = _x;
    y = _y;
    rewards = _rewards;
    chest_cost = _chest_cost;
    onSelect = _on_select;
    onSkip = _on_skip;
    total = array_length(rewards);
    
    // Card dimensions
    card_w = 140;
    card_h = 200;
    spacing = 180;
    y_offset = -40;
    
    // Animation
    base_scale = 1.0;
    highlight_scale = 1.15;
    pop_scale = 1.5;
    lerp_speed = 0.15;
    
    // State
    alpha = 0;
    fading_in = true;
    selected = floor(total / 2);
    hover = -1;
    confirmed = false;
    pop_progress = 0;
    can_finish = false;
    finished = false;
    skipped = false;
    
    // Animation timers
    intro_timer = 0;
    glow_timer = 0;
    particles = [];
    
    // Skip button
    skip_button = {
        x: x,
        y: y + 220,
        w: 220,
        h: 45,
        hover: false,
        refund: GetChestSkipRefund(chest_cost, obj_player)
    };
    
    // Card positions with animation
    cards = [];
    var start_x = x - ((total - 1) * spacing) * 0.5;
    for (var i = 0; i < total; i++) {
        var cx = start_x + i * spacing;
        cards[i] = {
            home_x: cx,
            home_y: y + y_offset,
            x: cx,
            y: y + 400,
            scale: base_scale,
            alpha: 0,
            rotation: random_range(-5, 5),
            intro_delay: i * 8,
            intro_done: false,
            wobble: 0
        };
    }
    
    /// @function GetRewardColor(_reward)
    static GetRewardColor = function(_reward) {
        // Color by rarity first
        var rarity = 0;
        if (variable_struct_exists(_reward, "rarity")) rarity = _reward.rarity;
        
        switch (rarity) {
            case 3: return make_color_rgb(255, 200, 50);  // Legendary - Gold
            case 2: return make_color_rgb(180, 100, 255); // Rare - Purple
            case 1: return make_color_rgb(100, 200, 255); // Uncommon - Blue
        }
        
        // Color by type
        var reward_type = RewardType.MODIFIER;
        if (variable_struct_exists(_reward, "type")) reward_type = _reward.type;
        
        switch (reward_type) {
            case RewardType.WEAPON: return make_color_rgb(255, 150, 50);  // Orange
            case RewardType.MODIFIER: return make_color_rgb(100, 255, 150); // Green
            case RewardType.ITEM: return make_color_rgb(200, 200, 200);   // Gray
        }
        
        return c_white;
    };
    
    static SpawnParticles = function(_x, _y, _color, _count) {
        for (var i = 0; i < _count; i++) {
            array_push(particles, {
                x: _x + random_range(-30, 30),
                y: _y + random_range(-50, 50),
                vx: random_range(-1, 1),
                vy: random_range(-2, -0.5),
                life: random_range(30, 60),
                max_life: 60,
                size: random_range(2, 5),
                color: _color
            });
        }
    };
    
    static UpdateParticles = function() {
        for (var i = array_length(particles) - 1; i >= 0; i--) {
            var p = particles[i];
            p.x += p.vx;
            p.y += p.vy;
            p.life--;
            if (p.life <= 0) array_delete(particles, i, 1);
        }
    };
    
    step = function() {
        if (finished) return;
        
        glow_timer += 0.05;
        UpdateParticles();
        
        // Intro animation
        intro_timer++;
        for (var i = 0; i < total; i++) {
            var c = cards[i];
            if (intro_timer > c.intro_delay && !c.intro_done) {
                var progress = (intro_timer - c.intro_delay) / 20;
                if (progress >= 1) {
                    c.intro_done = true;
                    c.y = c.home_y;
                    c.alpha = 1;
                    c.wobble = 10;
                    SpawnParticles(c.x, c.y, GetRewardColor(rewards[i]), 5);
                } else {
                    var ease = 1 - power(1 - progress, 3);
                    c.y = lerp(y + 400, c.home_y, ease);
                    c.alpha = ease;
                }
            }
            if (c.wobble > 0) {
                c.wobble *= 0.9;
                c.rotation = sin(intro_timer * 0.5) * c.wobble;
            }
            cards[i] = c;
        }
        
        // Fade in
        if (fading_in) {
            alpha = min(alpha + 0.08, 1);
            if (alpha >= 1) fading_in = false;
        }
        
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        
        if (!confirmed && !skipped) {
            // Keyboard nav
            if (keyboard_check_pressed(vk_left)) {
                selected = max(0, selected - 1);
                SpawnParticles(cards[selected].x, cards[selected].y, GetRewardColor(rewards[selected]), 3);
            }
            if (keyboard_check_pressed(vk_right)) {
                selected = min(total - 1, selected + 1);
                SpawnParticles(cards[selected].x, cards[selected].y, GetRewardColor(rewards[selected]), 3);
            }
            
            // Card hover/click
            hover = -1;
            for (var i = 0; i < total; i++) {
                var c = cards[i];
                var halfw = card_w * c.scale * 0.5;
                var halfh = card_h * c.scale * 0.5;
                if (mx > c.x - halfw && mx < c.x + halfw && my > c.y - halfh && my < c.y + halfh) {
                    hover = i;
                    if (hover != selected) selected = hover;
                    if (mouse_check_button_pressed(mb_left)) {
                        selected = i;
                        confirmed = true;
                        pop_progress = 0;
                        SpawnParticles(c.x, c.y, GetRewardColor(rewards[i]), 15);
                        if (is_callable(onSelect)) onSelect(selected, rewards[selected]);
                        break;
                    }
                }
            }
            
            // Skip button hover/click
            var btn = skip_button;
            btn.hover = (mx > btn.x - btn.w/2 && mx < btn.x + btn.w/2 &&
                        my > btn.y - btn.h/2 && my < btn.y + btn.h/2);
            
            if (btn.hover && mouse_check_button_pressed(mb_left)) {
                skipped = true;
                if (is_callable(onSkip)) onSkip(btn.refund);
            }
            
            // Keyboard confirm
            if (!confirmed && keyboard_check_pressed(vk_enter)) {
                confirmed = true;
                pop_progress = 0;
                SpawnParticles(cards[selected].x, cards[selected].y, GetRewardColor(rewards[selected]), 15);
                if (is_callable(onSelect)) onSelect(selected, rewards[selected]);
            }
            
            // Idle scaling
            for (var i = 0; i < total; i++) {
                var c = cards[i];
                var target = (i == selected) ? highlight_scale : base_scale;
                c.scale = lerp(c.scale, target, lerp_speed);
                cards[i] = c;
            }
        }
        else if (confirmed && !can_finish) {
            pop_progress = min(pop_progress + 0.06, 1);
            
            for (var i = 0; i < total; i++) {
                var c = cards[i];
                if (i == selected) {
                    c.x = lerp(c.x, x, 0.15);
                    c.y = lerp(c.y, y - 30, 0.15);
                    c.scale = lerp(c.scale, pop_scale, 0.15);
                    c.alpha = 1;
                    c.rotation = lerp(c.rotation, 0, 0.2);
                } else {
                    c.scale = lerp(c.scale, 0.3, 0.1);
                    c.alpha = lerp(c.alpha, 0, 0.1);
                }
                cards[i] = c;
            }
            
            if (pop_progress >= 0.99) can_finish = true;
        }
        else if (skipped && !can_finish) {
            // Fade out all cards when skipped
            for (var i = 0; i < total; i++) {
                var c = cards[i];
                c.alpha = lerp(c.alpha, 0, 0.15);
                c.scale = lerp(c.scale, 0.5, 0.1);
                cards[i] = c;
            }
            
            if (cards[0].alpha < 0.05) can_finish = true;
        }
        
        if (can_finish) {
            finished = true;
            if (variable_global_exists("chest_popup")) global.chest_popup = noone;
        }
    };
    
    static DrawCard = function(_index, _c, _reward) {
        var draw_alpha = alpha * _c.alpha;
        if (draw_alpha < 0.01) return;
        
        var cx = _c.x;
        var cy = _c.y;
        var sc = _c.scale;
        
        var half_w = (card_w * sc) / 2;
        var half_h = (card_h * sc) / 2;
        
        var card_color = GetRewardColor(_reward);
        var is_selected = (_index == selected);
        
        // Get reward type
        var reward_type = RewardType.MODIFIER;
        if (variable_struct_exists(_reward, "type")) reward_type = _reward.type;
        
        // Glow for selected
        if (is_selected && !confirmed && !skipped) {
            var glow_pulse = 0.3 + sin(glow_timer * 2) * 0.15;
            draw_set_alpha(draw_alpha * glow_pulse);
            draw_set_color(card_color);
            for (var g = 3; g >= 1; g--) {
                var glow_size = g * 4 * sc;
                draw_roundrect_ext(
                    cx - half_w - glow_size, cy - half_h - glow_size,
                    cx + half_w + glow_size, cy + half_h + glow_size,
                    12 * sc, 12 * sc, false
                );
            }
        }
        
        // Card background
        draw_set_alpha(draw_alpha * 0.95);
        draw_set_color(c_black);
        draw_roundrect_ext(cx - half_w, cy - half_h, cx + half_w, cy + half_h, 8 * sc, 8 * sc, false);
        
        // Inner area
        draw_set_alpha(draw_alpha * 0.8);
        draw_set_color(make_color_rgb(30, 30, 40));
        draw_roundrect_ext(cx - half_w + 4*sc, cy - half_h + 4*sc, cx + half_w - 4*sc, cy + half_h - 4*sc, 6 * sc, 6 * sc, false);
        
        // Border
        draw_set_alpha(draw_alpha);
        draw_set_color(is_selected ? card_color : merge_color(card_color, c_dkgray, 0.5));
        var border_thick = is_selected ? 3 : 2;
        for (var b = 0; b < border_thick; b++) {
            draw_roundrect_ext(cx - half_w + b, cy - half_h + b, cx + half_w - b, cy + half_h - b, 8 * sc, 8 * sc, true);
        }
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(fnt_default);
        
        // NAME at top
        var name_y = cy - half_h + 22 * sc;
        draw_set_color(merge_color(card_color, c_black, 0.7));
        draw_rectangle(cx - half_w + 6*sc, name_y - 12*sc, cx + half_w - 6*sc, name_y + 12*sc, false);
        
        draw_set_color(c_white);
        var name_text = "Unknown";
        if (variable_struct_exists(_reward, "name")) name_text = _reward.name;
        draw_text_transformed(cx, name_y, name_text, sc * 0.85, sc * 0.85, 0);
        
        // ICON
        var icon_y = cy - 15 * sc;
        var icon_size = 64 * sc;
        
        draw_set_alpha(draw_alpha * 0.5);
        draw_set_color(merge_color(card_color, c_black, 0.6));
        draw_circle(cx, icon_y, icon_size * 0.6, false);
        
        draw_set_alpha(draw_alpha);
        var spr = -1;
        if (variable_struct_exists(_reward, "sprite")) spr = _reward.sprite;
        
        if (sprite_exists(spr) && spr != -1) {
            var spr_w = sprite_get_width(spr);
            var spr_h = sprite_get_height(spr);
            var icon_scale = (icon_size * 0.8) / max(spr_w, spr_h);
            draw_sprite_ext(spr, 0, cx, icon_y, icon_scale, icon_scale, 0, c_white, draw_alpha);
        } else {
            draw_set_color(card_color);
            draw_text_transformed(cx, icon_y, "?", sc * 2, sc * 2, 0);
        }
        
        // TYPE badge (top right)
        var badge_x = cx + half_w - 25 * sc;
        var badge_y = cy - half_h + 15 * sc;
        var badge_text = "MOD";
        var badge_color = c_lime;
        
        switch (reward_type) {
            case RewardType.WEAPON:
                badge_text = "WPN";
                badge_color = make_color_rgb(255, 150, 50);
                break;
            case RewardType.ITEM:
                badge_text = "ITEM";
                badge_color = c_gray;
                break;
        }
        
        draw_set_alpha(draw_alpha * 0.9);
        draw_set_color(badge_color);
        draw_roundrect(badge_x - 20*sc, badge_y - 8*sc, badge_x + 20*sc, badge_y + 8*sc, false);
        draw_set_color(c_black);
        draw_text_transformed(badge_x, badge_y, badge_text, sc * 0.55, sc * 0.55, 0);
        
        // RARITY stars (bottom left)
        var rarity = 0;
        if (variable_struct_exists(_reward, "rarity")) rarity = _reward.rarity;
        
        if (rarity > 0) {
            var star_x = cx - half_w + 15 * sc;
            var star_y = cy + half_h - 20 * sc;
            draw_set_color(c_yellow);
            for (var s = 0; s < rarity; s++) {
                draw_text_transformed(star_x + (s * 12 * sc), star_y, "*", sc, sc, 0);
            }
        }
        
        // Description (selected only)
        if (is_selected && !skipped) {
            var desc_y = cy + half_h - 50 * sc;
            var desc_text = "No description";
            if (variable_struct_exists(_reward, "desc")) desc_text = _reward.desc;
            
            draw_set_alpha(draw_alpha * 0.9);
            draw_set_color(c_ltgray);
            draw_set_valign(fa_top);
            
            var max_width = (card_w - 16) * sc;
            draw_text_ext_transformed(cx, desc_y, desc_text, 12 * sc, max_width, sc * 0.65, sc * 0.65, 0);
        }
        
        draw_set_alpha(1);
    };
    
    draw = function() {
        if (finished) return;
        if (rewards == noone || !is_array(rewards) || array_length(rewards) == 0) return;
        
        // Overlay
        draw_set_alpha(0.85 * alpha);
        draw_set_color(c_black);
        draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
        draw_set_alpha(1);
        
        // Title
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(fnt_large);
        draw_set_color(c_yellow);
        draw_set_alpha(alpha);
        draw_text_transformed(x, y - 160, "CHEST REWARDS", 1.3, 1.3, 0);
        
        draw_set_font(fnt_default);
        draw_set_color(c_ltgray);
        draw_text(x, y - 130, "Choose your reward");
        
        // Particles
        for (var i = 0; i < array_length(particles); i++) {
            var p = particles[i];
            var p_alpha = (p.life / p.max_life) * alpha;
            draw_set_alpha(p_alpha);
            draw_set_color(p.color);
            draw_circle(p.x, p.y, p.size, false);
        }
        
        // Draw non-selected cards first
        for (var i = 0; i < total; i++) {
            if (i >= array_length(cards) || i >= array_length(rewards)) continue;
            if (i != selected) DrawCard(i, cards[i], rewards[i]);
        }
        // Selected on top
        if (selected >= 0 && selected < total) {
            DrawCard(selected, cards[selected], rewards[selected]);
        }
        
        // Skip button
        if (!confirmed && !skipped && alpha > 0.5) {
            var btn = skip_button;
            var btn_alpha = alpha * (btn.hover ? 1.0 : 0.7);
            
            draw_set_alpha(btn_alpha * 0.9);
            draw_set_color(btn.hover ? c_yellow : make_color_rgb(60, 60, 60));
            draw_roundrect(btn.x - btn.w/2, btn.y - btn.h/2, btn.x + btn.w/2, btn.y + btn.h/2, false);
            
            draw_set_alpha(btn_alpha);
            draw_set_color(btn.hover ? c_black : c_white);
            draw_text(btn.x, btn.y, "Skip for " + string(btn.refund) + " Gold");
        }
        
        // Instructions
        if (!confirmed && !skipped) {
            draw_set_alpha(alpha * 0.7);
            draw_set_color(c_white);
            draw_set_font(fnt_default);
            draw_text(x, y + 270, "[A/D] Navigate  |  [ENTER] or [CLICK] Select");
        }
        
        draw_set_alpha(1);
    };
}