/// @desc Main Controller - Draw GUI Event

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var cx = gui_w / 2;
var cy = gui_h / 2;

// ==========================================
// DEBUG: Show game speed (F12 to toggle)
// ==========================================
if (keyboard_check(vk_f12)) {
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(10, 10, 350, 160, false);
    draw_set_alpha(1);
    draw_set_color(c_lime);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    draw_text(20, 20, "PAUSE DEBUG:");
    if (instance_exists(obj_game_manager)) {
        draw_text(20, 40, "global.gameSpeed: " + string(global.gameSpeed));
        draw_text(20, 60, "IsPaused: " + string(obj_game_manager.pause_manager.IsPaused()));
    }
    draw_text(20, 80, "Menu State: " + string(menu_state));
    draw_text(20, 100, "Room: " + room_get_name(room));
    draw_text(20, 120, "Death Sequence: " + string(death_sequence_active));
    draw_text(20, 140, "Death Phase: " + string(death_phase));
}

// ==========================================
// DEATH SEQUENCE OVERLAY
// ==========================================
if (death_sequence_active && room == rm_demo_room) {
    DrawDeathSequence(gui_w, gui_h, cx, cy);
    exit;
}

// ==========================================
// PAUSE MENU (only in gameplay room)
// ==========================================
if (menu_state == MENU_STATE.PAUSE_MENU && room == rm_demo_room) {
    DrawPauseMenu(gui_w, gui_h, cx, cy);
    exit;
}

// ==========================================
// MAIN MENU (only in menu room)
// ==========================================
if (room == rm_main_menu) {
	// Draw highscores table on the side
    
    switch(menu_state) {
        case MENU_STATE.MAIN:
            DrawMainMenu(gui_w, gui_h, cx, cy);
            break;
        case MENU_STATE.CHARACTER_SELECT:
            DrawCharacterSelect(gui_w, gui_h, cx, cy);
            break;
        case MENU_STATE.SETTINGS:
            DrawSettings(gui_w, gui_h, cx, cy);
            break;
    }
	
	draw_set_font(fnt_default);
	DrawHighscores(gui_w, gui_h);
}

// Reset
draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);