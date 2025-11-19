/// @description Insert description here
// You can write your code in this editor
/// @desc Draw GUI
var cx = display_get_gui_width() / 2;

draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_font(fnt_large);
draw_set_color(c_yellow);
draw_text(cx, 20, "WAVE " + string(current_wave) + "/" + string(max_waves));

if (wave_break_timer > 0) {
    draw_set_font(fnt_default);
    draw_set_color(c_lime);
    draw_text(cx, 50, "Next wave in " + string(ceil(wave_break_timer / 60)));
}