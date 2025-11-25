
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



if !(obj_main_controller.textbox_system.active)
{
	ui.draw();
	score_display.Draw();

}

// COMBO DISPLAY
if (instance_exists(obj_player) && obj_player.combo_count > 0 && obj_player.combo_display_timer > 0) {
    var combo = obj_player.combo_count;
    var timer = obj_player.combo_display_timer;
    
    // Fade out in last 30 frames
    var alpha = timer > 30 ? 1 : timer / 30;
    
    // Position (top center of screen)
    var cx = display_get_gui_width() / 2;
    var cy = 80;
    
    // Scale pulse effect
    var pulse = 1 + sin(current_time * 0.01) * 0.05;
    var scale = pulse;
    
    // Color based on combo size
    var col = c_white;
    if (combo >= 50) col = c_yellow;
    else if (combo >= 25) col = c_orange;
    else if (combo >= 10) col = c_lime;
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(fnt_large);
    draw_set_alpha(alpha);
    draw_set_color(col);
    
    draw_text_transformed(cx, cy, string(combo) + " HIT COMBO", scale, scale, 0);
    
    // Bonus damage indicator
    var bonus = min(combo * 2, 100);
    draw_set_font(fnt_default);
    draw_set_color(c_ltgray);
    draw_text(cx, cy + 30, "+" + string(bonus) + "% Damage");
    
    draw_set_alpha(1);
}

// Decrement combo display timer
if (instance_exists(obj_player)) {
    if (obj_player.combo_display_timer > 0) {
        obj_player.combo_display_timer--;
    }
}
