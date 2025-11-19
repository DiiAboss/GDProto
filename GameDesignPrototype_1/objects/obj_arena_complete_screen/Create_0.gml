/// @description Insert description here
// You can write your code in this editor
/// @desc Create Event
fade_in = 0;
display_time = 180; // 3 seconds
timer = 0;

souls_earned = 100; // Passed from arena controller
arena_unlocked = true;

/// @desc Step Event
timer++;
fade_in = min(fade_in + 0.05, 1);

if (timer >= display_time || keyboard_check_pressed(vk_anykey)) {
    instance_destroy();
    obj_main_controller.ReturnToOverworld();
}