/// SelectionPopup.gml
function SelectionPopup(_x, _y, _options, _onSelect) constructor {
    x = _x;
    y = _y;
    options = _options;
    onSelect = _onSelect;
    total = array_length(options);

    // layout
    spacing = 220;
    card_w = 160;
    card_h = 220;
    y_offset = -40;

    base_scale = 0.92;
    highlight_scale = 1.12;
    pop_scale = 1.4;
    lerp_speed = 0.18;

    // state
    alpha = 0;
    fading_in = true;
    selected = 0;
    hover = -1;
    confirmed = false;
    pop_progress = 0;
    can_finish = false;
    finished = false;

    // cards positions
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

    /// STEP method
    step = function() {
        if (finished) return;

        // fade in overlay
        if (fading_in) {
            alpha = min(alpha + 0.12, 1);
            if (alpha >= 1) fading_in = false;
        }

        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);

        // ---------- BEFORE confirmation ----------
        if (!confirmed) {
            // keyboard nav
            if (keyboard_check_pressed(vk_left)) selected = max(0, selected - 1);
            if (keyboard_check_pressed(vk_right)) selected = min(total - 1, selected + 1);

            // hover detection & click
            hover = -1;
            for (var i = 0; i < total; i++) {
                var c = cards[i];
                var halfw = card_w * c.scale * 0.5;
                var halfh = card_h * c.scale * 0.5;
                if (mx > c.x - halfw && mx < c.x + halfw && my > c.y - halfh && my < c.y + halfh) {
                    hover = i;
                    if (mouse_check_button_pressed(mb_left)) {
                        selected = i;
                        confirmed = true;
                        pop_progress = 0;
                        if (is_callable(onSelect)) onSelect(selected, options[selected]);
                        break;
                    }
                }
            }

            // keyboard confirm
            if (!confirmed && keyboard_check_pressed(vk_enter)) {
                confirmed = true;
                pop_progress = 0;
                if (is_callable(onSelect)) onSelect(selected, options[selected]);
            }
        }
        // ---------- AFTER confirmation ----------
        else if (!can_finish) {
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
                // force non-selected cards invisible
                for (var i = 0; i < total; i++) {
                    if (i != selected) {
                        cards[i].alpha = 0;
                        cards[i].scale = 0.25;
                    }
                }
            }
        }

        // ---------- WAIT FOR ANY KEY / CLICK ----------
        if (can_finish) {
            if (keyboard_check_pressed(vk_anykey) || mouse_check_button_pressed(mb_left)) {
                finished = true;
                if (variable_global_exists("selection_popup")) global.selection_popup = undefined;
            }
        }

        // ---------- IDLE hover scaling ----------
        if (!confirmed) {
            for (var i = 0; i < total; i++) {
                var c = cards[i];
                var target = (i == (hover >= 0 ? hover : selected)) ? highlight_scale : base_scale;
                c.scale = lerp(c.scale, target, lerp_speed);
                cards[i] = c;
            }
        }
    };

    /// DRAW method
    draw = function() {
        if (finished) return;

        // overlay
        draw_set_alpha(0.8 * alpha);
        draw_set_color(c_black);
        draw_rectangle(0, 0, window_get_width(), window_get_height(), false);
        draw_set_alpha(1);

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        // draw cards
        for (var i = 0; i < total; i++) {
            var c = cards[i];
            var opt = options[i];
            var draw_alpha = alpha * c.alpha;
            draw_sprite_ext(opt.sprite, 0, c.x, c.y, c.scale, c.scale, 0, c_white, draw_alpha);

            // name below card
            if (c.alpha > 0.05) {
                draw_set_alpha(draw_alpha);
                draw_set_color(c_white);
                draw_set_font(fnt_default);
                draw_text(c.x, c.y + (card_h * c.scale)/2 + 18, opt.name);
                draw_set_alpha(1);
            }

            // small border for hover/selected pre-confirm
            if (!confirmed && (i == selected || i == hover)) {
                draw_set_alpha(alpha * 0.35);
                draw_rectangle(c.x - (card_w*c.scale)/2, c.y - (card_h*c.scale)/2, c.x + (card_w*c.scale)/2, c.y + (card_h*c.scale)/2, false);
                draw_set_alpha(1);
            }
        }

        // description
        var desc_opt = confirmed ? options[selected] : (hover >= 0 ? options[hover] : options[selected]);
        if (desc_opt != undefined && alpha > 0.01) {
            draw_set_alpha(alpha);
            draw_set_color(c_white);
            draw_set_font(fnt_default);
            draw_text(x, y + 200, desc_opt.name);
            draw_set_color(c_ltgray);
            draw_text(x, y + 230, desc_opt.desc);
            draw_set_alpha(1);
        }
    };
}
