/// @description
/// obj_menu_controller - Step Event
// Animate logo
logo_scale = lerp(logo_scale, 1, 0.1);
logo_bounce = sin(current_time * 0.003) * 5;
menu_alpha = min(menu_alpha + 0.02, 1);

switch(menu_state) {
    case MENU_STATE.MAIN:
        // Keyboard navigation
        if (keyboard_check_pressed(vk_up)) {
            selected_option = (selected_option - 1 + array_length(menu_options)) mod array_length(menu_options);
        }
        if (keyboard_check_pressed(vk_down)) {
            selected_option = (selected_option + 1) mod array_length(menu_options);
        }
        
        // Selection
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
            switch(selected_option) {
                case 0: // START
                    menu_state = MENU_STATE.CHARACTER_SELECT;
                    selected_class = 0;
                    break;
                case 1: // SETTINGS
                    menu_state = MENU_STATE.SETTINGS;
                    selected_option = 0;
                    break;
                case 2: // EXIT
                    game_end();
                    break;
            }
        }
        break;
        
    case MENU_STATE.CHARACTER_SELECT:
        if (keyboard_check_pressed(vk_left)) {
            selected_class = (selected_class - 1 + array_length(class_options)) mod array_length(class_options);
        }
        if (keyboard_check_pressed(vk_right)) {
            selected_class = (selected_class + 1) mod array_length(class_options);
        }
        
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
            global.selected_class = class_options[selected_class].type;
            room_goto(DemoRoom);
        }
        
        if (keyboard_check_pressed(vk_escape)) {
            menu_state = MENU_STATE.MAIN;
        }
        break;
        
    case MENU_STATE.SETTINGS:
        if (keyboard_check_pressed(vk_escape) || 
            (selected_option == 3 && keyboard_check_pressed(vk_enter))) {
            menu_state = MENU_STATE.MAIN;
            selected_option = 0;
        }
        break;
}