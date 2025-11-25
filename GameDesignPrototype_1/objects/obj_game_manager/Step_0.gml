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
    			
	    			// Step event or collision with player
					if (place_meeting(x, y, obj_player)) {
					    GiveExperience(obj_player, obj_exp.amount);  // exp_value = how much this orb gives
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
                
	                if (place_meeting(x, y, obj_player)) {
					    GiveGold(obj_player, 1);  // gold_value = coin amount
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
}
else
{
	with (obj_coin)speed = 0;
	with (obj_exp)speed = 0;
}

// Update weapon swap prompt
UpdateWeaponSwapPrompt();


	
// LEVEL UP POPUP (P key for testing)

if (keyboard_check_pressed(ord("P"))) {
    if global.selection_popup == noone {
        ShowLevelUpPopup(can_click);
    }
	
	show_debug_message("Step Event Loaded");
}


// UPDATE SELECTION POPUP (Level-ups)

if global.selection_popup != noone {
	var popup = global.selection_popup;
    popup.step();

    if (popup.finished) {
        global.selection_popup = noone;
    }
}


// UPDATE CHEST POPUP

if global.chest_popup != noone {
	var chest_popup = global.chest_popup;
    chest_popup.step();
    
    if (chest_popup.finished) {
        global.chest_popup = noone;
    }
}
if (obj_main_controller.menu_system.state == MENU_STATE.PAUSE_MENU)
{
	alarm[0] = 10;
	can_click = false;
	exit;
}

// Level up slowdown effect
if (level_up_slowdown_active) {
    level_up_slowdown_timer++;
    
    // Gradual slowdown
    var progress = level_up_slowdown_timer / level_up_slowdown_duration;
    var target_speed = lerp(1.0, 0.1, progress);
    pause_manager.target_speed = target_speed;
    
    if (level_up_slowdown_timer >= level_up_slowdown_duration) {
        level_up_slowdown_active = false;
        level_up_slowdown_timer = 0;
        
        // Show the actual popup
        ShowLevelUpPopup(can_click);
    }
}





