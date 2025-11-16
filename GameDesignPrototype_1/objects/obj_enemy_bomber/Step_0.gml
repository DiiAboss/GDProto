/// @description

event_inherited();

if (marked_for_death) exit;
	
switch (state) {

    // --- Idle / telegraph ---
    case "idle":
        dashTimer -=  game_speed_delta();
        if (dashTimer <= 0 && instance_exists(obj_player)) {
            
            // Lock target direction toward player
            var dir = point_direction(x, y, obj_player.x, obj_player.y);
            dashTargetX = x + lengthdir_x(dashDistance, dir);
            dashTargetY = y + lengthdir_y(dashDistance, dir);

            // Show attack indicator
            showIndicator = true;
            indicatorDir = dir;

            state = "telegraph";
            dashTimer = 10; // show indicator for 10 frames
        }
    break;

    // --- Telegraph / charge prep ---
    case "telegraph":
        dashTimer -=  game_speed_delta();
        if (dashTimer <= 0) {
            showIndicator = false;
            state = "dashing";
            canBeHit = false; // maybe invulnerable mid-dash
        }
    break;

    // --- Dash ---
    case "dashing":
        var _dir = point_direction(x, y, dashTargetX, dashTargetY);
        var moveX = lengthdir_x(dashSpeed, _dir) * game_speed_delta();
        var moveY = lengthdir_y(dashSpeed, _dir) * game_speed_delta();

        // Move
        x += moveX;
        y += moveY;

        // Check if reached target (or overshot)
        if (point_distance(x, y, dashTargetX, dashTargetY) < dashSpeed) {
            x = dashTargetX;
            y = dashTargetY;
            state = "idle";
            dashTimer = irandom_range(30, dashCooldown);
            canBeHit = true;
        }

        // --- Collision with player or enemies ---
        var hit = instance_place(x, y, obj_player);
        if (hit != noone) {
            var kbDir = point_direction(x, y, hit.x, hit.y);
            hit.damage_sys.TakeDamage(10, self);
			hit.knockback.Apply(kbDir, dashSpeed * 2);
        }

        // Check for other enemies with knockback
        with (obj_enemy) {
            if (id != other.id && point_distance(x, y, other.x, other.y) < sprite_width) {
                var kbDir = point_direction(other.x, other.y, x, y);
				knockback.Apply(kbDir, 6);
            }
        }
    break;
}

if (can_attack && alarm[0] <= 0) {
    // Check if player is in range
    if (instance_exists(obj_player)) {
        var dist = point_distance(x, y, obj_player.x, obj_player.y);
        
        if (dist < 300 && dist > 100) { // Attack range
            // Create bomb
            var bomb = instance_create_depth(x, y, depth - 1, obj_bomb);
            
            // Arm it immediately
            bomb.ArmBomb(self);
            
            // Calculate lob trajectory
            var throw_dir = point_direction(x, y, obj_player.x, obj_player.y);
            var throw_dist = min(dist, 200);
            
            // Set up lob throw
            bomb.targetX = obj_player.x;
            bomb.targetY = obj_player.y;
            bomb.is_projectile = true;
            bomb.is_lob_shot = true;
            bomb.projectile_speed = 6;
            bomb.lob_direction = throw_dir;
            bomb.targetDistance = throw_dist;
            bomb.destroy_on_impact = false; // Don't destroy on landing
            
            // Arc physics
            bomb.xStart = bomb.x;
            bomb.yStart = bomb.y;
            bomb.lobHeight = 32;
            bomb.lobProgress = 0;
            bomb.lobStep = 0;
            
            // Movement
            var lob_speed = 5;
            bomb.moveX = lengthdir_x(lob_speed, throw_dir);
            bomb.moveY = lengthdir_y(lob_speed, throw_dir);
            
            // Set cooldown
            alarm[0] = bomb_timer; // 3 seconds between attacks
            
            show_debug_message("Enemy threw armed bomb!");
        }
    }
}