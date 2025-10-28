/// @desc Game Manager Step
pause_manager.Update();


score_manager.Update(game_speed_delta());
time_manager.Update(game_speed_delta());

score_display.Update(game_speed_delta());


//if (global.gameSpeed <= 0) exit;

if (global.gameSpeed > 0)
{
	if (instance_exists(obj_exp))
{
    with (obj_exp)
    {
    	if (settled)
    	{
    		var _dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);
    		if (_dist_to_player <= 128)
    		{
    			direction = point_direction(x, y, obj_player.x, obj_player.y);
    			speed += 0.1 * game_speed_delta();
    			
    			if (_dist_to_player <= 4)
    			{
    				obj_player.experience_points += obj_exp.amount;
    				instance_destroy();
    			}
    		}
    		else
    		{
    			speed = 0;
    		}
    	}
    }
}

if (instance_exists(obj_coin))
{
    with (obj_coin)
    {
        if (settled)
        {
            var _dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);
            if (_dist_to_player <= 128)
            {
                direction = point_direction(x, y, obj_player.x, obj_player.y);
                speed += 0.1 * game_speed_delta();
                
                if (_dist_to_player <= 4)
                {
                    instance_destroy();
					obj_player.gold += 1;
                }
            }
            else
            {
                speed = 0;
            }
        }
    }
}
}

// Update weapon swap prompt
UpdateWeaponSwapPrompt();


	// ==========================================
// LEVEL UP POPUP (P key for testing)
// ==========================================
if (keyboard_check_pressed(ord("P"))) {
    if (!variable_global_exists("selection_popup") || global.selection_popup == noone) {
        ShowLevelUpPopup();
    }
	
	show_debug_message("Step Event Loaded");
}

// ==========================================
// UPDATE SELECTION POPUP (Level-ups)
// ==========================================
if (variable_global_exists("selection_popup") && global.selection_popup != noone) {
    var popup = global.selection_popup;
    popup.step();

    if (popup.finished) {
        global.selection_popup = noone;
    }
}

// ==========================================
// UPDATE CHEST POPUP
// ==========================================
if (variable_global_exists("chest_popup") && global.chest_popup != noone) {
    var chest_popup = global.chest_popup;
    chest_popup.step();
    
    if (chest_popup.finished) {
        global.chest_popup = noone;
    }
}
	





