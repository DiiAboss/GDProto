// Draw level-up popup
if (variable_global_exists("selection_popup") && global.selection_popup != undefined) {
    global.selection_popup.draw();
}

// Draw chest popup
if (variable_global_exists("chest_popup") && global.chest_popup != undefined) {
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
    
    draw_text(20, debug_y, "Room: " + string(current_room_type));
    debug_y += 15;
    
    var stats = score_manager.GetStyleStats();
    draw_text(20, debug_y, "Perfect Kills: " + string(stats.perfect_timing_kills));
    debug_y += 15;
    
    draw_text(20, debug_y, "Chain Kills: " + string(stats.chain_kills));
}

/// @description
ui.draw();