/// @desc Draw GUI
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var cx = gui_w / 2;
var cy = gui_h / 2;

// Death sequence overlay
if (death_sequence.active && room == rm_demo_room) {
    death_sequence.Draw(gui_w, gui_h, cx, cy, highscore_system);
    exit;
}

// Pause menu
if (menu_system.state == MENU_STATE.PAUSE_MENU && room == rm_demo_room) {
    menu_system.Draw(gui_w, gui_h, cx, cy);
    exit;
}

// Main menu
if (room == rm_main_menu) {
    menu_system.Draw(gui_w, gui_h, cx, cy);
    //draw_set_font(fnt_default);
    //highscore_system.DrawHighscores(gui_w, gui_h);
}

else
{
	// Draw textbox last (on top of everything)
if (textbox_system.active) {
    textbox_system.Draw(player_input, gui_w, gui_h);
}
var souls = GetSouls();
draw_set_halign(fa_right);
draw_set_valign(fa_top);
draw_set_font(fnt_small_1);
draw_set_color(c_aqua);
draw_text(20, 20, "Souls: " + string(souls));
draw_set_color(c_white);
}

