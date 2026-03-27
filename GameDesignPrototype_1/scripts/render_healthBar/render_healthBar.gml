/// @function draw_player_hp_bar(player_x, player_y, current_hp, max_hp, [show_always])
/// -----------------------------------------------------------------------------
/// Renders a small health bar above a player (or any entity) showing current HP.
/// The bar hides automatically when at full HP unless explicitly forced.
/// -----------------------------------------------------------------------------
/// Parameters:
///   _x, _y          – World coordinates (player position).
///   _current_hp     – Current hit points.
///   _max_hp         – Maximum hit points.
///   _show_always    – Optional bool (default false) to force visibility.
/// -----------------------------------------------------------------------------
/// Notes:
///   Ideal for quick readability in crowded combat scenes.
///   Draws simple rectangles—no surfaces or sprites.
///   Uses GUI-safe colors: red background, lime fill, black outline.
/// -----------------------------------------------------------------------------
function draw_player_hp_bar(_x, _y, _current_hp, _max_hp, _show_always = false) {
    // Only show if damaged or forced to show
    if (_current_hp >= _max_hp && !_show_always) return;

    // --- Dimensions & placement ---
    var bar_width = 32;
    var bar_height = 3;
    var bar_offset_y = 20; // Above player

    var bar_x = _x - bar_width / 2;
    var bar_y = _y + bar_offset_y;

    // --- Fill computation ---
    var hp_percent = clamp(_current_hp / _max_hp, 0, 1);
    var fill_width = bar_width * hp_percent;

    // --- Draw passes ---
    // Background
    draw_set_color(c_red);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);

    // Foreground (fill)
    draw_set_color(c_lime);
    draw_rectangle(bar_x, bar_y, bar_x + fill_width, bar_y + bar_height, false);

    // Outline
    draw_set_color(c_black);
    draw_rectangle(bar_x - 1, bar_y - 1, bar_x + bar_width + 1, bar_y + bar_height + 1, true);

    draw_set_color(c_white);
}