/// @function draw_player_hp_bar(player_x, player_y, current_hp, max_hp, [show_always])
/// @description Draws a mini HP bar above the player
function draw_player_hp_bar(_x, _y, _current_hp, _max_hp, _show_always = false) {
    // Only show if damaged or forced to show
    if (_current_hp >= _max_hp && !_show_always) return;
    
    // Bar dimensions
    var bar_width = 32;
    var bar_height = 3;
    var bar_offset_y = 20; // Above player
    
    // Position
    var bar_x = _x - bar_width / 2;
    var bar_y = _y + bar_offset_y;
    
    // Calculate fill percentage
    var hp_percent = clamp(_current_hp / _max_hp, 0, 1);
    var fill_width = bar_width * hp_percent;
    
    // Background (red)
    draw_set_color(c_red);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);
    
    // Foreground (green)
    draw_set_color(c_lime);
    draw_rectangle(bar_x, bar_y, bar_x + fill_width, bar_y + bar_height, false);
    
    // Border (black outline)
    draw_set_color(c_black);
    draw_rectangle(bar_x - 1, bar_y - 1, bar_x + bar_width + 1, bar_y + bar_height + 1, true);
    
    draw_set_color(c_white);
}