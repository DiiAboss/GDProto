/// @description Insert description here
// You can write your code in this editor
/// @desc Draw GUI Event
var cx = display_get_gui_width() / 2;
var cy = display_get_gui_height() / 2;

// Left triangle (from top-left)
draw_primitive_begin(pr_trianglelist);
draw_vertex_color(left_triangle_x, 0, c_black, 0.9);
draw_vertex_color(left_triangle_x + 300, cy - 50, c_black, 0.9);
draw_vertex_color(left_triangle_x, cy + 50, c_black, 0.9);
draw_primitive_end();

// Right triangle (from bottom-right)
var gh = display_get_gui_height();
draw_primitive_begin(pr_trianglelist);
draw_vertex_color(right_triangle_x, gh, c_black, 0.9);
draw_vertex_color(right_triangle_x - 300, cy + 50, c_black, 0.9);
draw_vertex_color(right_triangle_x, cy - 50, c_black, 0.9);
draw_primitive_end();

// Center bar
draw_set_alpha(0.8);
draw_set_color(c_black);
draw_rectangle(0, cy - 60, display_get_gui_width(), cy + 60, false);
draw_set_alpha(1);

// Text
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_large);

// Main title
var title_color = c_red;
if (banner_type == "CHALLENGE") title_color = c_orange;
if (banner_type == "BOSS") title_color = c_purple;

draw_set_color(title_color);
draw_text_transformed(cx, cy - 20, banner_text, 2, 2, 0);

// Subtitle (typewriter effect)
draw_set_font(fnt_default);
draw_set_color(c_white);
draw_set_alpha(text_alpha);
var display_text = string_copy(subtitle_text, 1, floor(char_index));
draw_text(cx, cy + 20, display_text);
draw_set_alpha(1);