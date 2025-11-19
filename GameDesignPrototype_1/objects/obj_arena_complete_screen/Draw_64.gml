/// @description Insert description here
// You can write your code in this editor
/// @desc Draw GUI Event
var cx = display_get_gui_width() / 2;
var cy = display_get_gui_height() / 2;

// Dark overlay
draw_set_alpha(0.9 * fade_in);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Title
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_large);
draw_set_color(c_yellow);
draw_text(cx, cy - 60, "ARENA COMPLETE!");

// Rewards
draw_set_font(fnt_default);
draw_set_color(c_white);
draw_text(cx, cy, "Souls Earned: " + string(souls_earned));

if (arena_unlocked) {
    draw_set_color(c_lime);
    draw_text(cx, cy + 40, "Arena Unlocked for Quick Play!");
}

// Prompt
draw_set_color(c_gray);
draw_text(cx, cy + 100, "Press any key to return...");