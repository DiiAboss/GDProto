/// @desc Enhanced popup with skip option
function ChestPopup(_x, _y, _rewards, _chest_cost, _on_select, _on_skip) constructor {
    x = _x;
    y = _y;
    rewards = _rewards;
    chest_cost = _chest_cost;
    onSelect = _on_select;
    onSkip = _on_skip;
    total = array_length(rewards);
    
    // Layout
    spacing = 220;
    card_w = 160;
    card_h = 220;
    y_offset = -80;
    
    base_scale = 0.92;
    highlight_scale = 1.12;
    pop_scale = 1.4;
    lerp_speed = 0.18;
    
    // State
    alpha = 0;
    fading_in = true;
    selected = 0;
    hover = -1;
    confirmed = false;
    pop_progress = 0;
    can_finish = false;
    finished = false;
    skipped = false;
    
    // Skip button
    skip_button = {
        x: x,
        y: y + 240,
        w: 200,
        h: 50,
        hover: false,
        refund: GetChestSkipRefund(chest_cost, obj_player)
    };
    
    // Card positions
    cards = [];
    var start_x = x - ((total - 1) * spacing) * 0.5;
    for (var i = 0; i < total; i++) {
        var cx = start_x + i * spacing;
        cards[i] = {
            home_x: cx,
            x: cx,
            y: y + y_offset,
            scale: base_scale,
            alpha: 1
        };
    }
    
    step = function() {
        if (finished) return;
        
        // Fade in
        if (fading_in) {
            alpha = min(alpha + 0.12, 1);
            if (alpha >= 1) fading_in = false;
        }
        
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        
        // Before confirmation
        if (!confirmed) {
            // Keyboard nav
            if (keyboard_check_pressed(vk_left)) selected = max(0, selected - 1);
            if (keyboard_check_pressed(vk_right)) selected = min(total - 1, selected + 1);
            
            // Skip button hover/click
            skip_button.hover = point_in_rectangle(
                mx, my,
                skip_button.x - skip_button.w/2,
                skip_button.y - skip_button.h/2,
                skip_button.x + skip_button.w/2,
                skip_button.y + skip_button.h/2
            );
            
            if (skip_button.hover && mouse_check_button_pressed(mb_left)) {
			    skipped = true;
			    confirmed = true;
			    if (is_callable(onSkip)) {
			        onSkip(skip_button.refund); // Pass just the refund amount
			    }
			    return;
			}
            
            // Card hover/click
            hover = -1;
            for (var i = 0; i < total; i++) {
                var c = cards[i];
                var halfw = card_w * c.scale * 0.5;
                var halfh = card_h * c.scale * 0.5;
                if (mx > c.x - halfw && mx < c.x + halfw && 
                    my > c.y - halfh && my < c.y + halfh) {
                    hover = i;
                    if (mouse_check_button_pressed(mb_left)) {
					    selected = i;
					    confirmed = true;
					    pop_progress = 0;
					    if (is_callable(onSelect)) {
					        onSelect(selected, rewards[selected]); // Pass index AND reward struct
					    }
					    break;
}
                }
            }
            
            // Keyboard confirm
            if (!confirmed && keyboard_check_pressed(vk_enter)) {
                confirmed = true;
                pop_progress = 0;
                if (is_callable(onSelect)) onSelect(selected, rewards[selected]);
            }
        }
        // After confirmation
        else if (!can_finish && !skipped) {
            pop_progress = min(pop_progress + 0.08, 1);
            
            for (var i = 0; i < total; i++) {
                var c = cards[i];
                if (i == selected) {
                    c.x = lerp(c.x, x, 0.18);
                    c.y = lerp(c.y, y - 20, 0.18);
                    c.scale = lerp(c.scale, pop_scale, 0.18);
                    c.alpha = 1;
                } else {
                    c.scale = lerp(c.scale, 0.25, 0.12);
                    c.alpha = lerp(c.alpha, 0, 0.12);
                }
                cards[i] = c;
            }
            
            if (pop_progress >= 0.99) {
                can_finish = true;
                for (var i = 0; i < total; i++) {
                    if (i != selected) {
                        cards[i].alpha = 0;
                        cards[i].scale = 0.25;
                    }
                }
            }
        } else if (skipped) {
            // Fade out all cards on skip
            for (var i = 0; i < total; i++) {
                cards[i].alpha = lerp(cards[i].alpha, 0, 0.15);
            }
            if (cards[0].alpha < 0.01) can_finish = true;
        }
        
        // Wait for confirmation
        if (can_finish) {
            if (keyboard_check_pressed(vk_anykey) || mouse_check_button_pressed(mb_left)) {
                finished = true;
            }
        }
        
        // Idle hover scaling
        if (!confirmed) {
            for (var i = 0; i < total; i++) {
                var c = cards[i];
                var target = (i == (hover >= 0 ? hover : selected)) ? highlight_scale : base_scale;
                c.scale = lerp(c.scale, target, lerp_speed);
                cards[i] = c;
            }
        }
    };
    
    draw = function() {
    if (finished) return;
    
    // Safety check
    if (rewards == undefined || !is_array(rewards) || array_length(rewards) == 0) return;
    
    // Overlay
    draw_set_alpha(0.8 * alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, window_get_width(), window_get_height(), false);
    draw_set_alpha(1);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Cards
    for (var i = 0; i < total; i++) {
        if (i >= array_length(cards)) continue; // Safety
        if (i >= array_length(rewards)) continue; // Safety
        
        var c = cards[i];
        var reward = rewards[i];
        var draw_alpha = alpha * c.alpha;
        draw_sprite_ext(reward.sprite, 0, c.x, c.y, c.scale, c.scale, 0, c_white, draw_alpha);
        
        if (c.alpha > 0.05) {
            draw_set_alpha(draw_alpha);
            draw_set_color(c_white);
            draw_set_font(fnt_default);
            draw_text(c.x, c.y + (card_h * c.scale)/2 + 18, reward.name);
            draw_set_alpha(1);
        }
        
        if (!confirmed && (i == selected || i == hover)) {
            draw_set_alpha(alpha * 0.35);
            draw_rectangle(c.x - (card_w*c.scale)/2, c.y - (card_h*c.scale)/2, 
                          c.x + (card_w*c.scale)/2, c.y + (card_h*c.scale)/2, false);
            draw_set_alpha(1);
        }
    }
    
    // Skip button (only if not confirmed)
    if (!confirmed && alpha > 0.01) {
        var btn = skip_button;
        var btn_alpha = alpha * (btn.hover ? 1.0 : 0.7);
        
        draw_set_alpha(btn_alpha);
        draw_set_color(btn.hover ? c_yellow : c_dkgray);
        draw_rectangle(btn.x - btn.w/2, btn.y - btn.h/2, 
                      btn.x + btn.w/2, btn.y + btn.h/2, false);
        
        draw_set_color(c_white);
        draw_set_font(fnt_default);
        draw_text(btn.x, btn.y - 8, "Skip for " + string(btn.refund) + " Gold");
        draw_set_alpha(1);
    }
    
    // Description - with safety checks
    if (!skipped && array_length(rewards) > 0) {
        var desc_index = selected;
        
        if (!confirmed && hover >= 0 && hover < array_length(rewards)) {
            desc_index = hover;
        }
        
        // Clamp to valid range
        desc_index = clamp(desc_index, 0, array_length(rewards) - 1);
        
        var desc_reward = rewards[desc_index];
        
        if (desc_reward != undefined && alpha > 0.01) {
            draw_set_alpha(alpha);
            draw_set_color(c_white);
            draw_set_font(fnt_default);
            draw_text(x, y + 180, desc_reward.desc);
            draw_set_alpha(1);
        }
    }
};
}