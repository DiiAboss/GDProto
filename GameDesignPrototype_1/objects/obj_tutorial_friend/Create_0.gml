/// @description obj_tutorial_friend - Create Event

sprite_index = spr_BBallPlayer_South;
image_speed = 0;

// Pitching
is_pitching = false;
pitch_timer = 0;
pitch_cooldown = 100;
pitch_speed = 3;

// Create interaction prompt
var action = CreateCustomAction(function(_player, _npc) {
    // Does nothing - controlled by tutorial_controller
});
context_prompt = CreateContextPrompt(self, action, "", 64);
context_prompt.visible = false;

/// @function StartPitching()
StartPitching = function() {
    is_pitching = true;
    pitch_timer = 90;
    obj_main_controller.textbox_system.Show("FRIEND", "Now let's see you DEFLECT!");
}

/// @function PitchBall()
PitchBall = function() {
    if (!instance_exists(obj_player)) return;
    
    var player = obj_player;
    var lead = 30;
    var tx = player.x + (variable_instance_exists(player, "moveX") ? player.moveX * lead : 0);
    var ty = player.y + (variable_instance_exists(player, "moveY") ? player.moveY * lead : 0);
    
    var dir = point_direction(x, y, tx, ty);
    
    var ball = instance_create_depth(x, y - 16, depth - 1, obj_enemy_attack_orb);
    ball.direction = dir;
    ball.speed = pitch_speed;
    ball.from_tutorial = true;
    ball.life = 600;
    
    pitch_timer = pitch_cooldown;
    
    if (instance_exists(obj_tutorial_controller)) {
        obj_tutorial_controller.deflect_attempts++;
    }
    
    // Occasional floating text
    if (random(1) < 0.5) {
        var msg = choose("Here!", "Heads up!", "Catch!", "Batter up!");
        spawn_damage_number(x, y - 32, msg, c_white, false);
    }
}

/// @function OnBallCaught(_ball)
OnBallCaught = function(_ball) {
    if (!instance_exists(obj_tutorial_controller)) return;
    var ctrl = obj_tutorial_controller;
    var textbox = obj_main_controller.textbox_system;
    
    if (ctrl.phase == TUTORIAL_PHASE.THROW_BALL || ctrl.phase == TUTORIAL_PHASE.THROW_RETRY) {
        textbox.Show("FRIEND", "Nice throw!");
        ctrl.phase = TUTORIAL_PHASE.PICKUP_BAT;
        
        // Give instruction after delay
        ctrl.alarm[2] = 60;
    }
    else if (ctrl.phase == TUTORIAL_PHASE.BAT_BALL) {
        textbox.Show("FRIEND", "Whoa, nice swing!");
        ctrl.phase = TUTORIAL_PHASE.DEFLECT_PRACTICE;
        StartPitching();
    }
    
    if (instance_exists(_ball)) instance_destroy(_ball);
}
