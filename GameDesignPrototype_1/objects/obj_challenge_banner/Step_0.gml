/// @description Insert description here
// You can write your code in this editor
/// @desc Step Event
var _delta = game_speed_delta();
phase_timer++;

switch(phase) {
    case 0: // Slide in
        if (!slowdown_applied) {
            obj_game_manager.pause_manager.target_speed = 0.2;
            slowdown_applied = true;
        }
        
        left_triangle_x = lerp(left_triangle_x, target_left_x, 0.15);
        right_triangle_x = lerp(right_triangle_x, target_right_x, 0.15);
        
        if (phase_timer > 30) {
            phase = 1;
            phase_timer = 0;
        }
        break;
        
    case 1: // Display + typewriter
        text_alpha = min(text_alpha + 0.05, 1);
        
        if (char_index < string_length(subtitle_text)) {
            char_index += typewriter_speed * _delta;
        }
        
        if (phase_timer > display_duration) {
            phase = 2;
            phase_timer = 0;
        }
        break;
        
    case 2: // Slide out
        left_triangle_x = lerp(left_triangle_x, -display_get_gui_width() * 0.3, 0.15);
        right_triangle_x = lerp(right_triangle_x, display_get_gui_width() * 1.3, 0.15);
        text_alpha = max(text_alpha - 0.1, 0);
        
        if (phase_timer > 30) {
            obj_game_manager.pause_manager.target_speed = original_target_speed;
            instance_destroy();
        }
        break;
}