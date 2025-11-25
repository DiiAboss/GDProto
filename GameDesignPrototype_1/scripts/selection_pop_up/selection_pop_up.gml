/// SelectionPopup - Enhanced Card-Style Level Up UI
/// Features: Playing card layout, color-coded borders, entrance animations, upgrade support

function SelectionPopup(_x, _y, _options, _onSelect) constructor {
    x = _x;
    y = _y;
    options = _options;
    onSelect = _onSelect;
    total = array_length(options);

    // Card dimensions (playing card proportions)
    card_w = 140;
    card_h = 200;
    spacing = 180;
    y_offset = -20;

    // Animation scales
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
    
    // Animation timers
    intro_timer = 0;
    intro_duration = 40;
    glow_timer = 0;
    
    // Particles
    particles = [];
    
    // Cards with animation states
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

    /// @function GetCardColor(_option)
    static GetCardColor = function(_option) {
        if (!variable_struct_exists(_option, "mod_key")) return c_white;
        var mod_key = _option.mod_key;
        
        if (!variable_struct_exists(global.Modifiers, mod_key)) return c_white;
        var template = global.Modifiers[$ mod_key];
        
        if (!variable_struct_exists(template, "synergy_tags")) return c_white;
        var tags = template.synergy_tags;
        
        for (var i = 0; i < array_length(tags); i++) {
            switch (tags[i]) {
                case SYNERGY_TAG.FIRE: return make_color_rgb(255, 100, 50);
                case SYNERGY_TAG.ICE: return make_color_rgb(100, 200, 255);
                case SYNERGY_TAG.LIGHTNING: return make_color_rgb(180, 100, 255);
                case SYNERGY_TAG.POISON: return make_color_rgb(100, 255, 100);
                case SYNERGY_TAG.LIFESTEAL: return make_color_rgb(255, 50, 80);
                case SYNERGY_TAG.HOLY: return make_color_rgb(255, 255, 150);
                case SYNERGY_TAG.VAMPIRE: return make_color_rgb(150, 0, 50);
                case SYNERGY_TAG.EXPLOSIVE: return make_color_rgb(255, 150, 50);
                case SYNERGY_TAG.CHAIN: return make_color_rgb(200, 180, 255);
                case SYNERGY_TAG.STRENGTH: return make_color_rgb(255, 80, 80);
                case SYNERGY_TAG.SPEED: return make_color_rgb(100, 255, 200);
                case SYNERGY_TAG.CRITICAL: return make_color_rgb(255, 200, 50);
                case SYNERGY_TAG.TANKY: return make_color_rgb(150, 150, 180);
            }
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
            if (p.life <= 0) {
                array_delete(particles, i, 1);
            }
        }
    };

    step = function() {
        if (finished) return;
        if (!obj_game_manager.can_click) return;
        
        glow_timer += 0.05;
        UpdateParticles();
        
        // Intro animation
        if (intro_timer < intro_duration + (total * 8)) {
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
                        SpawnParticles(c.x, c.y, GetCardColor(options[i]), 5);
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
        }
        
        if (fading_in) {
            alpha = min(alpha + 0.08, 1);
            if (alpha >= 1) fading_in = false;
        }

        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);

        if (!confirmed) {
            if (keyboard_check_pressed(vk_left)) {
                selected = max(0, selected - 1);
                SpawnParticles(cards[selected].x, cards[selected].y, GetCardColor(options[selected]), 3);
            }
            if (keyboard_check_pressed(vk_right)) {
                selected = min(total - 1, selected + 1);
                SpawnParticles(cards[selected].x, cards[selected].y, GetCardColor(options[selected]), 3);
            }

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
                        SpawnParticles(c.x, c.y, GetCardColor(options[i]), 15);
                        if (is_callable(onSelect)) onSelect(selected, options[selected]);
                        break;
                    }
                }
            }

            if (!confirmed && keyboard_check_pressed(vk_enter)) {
                confirmed = true;
                pop_progress = 0;
                SpawnParticles(cards[selected].x, cards[selected].y, GetCardColor(options[selected]), 15);
                if (is_callable(onSelect)) onSelect(selected, options[selected]);
            }
            
            for (var i = 0; i < total; i++) {
                var c = cards[i];
                var target = (i == selected) ? highlight_scale : base_scale;
                c.scale = lerp(c.scale, target, lerp_speed);
                cards[i] = c;
            }
        }
        else if (!can_finish) {
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

        if (can_finish) {
            finished = true;
            if (variable_global_exists("selection_popup")) global.selection_popup = noone;
        }
    };

    static DrawCard = function(_index, _c, _opt) {
        var draw_alpha = alpha * _c.alpha;
        if (draw_alpha < 0.01) return;
        
        var cx = _c.x;
        var cy = _c.y;
        var sc = _c.scale;
        
        var half_w = (card_w * sc) / 2;
        var half_h = (card_h * sc) / 2;
        
        var card_color = GetCardColor(_opt);
        var is_selected = (_index == selected);
        var is_upgrade = false;
        if (variable_struct_exists(_opt, "current_level")) {
            is_upgrade = _opt.current_level > 0;
        }
        
        // Glow for selected
        if (is_selected && !confirmed) {
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
        if (variable_struct_exists(_opt, "name")) name_text = _opt.name;
        draw_text_transformed(cx, name_y, name_text, sc * 0.9, sc * 0.9, 0);
        
        // ICON
        var icon_y = cy - 15 * sc;
        var icon_size = 64 * sc;
        
        draw_set_alpha(draw_alpha * 0.5);
        draw_set_color(merge_color(card_color, c_black, 0.6));
        draw_circle(cx, icon_y, icon_size * 0.6, false);
        
        draw_set_alpha(draw_alpha);
        var spr = -1;
        if (variable_struct_exists(_opt, "sprite")) spr = _opt.sprite;
        
        if (sprite_exists(spr) && spr != -1) {
            var spr_w = sprite_get_width(spr);
            var spr_h = sprite_get_height(spr);
            var icon_scale = (icon_size * 0.8) / max(spr_w, spr_h);
            draw_sprite_ext(spr, 0, cx, icon_y, icon_scale, icon_scale, 0, c_white, draw_alpha);
        } else {
            draw_set_color(card_color);
            draw_text_transformed(cx, icon_y, "?", sc * 2, sc * 2, 0);
        }
        
        // Level indicator
        var current_level = 0;
        if (variable_struct_exists(_opt, "current_level")) current_level = _opt.current_level;
        
        if (current_level > 0 || is_upgrade) {
            var level_x = cx - half_w + 18 * sc;
            var level_y = cy + half_h - 25 * sc;
            
            draw_set_alpha(draw_alpha * 0.9);
            draw_set_color(c_dkgray);
            draw_circle(level_x, level_y, 14 * sc, false);
            draw_set_color(card_color);
            draw_circle(level_x, level_y, 14 * sc, true);
            
            draw_set_color(c_white);
            draw_text_transformed(level_x, level_y, string(current_level + 1), sc * 0.8, sc * 0.8, 0);
        }
        
        // NEW/UP badge
        var badge_x = cx + half_w - 25 * sc;
        var badge_y = cy - half_h + 15 * sc;
        
        draw_set_alpha(draw_alpha * 0.9);
        if (is_upgrade) {
            draw_set_color(c_lime);
            draw_roundrect(badge_x - 20*sc, badge_y - 8*sc, badge_x + 20*sc, badge_y + 8*sc, false);
            draw_set_color(c_black);
            draw_text_transformed(badge_x, badge_y, "UP", sc * 0.6, sc * 0.6, 0);
        } else {
            draw_set_color(c_yellow);
            draw_roundrect(badge_x - 22*sc, badge_y - 8*sc, badge_x + 22*sc, badge_y + 8*sc, false);
            draw_set_color(c_black);
            draw_text_transformed(badge_x, badge_y, "NEW", sc * 0.55, sc * 0.55, 0);
        }
        
        // Description (selected only)
        if (is_selected) {
            var desc_y = cy + half_h - 45 * sc;
            var desc_text = "No description";
            if (variable_struct_exists(_opt, "desc")) desc_text = _opt.desc;
            
            draw_set_alpha(draw_alpha * 0.9);
            draw_set_color(c_ltgray);
            draw_set_valign(fa_top);
            
            var max_width = (card_w - 20) * sc;
            draw_text_ext_transformed(cx, desc_y, desc_text, 14 * sc, max_width, sc * 0.7, sc * 0.7, 0);
        }
        
        draw_set_alpha(1);
    };

    draw = function() {
        if (finished) return;

        draw_set_alpha(0.85 * alpha);
        draw_set_color(c_black);
        draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
        draw_set_alpha(1);
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(fnt_large);
        draw_set_color(c_yellow);
        draw_set_alpha(alpha);
        draw_text_transformed(x, y - 160, "LEVEL UP!", 1.5, 1.5, 0);
        
        draw_set_font(fnt_default);
        draw_set_color(c_ltgray);
        draw_text(x, y - 130, "Choose a modifier");

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
            if (i != selected) DrawCard(i, cards[i], options[i]);
        }
        // Selected on top
        if (selected >= 0 && selected < total) {
            DrawCard(selected, cards[selected], options[selected]);
        }

        if (!confirmed) {
            draw_set_alpha(alpha * 0.7);
            draw_set_color(c_white);
            draw_set_font(fnt_default);
            draw_text(x, y + 180, "[A/D] Navigate  |  [ENTER] or [CLICK] Select");
        }
        
        draw_set_alpha(1);
    };
}