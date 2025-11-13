
if (obj_main_controller.menu_system.state == MENU_STATE.PAUSE_MENU) exit;
// Draw level-up popup
if (variable_global_exists("selection_popup") && global.selection_popup != noone) {
    global.selection_popup.draw();
}

// Draw chest popup
if (variable_global_exists("chest_popup") && global.chest_popup != noone) {
    global.chest_popup.draw();
}

// Draw weapon swap prompt
DrawWeaponSwapPrompt();

// Debug info (remove for final demo)
if (keyboard_check(vk_f1)) {
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    
    var debug_y = 20;
    draw_text(20, debug_y, "=== DEBUG INFO ===");
    debug_y += 20;
    
    draw_text(20, debug_y, "Score: " + string(score_manager.GetScore()));
    debug_y += 15;
    
    draw_text(20, debug_y, "Combo: x" + string_format(score_manager.GetComboMultiplier(), 1, 2));
    debug_y += 15;
    
    draw_text(20, debug_y, "Time: " + time_manager.GetFormattedTime(true));
    debug_y += 15;
    
    
    var stats = score_manager.GetStyleStats();
    draw_text(20, debug_y, "Perfect Kills: " + string(stats.perfect_timing_kills));
    debug_y += 15;
    
    draw_text(20, debug_y, "Chain Kills: " + string(stats.chain_kills));
}

/// @description
ui.draw();
score_display.Draw();

// DEBUG: Check pause state
if (keyboard_check(vk_f10)) {
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(10, 10, 400, 150, false);
    draw_set_alpha(1);
    draw_set_color(c_lime);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    draw_text(20, 20, "=== PAUSE DEBUG ===");
    draw_text(20, 40, "IsPaused: " + string(pause_manager.IsPaused()));
    draw_text(20, 60, "global.gameSpeed: " + string(global.gameSpeed));
    draw_text(20, 80, "Pause Stack Length: " + string(array_length(pause_manager.pause_stack)));
    draw_text(20, 100, "Current Speed: " + string(pause_manager.current_speed));
    draw_text(20, 120, "Target Speed: " + string(pause_manager.target_speed));
}