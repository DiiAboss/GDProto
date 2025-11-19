/// @description Insert description here
// You can write your code in this editor
banner_text = "ARENA";
subtitle_text = "Survive 10 Waves";
banner_type = "ARENA"; // or "CHALLENGE" or "BOSS"

// Animation
phase = 0; // 0=slide in, 1=display, 2=slide out
phase_timer = 0;
display_duration = 120; // 2 seconds

// Triangle positions
left_triangle_x = 0;
right_triangle_x = display_get_gui_width();
target_left_x = display_get_gui_width() * 0.2;
target_right_x = display_get_gui_width() * 0.8;

// Text
text_alpha = 0;
char_index = 0;
typewriter_speed = 2; // chars per frame

// Camera slowdown
original_target_speed = obj_game_manager.pause_manager.target_speed;
slowdown_applied = false;
