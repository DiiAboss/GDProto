/// @description obj_tutorial_controller - Step Event

if (dialogue_cooldown > 0) dialogue_cooldown--;

var textbox = obj_main_controller.textbox_system;
var player = instance_exists(obj_player) ? obj_player : noone;
if (!instance_exists(player)) exit;

switch (phase) {
    
    case TUTORIAL_PHASE.INTRO_TEXT:
        break;
        
    case TUTORIAL_PHASE.GO_TO_FRIEND:
        if (!textbox.active && instance_exists(friend_npc)) {
            indicator_target = friend_npc;
            indicator_visible = true;
            
            if (point_distance(player.x, player.y, friend_npc.x, friend_npc.y) < 80) {
                indicator_visible = false;
                phase = TUTORIAL_PHASE.THROW_BALL;
                
                textbox.QueueMessage("FRIEND", "There you are!");
                textbox.QueueMessage("FRIEND", "Grab that ball and toss it to me!");
                textbox.QueueMessage("FRIEND", "[E] to pick up, [LMB] to throw!");
                textbox.ShowNextInQueue();
                
                // Point at nearest ball
                var ball = instance_nearest(player.x, player.y, obj_baseball_ground);
                if (instance_exists(ball)) indicator_target = ball;
            }
        }
        break;
        
    case TUTORIAL_PHASE.THROW_BALL:
    case TUTORIAL_PHASE.THROW_RETRY:
        if (!textbox.active) {
            var ball = instance_nearest(player.x, player.y, obj_baseball_ground);
            if (instance_exists(ball) && !ball.is_being_carried) {
                indicator_target = ball;
                indicator_visible = true;
            } else {
                indicator_visible = false;
            }
        }
        break;
        
    case TUTORIAL_PHASE.PICKUP_BAT:
        if (!textbox.active) {
            var bat = instance_find(obj_baseball_bat_pickup, 0);
            if (instance_exists(bat)) {
                indicator_target = bat;
                indicator_visible = true;
            }
            
            // Check if player has bat equipped
            if (instance_exists(player.melee_weapon)) {
                if (player.melee_weapon.object_index == obj_baseball_bat) {
                    indicator_visible = false;
                    phase = TUTORIAL_PHASE.BAT_BALL;
                    
                    // Spawn ball if needed
                    if (!instance_exists(obj_baseball_ground)) {
                        instance_create_layer(player.x + 40, player.y, "Instances", obj_baseball_ground);
                    }
                    
                    textbox.QueueMessage("FRIEND", "Nice! Now pick up a ball...");
                    textbox.QueueMessage("FRIEND", "And SWING it toward me!");
                    textbox.ShowNextInQueue();
                }
            }
        }
        break;
        
    case TUTORIAL_PHASE.BAT_BALL:
        if (!textbox.active) {
            var ball = instance_nearest(player.x, player.y, obj_baseball_ground);
            if (instance_exists(ball)) {
                indicator_target = ball;
                indicator_visible = true;
            }
        }
        break;
        
    case TUTORIAL_PHASE.DEFLECT_PRACTICE:
        indicator_visible = false;
        
        if (!textbox.active && instance_exists(friend_npc)) {
            // Check wandering
            var dist = point_distance(player.x, player.y, friend_npc.x, friend_npc.y);
            if (dist > 200) {
                wander_timer++;
                if (wander_timer > 180 && dialogue_cooldown <= 0) {
                    var tease = choose(
                        "Was that close?! I can't tell, you're so far away!!",
                        "Maybe practice REAL baseball instead of running around!",
                        "Get back here!"
                    );
                    textbox.Show("FRIEND", tease);
                    dialogue_cooldown = 180;
                    wander_timer = 0;
                }
            } else {
                wander_timer = 0;
            }
            
            // Check completion
            if (deflection_success || deflect_attempts >= 5) {
                phase = TUTORIAL_PHASE.COMPLETE;
                if (deflection_success) {
                    textbox.Show("FRIEND", "PERFECT! You're ready!");
                } else {
                    textbox.Show("FRIEND", "Good effort! Let's go!");
                }
            }
        }
        break;
        
    case TUTORIAL_PHASE.COMPLETE:
        if (!textbox.active) {
            flash_alpha += 0.02;
            if (flash_alpha >= 1) {
                obj_main_controller._audio_system.StopAll();
                room_goto(transition_room);
            }
        }
        break;
}