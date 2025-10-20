/// @desc Main Controller - Step Event

UpdateMusic();

// Death sequence
if (death_sequence_active) {
    UpdateDeathSequence();
    exit;
}

// MAIN MENU (rm_main_menu only)
if (room == rm_main_menu) {
    logo_scale = lerp(logo_scale, 1, 0.1);
    logo_bounce = sin(current_time * 0.003) * 5;
    menu_alpha = min(menu_alpha + 0.02, 1);
    
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    
    switch(menu_state) {
        case MENU_STATE.MAIN:
            HandleMainMenu(mx, my);
            break;
        case MENU_STATE.CHARACTER_SELECT:
            HandleCharacterSelect(mx, my);
            break;
        case MENU_STATE.SETTINGS:
            HandleSettings(mx, my);
            break;
    }
    exit;
}

// PAUSE MENU (rm_demo_room only) - ONLY if in pause menu state
if (room == rm_demo_room && menu_state == MENU_STATE.PAUSE_MENU) {
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    HandlePauseMenu(mx, my);
}

// ESC to toggle pause (rm_demo_room only)
if (room == rm_demo_room && keyboard_check_pressed(vk_escape) && !death_sequence_active) {
    if (menu_state == MENU_STATE.PAUSE_MENU) {
        ResumeGame();
    } else {
        PauseGame();
    }
}