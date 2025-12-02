/// @description obj_tutorial_friend - Step Event

// Pitching
if (is_pitching) {
    pitch_timer--;
    if (pitch_timer <= 0) PitchBall();
}

// Check for incoming balls
var ball = instance_place(x, y, obj_can_carry);
if (ball != noone && ball.is_projectile) {
    OnBallCaught(ball);
}

// Face player
if (instance_exists(obj_player)) {
    var dir = point_direction(x, y, obj_player.x, obj_player.y);
    if (dir > 315 || dir <= 45) sprite_index = spr_BBallPlayer_East;
    else if (dir > 45 && dir <= 135) sprite_index = spr_BBallPlayer_North;
    else if (dir > 135 && dir <= 225) sprite_index = spr_BBallPlayer_West;
    else sprite_index = spr_BBallPlayer_South;
}

depth = -y;