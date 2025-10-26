/// SelectionPopup.gml
/// ------------------------------------------------------------
/// Component: SelectionPopup
/// Role in the larger system:
///  - Lightweight GUI picker for N options (cards). Owns input handling,
///    hover/selection logic, confirmation animation, and dismissal.
///  - Emits a single selection via `onSelect(index, options[index])` exactly
///    once when confirmed; caller owns applying the choice and closing flow.
///  - Designed to live under a global pointer (e.g., global.selection_popup)
///    and be stepped/drawn from a GUI controller’s Step/Draw GUI events.
/// Notes:
///  - All coordinates use GUI space; cards precompute their home positions and
///    animate through scale/alpha to keep layout simple and deterministic.
/// ------------------------------------------------------------
function SelectionPopup(_x, _y, _options, _onSelect) constructor {
    x = _x;
    y = _y;
    options = _options;      // Array of { sprite, name, desc, ... }
    onSelect = _onSelect;    // Callback: (index, option)
    total = array_length(options);

    // --- Layout tuning ---------------------------------------
    spacing = 220;           // Horizontal gap between card centers
    card_w = 160;            // Logical card width for hit tests/borders
    card_h = 220;            // Logical card height for hit tests/borders
    y_offset = -40;          // Slight lift so label/desc fits underneath

    base_scale = 0.92;       // Idle size
    highlight_scale = 1.12;  // Hover/selected (pre‑confirm) emphasis
    pop_scale = 1.4;         // Post‑confirm “pop” size for the chosen card
    lerp_speed = 0.18;       // General easing factor for scale smoothing

    // --- State machine ---------------------------------------
    alpha = 0;               // Overlay/card fade‑in 0→1
    fading_in = true;        // Overlay is still rising in
    selected = 0;            // Current cursor (keyboard or last hover)
    hover = -1;              // Which card mouse is over (or -1)
    confirmed = false;       // Set when user confirms selection
    pop_progress = 0;        // 0→1 progress of the confirm animation
    can_finish = false;      // Becomes true after pop completes
    finished = false;        // When true, popup is done and stops drawing

    // --- Card transforms -------------------------------------
    cards = [];
    var start_x = x - ((total - 1) * spacing) * 0.5; // Center pack around x
    for (var i = 0; i < total; i++) {
        var cx = start_x + i * spacing;
        cards[i] = {
            home_x: cx,  // Home anchor (unused in current anim but helpful)
            x: cx,
            y: y + y_offset,
            scale: base_scale,
            alpha: 1
        };
    }

    /// STEP method
    /// Drives the state machine: fade‑in → selection/hover input → confirm
    /// animation → wait‑to‑dismiss on any key/click. Emits `onSelect` once.
    step = function() {
        if (finished) return;

        // Fade in the dimming overlay and cards
        if (fading_in) {
            alpha = min(alpha + 0.12, 1);
            if (alpha >= 1) fading_in = false;
        }

        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);

        // ---------- BEFORE confirmation ----------
        if (!confirmed) {
            // Keyboard navigation snaps the selection index
            if (keyboard_check_pressed(vk_left)) selected = max(0, selected - 1);
            if (keyboard_check_pressed(vk_right)) selected = min(total - 1, selected + 1);

            // Mouse hover detection + click confirm (also sets selection)
            hover = -1;
            for (var i = 0; i < total; i++) {
                var c = cards[i];
                var halfw = card_w * c.scale * 0.5;
                var halfh = card_h * c.scale * 0.5;
                if (mx > c.x - halfw && mx < c.x + halfw && my > c.y - halfh && my < c.y + halfh) {
                    hover = i;
                    selected = hover; // Keep keyboard and mouse in sync
                    if (mouse_check_button_pressed(mb_left)) {
                        selected = i;
                        confirmed = true;          // Lock selection
                        pop_progress = 0;          // Start pop anim
                        if (is_callable(onSelect)) onSelect(selected, options[selected]); // Emit
                        break;
                    }
                }
            }

            // Keyboard confirm (Enter) mirrors mouse click behavior
            if (!confirmed && keyboard_check_pressed(vk_enter)) {
                confirmed = true;
                pop_progress = 0;
                if (is_callable(onSelect)) onSelect(selected, options[selected]);
            }
        }
        // ---------- AFTER confirmation ----------
        else if (!can_finish) {
            // Drive pop animation and fade out other cards
            pop_progress = min(pop_progress + 0.08, 1);

            for (var i = 0; i < total; i++) {
                var c = cards[i];
                if (i == selected) {
                    // Winner moves toward center and grows
                    c.x = lerp(c.x, x, 0.18);
                    c.y = lerp(c.y, y - 20, 0.18);
                    c.scale = lerp(c.scale, pop_scale, 0.18);
                    c.alpha = 1;
                } else {
                    // Others shrink/fade out of attention
                    c.scale = lerp(c.scale, 0.25, 0.12);
                    c.alpha = lerp(c.alpha, 0, 0.12);
                }
                cards[i] = c;
            }

            // When pop completes, allow dismissal
            if (pop_progress >= 0.99) {
                can_finish = true;
                // Force non‑selected invisible to avoid flicker on finish
                for (var i = 0; i < total; i++) {
                    if (i != selected) {
                        cards[i].alpha = 0;
                        cards[i].scale = 0.25;
                    }
                }
            }
        }

        // ---------- WAIT FOR ANY KEY / CLICK ----------
        // One final input after the pop closes the popup (caller should clear
        // global pointer or keep reference and check `finished`).
        if (can_finish) {
            if (keyboard_check_pressed(vk_anykey) || mouse_check_button_pressed(mb_left)) {
                finished = true;
                if (variable_global_exists("selection_popup")) global.selection_popup = undefined;
            }
        }

        // ---------- IDLE hover scaling ----------
        // Smoothly interpolate toward highlight scale for hovered/selected card
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
    /// Renders modal overlay, card sprites with names, selection border, and a
    /// description block under the row. Uses GUI coordinates.
    draw = function() {
        if (finished) return;

        // Screen‑dim overlay for modal focus
        draw_set_alpha(0.8 * alpha);
        draw_set_color(c_black);
        draw_rectangle(0, 0, window_get_width(), window_get_height(), false);
        draw_set_alpha(1);

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        // Cards
        for (var i = 0; i < total; i++) {
            var c = cards[i];
            var opt = options[i];
            var draw_alpha = alpha * c.alpha;
            draw_sprite_ext(opt.sprite, 0, c.x, c.y, c.scale, c.scale, 0, c_white, draw_alpha);

            // Label under the card (if visible)
            if (c.alpha > 0.05) {
                draw_set_alpha(draw_alpha);
                draw_set_color(c_white);
                draw_set_font(fnt_default);
                draw_text(c.x, c.y + (card_h * c.scale)/2 + 18, opt.name);
                draw_set_alpha(1);
            }

            // Subtle selection/hover border pre‑confirm
            if (!confirmed && (i == selected || i == hover)) {
                draw_set_alpha(alpha * 0.35);
                draw_rectangle(c.x - (card_w*c.scale)/2, c.y - (card_h*c.scale)/2, c.x + (card_w*c.scale)/2, c.y + (card_h*c.scale)/2, false);
                draw_set_alpha(1);
            }
        }

        // Context description (hover priority, else selected; after confirm, chosen)
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