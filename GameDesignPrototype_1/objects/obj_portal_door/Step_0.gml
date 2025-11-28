/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();

if (is_unlocked) door.open = true;

if (!instance_exists(obj_player)) exit;

var dist = point_distance(x, y, obj_player.x, obj_player.y);

if (dist < 48) {
    // Show prompt
    var prompt = is_unlocked ? unlock_text : locked_text;
    
    // Draw interaction hint (in Draw GUI event)
    if (is_unlocked) {  
        // Player can enter
        if (keyboard_check_pressed(ord("E")) || obj_player.input.Action) {
            EnterSubRoom();
        }
    }
}

