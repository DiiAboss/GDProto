/// @desc Step Event
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

if !(instance_exists(input_caller))
{
	input_caller = self;
}

player_input.Update(input_caller);
_audio_system.Update();

// Death sequence
if (death_sequence.active) {
    death_sequence.Update(player_input); // Pass input!
    exit;
}

// Main menu
if (room == rm_main_menu) {
    menu_system.Update(player_input, _audio_system, mx, my);
    if (keyboard_check_pressed(vk_f12))
	{
		UnlockCharacter(CharacterClass.VAMPIRE);
		UnlockCharacter(CharacterClass.HOLY_MAGE);
	}
	
	exit;
	
	

}
else
{
	// Pause menu
	if (menu_system.state == MENU_STATE.PAUSE_MENU) {
	    menu_system.Update(player_input, _audio_system, mx, my);
		exit;
	}
	
	// ESC to toggle pause
	if (player_input.Escape && !death_sequence.active) {
	    if (menu_system.state == MENU_STATE.PAUSE_MENU) {
	        menu_system.ResumeGame(_audio_system, obj_game_manager.pause_manager);
	    } else {
	        menu_system.PauseGame(_audio_system, obj_game_manager.pause_manager);
	    }
	}
	// Handle textbox (check AFTER pause menu, but allow during dialogue pause)
	if (textbox_system.active) {
	    textbox_system.Update(player_input);
	    exit; // Don't process other game logic while textbox is active
	}
	
}





// DEBUG: Save system testing
if (keyboard_check_pressed(vk_f11)) {
    show_debug_message("=== CURRENT SAVE DATA ===");
    show_debug_message("Total Runs: " + string(global.SaveData.career.total_runs));
    show_debug_message("Total Kills: " + string(global.SaveData.career.total_kills));
    show_debug_message("Best Score: " + string(global.SaveData.career.best_score));
    show_debug_message("Unlocked Characters: " + json_stringify(global.SaveData.unlocks.characters));
}

if (keyboard_check_pressed(vk_f9)) {
    show_debug_message("Manually saving game...");
    SaveGame();
}