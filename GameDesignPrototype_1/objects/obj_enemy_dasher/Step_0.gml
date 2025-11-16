/// @description obj_enemy_dasher Step Event
event_inherited();
if (marked_for_death) exit;

switch (state) {
    // --- Idle / telegraph ---
    case "idle":
        dashTimer -= game_speed_delta();
        if (dashTimer <= 0 && instance_exists(obj_player)) {
            
            // Lock target direction toward player
            var dir = point_direction(x, y, obj_player.x, obj_player.y);
            var original_target_x = x + lengthdir_x(dashDistance, dir);
            var original_target_y = y + lengthdir_y(dashDistance, dir);
            
            // CHECK FOR PITS - Find safe dash target
            var safe_dash = FindSafeDashDirection(x, y, original_target_x, original_target_y, dashDistance);
            
            if (safe_dash.safe) {
                // Safe target found
                dashTargetX = safe_dash.target_x;
                dashTargetY = safe_dash.target_y;
                indicatorDir = safe_dash.direction;
                
                // Show attack indicator
                showIndicator = true;
                state = "telegraph";
                dashTimer = 10;
            } else {
                // No safe dash - skip this attack
                dashTimer = irandom_range(15, 30); // Try again soon
                show_debug_message("Dasher: No safe dash direction found");
            }
        }
    break;
    
    // --- Telegraph / charge prep ---
    case "telegraph":
        dashTimer -= game_speed_delta();
        if (dashTimer <= 0) {
            showIndicator = false;
            state = "dashing";
            canBeHit = false;
        }
    break;
    
    // --- Dash ---
    case "dashing":
        var _dir = point_direction(x, y, dashTargetX, dashTargetY);
        var moveX = lengthdir_x(dashSpeed, _dir) * game_speed_delta();
        var moveY = lengthdir_y(dashSpeed, _dir) * game_speed_delta();
        
        // SAFETY CHECK: Stop if about to enter pit
        var next_x = x + moveX;
        var next_y = y + moveY;
        
        if (CheckPitAhead(x, y, _dir, dashSpeed * 2)) {
            // Pit ahead - abort dash
            state = "idle";
            dashTimer = irandom_range(30, dashCooldown);
            canBeHit = true;
            show_debug_message("Dasher: Emergency stop - pit detected");
        } else {
            // Safe to move
            x += moveX;
            y += moveY;
        }
        
        // Check if reached target
        if (point_distance(x, y, dashTargetX, dashTargetY) < dashSpeed) {
            x = dashTargetX;
            y = dashTargetY;
            state = "idle";
            dashTimer = irandom_range(30, dashCooldown);
            canBeHit = true;
        }
        
        // Collision with player
        var hit = instance_place(x, y, obj_player);
        if (hit != noone) {
            var kbDir = point_direction(x, y, hit.x, hit.y);
			hit.knockback.Apply(kbDir, dashSpeed * 2);
			hit.damage_sys.TakeDamage(10, self);
            //takeDamage(hit, 10, self);
        }
        
        // Enemy knockback
        with (obj_enemy) {
            if (id != other.id && point_distance(x, y, other.x, other.y) < sprite_width) {
                var kbDir = point_direction(other.x, other.y, x, y);
				knockback.Apply(kbDir, 6);
            }
        }
    break;
}