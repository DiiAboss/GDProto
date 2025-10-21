/// @description
/// @desc Death Sequence - Draw GUI Event

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var center_x = gui_w / 2;
var center_y = gui_h / 2;

// Phase 1+: Draw black fade over everything
if (fade_alpha > 0) {
   drawAlphaRectangle(0, 0, gui_w, gui_h, fade_alpha);
}



//var char_draw_alpha = 1-fade_alpha;
	draw_sprite_ext(spr_vh_dead, 0, center_x, center_y, 3, 3, 0, c_white, fade_alpha);

// Phase 2+: Draw stats
if (show_stats && stats_alpha > 0) {
    draw_set_alpha(stats_alpha);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    
    // Title
    draw_set_font(fnt_large);
    draw_text(center_x, center_y - 120, "GAME OVER");
    
    draw_set_font(fnt_default);
    
    // Score
    var score_text = "FINAL SCORE: " + string(final_score);
    draw_text(center_x, center_y - 40, score_text);
    
    // Time
    var time_text = "TIME SURVIVED: " + final_time;
    draw_text(center_x, center_y, time_text);
    
    // Thank you message
    draw_set_color(c_yellow);
    draw_text(center_x, center_y + 60, "Thanks for playing the");
    draw_set_font(fnt_large);
    draw_text(center_x, center_y + 90, "TARLHS GAME DEMO");
    
    draw_set_alpha(1);
}

// Phase 3: Show return prompt
if (can_go_to_menu && menu_wait_timer > 60) {
    // Pulse effect
    var pulse = 0.5 + sin(current_time * 0.005) * 0.5;
    draw_set_alpha(pulse);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_set_font(fnt_default);
    
    draw_text(center_x, gui_h - 80, "Press ENTER or SPACE to return to Main Menu");
    
    draw_set_alpha(1);
}

// Reset draw settings
draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);