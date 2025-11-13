/// @description

// DRAW EVENT


draw_set_alpha(alpha);
draw_set_color(color);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_default);

draw_text_transformed(x, y - y_offset, text, scale, scale, 0);

// Reset draw settings
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);