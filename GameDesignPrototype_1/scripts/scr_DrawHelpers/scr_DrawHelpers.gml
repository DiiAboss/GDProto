/// @function draw_reset()
function draw_reset() {
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);
}

/// @function draw_text_centered(_x, _y, _text, _font, _color, _alpha)
/// @desc Common centered text pattern
function draw_text_centered(_x, _y, _text, _font = fnt_default, _color = c_white, _alpha = 1) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(_font);
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    draw_text(_x, _y, _text);
    draw_reset();
}

/// @function draw_panel(_x1, _y1, _x2, _y2, _bg_color, _border_color, _alpha)
/// @desc Common panel drawing pattern (used in shops, menus, popups)
function draw_panel(_x1, _y1, _x2, _y2, _bg_color = c_dkgray, _border_color = c_white, _alpha = 0.9) {
    draw_set_alpha(_alpha);
    draw_set_color(_bg_color);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_alpha(1);
    draw_set_color(_border_color);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
}

/// @function draw_bar(_x, _y, _width, _height, _percent, _bg_color, _fill_color, _border)
/// @desc Health/mana bar drawing (used in boss, player, UI)
function draw_bar(_x, _y, _width, _height, _percent, _bg_color = c_red, _fill_color = c_lime, _border = true) {
    // Background
    draw_set_color(_bg_color);
    draw_rectangle(_x, _y, _x + _width, _y + _height, false);
    
    // Fill
    draw_set_color(_fill_color);
    draw_rectangle(_x, _y, _x + (_width * clamp(_percent, 0, 1)), _y + _height, false);
    
    // Border
    if (_border) {
        draw_set_color(c_white);
        draw_rectangle(_x, _y, _x + _width, _y + _height, true);
    }
}

/// @function draw_overlay(_alpha)
/// @desc Full screen dark overlay (used in menus, popups, death screen)
function draw_overlay(_alpha = 0.8) {
    draw_set_alpha(_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
}