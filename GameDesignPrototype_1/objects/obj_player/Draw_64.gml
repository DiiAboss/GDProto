/// @description
// Camera Debug Display (top-left corner)
if (keyboard_check(vk_f12)) {
    draw_set_color(c_black);
    draw_set_alpha(0.7);
    draw_rectangle(10, 10, 320, 280, false);
    draw_set_alpha(1);
    
    draw_set_color(c_yellow);
    draw_set_font(fnt_default);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    var debug_y = 20;
    draw_text(20, debug_y, "CAMERA DEBUG (Hold F12)"); debug_y += 20;
    draw_set_color(c_white);
    draw_text(20, debug_y, "F1/F2: Shake"); debug_y += 18;
    draw_text(20, debug_y, "F3/F4/F5: Zoom"); debug_y += 18;
    draw_text(20, debug_y, "F6: Pan to Enemy"); debug_y += 18;
    draw_text(20, debug_y, "F7: Lock Center"); debug_y += 18;
    draw_text(20, debug_y, "F8: Unlock"); debug_y += 18;
    draw_text(20, debug_y, "F9: Toggle Bounds"); debug_y += 18;
    draw_text(20, debug_y, "F10: Follow Speed"); debug_y += 18;
    
    debug_y += 10;
    draw_set_color(c_lime);
    if (instance_exists(obj_player) && variable_instance_exists(obj_player, "camera")) {
        draw_text(20, debug_y, "Zoom: " + string(obj_player.camera.current_zoom)); debug_y += 18;
        draw_text(20, debug_y, "Follow: " + string(obj_player.camera.follow_speed)); debug_y += 18;
        draw_text(20, debug_y, "Locked: " + string(obj_player.camera.is_locked)); debug_y += 18;
        draw_text(20, debug_y, "Bounds: " + string(obj_player.camera.use_bounds));
    }
    
    draw_set_color(c_white);
}

