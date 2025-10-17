/// @description Enemy Fly Step
// Note: only keep event_inherited() if you really need parent HP/states —
// if the parent moves the enemy, REMOVE it or it’ll override this movement.
event_inherited();

if (marked_for_death) exit;

// Safety: ensure progress exists
if (!variable_instance_exists(id, "jumpProgress")) jumpProgress = 1;

// Main behavior
switch (state) {

    // --------------------------------------------------
    case ENEMY_STATE.IDLE:
        moveSpeed = 0;
        jumpTimer -= game_speed_delta();

        if (jumpTimer <= 0) {
            // Pick a new jump target
            var _range = jumpDistance; // use your variable
                var dir = point_direction(x, y, obj_player.x, obj_player.y);
			    var _target_x = x + lengthdir_x(jumpDistance, dir);
			    var _target_y = y + lengthdir_y(jumpDistance, dir);

            jumpStartX = x;
            jumpStartY = y;
            jumpTargetX = _target_x;
            jumpTargetY = _target_y;

            jumpProgress = 0;
            canBeHit = false;
            state = ENEMY_STATE.JUMPING;
        }
    break;


    // --------------------------------------------------
    case ENEMY_STATE.JUMPING:
        // Convert pixel speed → progress amount
        var total_dist = point_distance(jumpStartX, jumpStartY, jumpTargetX, jumpTargetY);
        if (total_dist == 0) total_dist = 1; // prevent div by 0
        // We move this many pixels per frame, so convert to 0–1 progress
        jumpProgress += (jumpSpeed / total_dist) *  game_speed_delta();

        if (jumpProgress >= 1) {
            jumpProgress = 1;
            x = jumpTargetX;
            y = jumpTargetY;
            state = ENEMY_STATE.IDLE;
            canBeHit = true;
            jumpTimer = jumpCooldown; // pause before next jump
        }
        else {
            // Interpolate position
            var _tx = lerp(jumpStartX, jumpTargetX, jumpProgress);
            var _ty = lerp(jumpStartY, jumpTargetY, jumpProgress);

            // Apply parabolic height
            var t = jumpProgress;
            var arc = -4 * jumpHeight * (t - 0.5) * (t - 0.5) + jumpHeight;

            // Update visual position
            x = _tx;
            y = _ty - arc;
        }
    break;
}

if (state == ENEMY_STATE.JUMPING) {
    // Stretch horizontally a bit less, compress vertically a bit less mid-air
    var _arc = -4 * jumpHeight * (jumpProgress - 0.5) * (jumpProgress - 0.5) + jumpHeight;
xScaleTarget = 1 - squashAmount * (_arc / jumpHeight) * 0.3;
yScaleTarget = 1 + squashAmount * (_arc / jumpHeight) * 0.5;
}
// On landing
else if (state == ENEMY_STATE.IDLE && jumpProgress == 1) {
    // Squash a little when landing
    xScaleTarget = 1 + squashAmount;
    yScaleTarget = 1 - squashAmount;
}
// Idle, normalize slowly
else {
    xScaleTarget = 1;
    yScaleTarget = 1;
}

image_xscale = lerp(image_xscale, xScaleTarget, squashSpeed);
image_yscale = lerp(image_yscale, yScaleTarget, squashSpeed);

depth = -y;