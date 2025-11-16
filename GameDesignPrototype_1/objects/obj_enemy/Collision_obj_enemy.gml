// ENEMY-TO-ENEMY COLLISION (in collision event or step)
if (is_falling) {
    exit;
}

// KNOCKBACK TRANSFER: When this enemy is being knocked back
if (knockback.IsActive()) {
    var transferDir = point_direction(x, y, other.x, other.y);
    var transferForce = knockback.GetSpeed() * 0.75;
    
    if (transferForce > 0.5 && other.knockback.cooldown <= 0) {
        var kbX = lengthdir_x(transferForce, transferDir);
        var kbY = lengthdir_y(transferForce, transferDir);
        
        // Check if the knockback would push enemy into wall
        var testX = other.x + kbX;
        var testY = other.y + kbY;
        
        // Smart knockback application with wall detection
        if (!place_meeting(testX, testY, obj_wall)) {
            // No wall collision, apply full knockback
            other.knockback.Apply(transferDir, transferForce);
        } else {
            // Will hit wall, check each axis separately
            var finalKbX = 0;
            var finalKbY = 0;
            
            // Try horizontal knockback
            if (!place_meeting(testX, other.y, obj_wall)) {
                finalKbX = kbX;
            } else {
                // Hit horizontal wall - apply bounce force instead
                finalKbX = -kbX * knockback.bounce_dampening;
            }
            
            // Try vertical knockback
            if (!place_meeting(other.x, testY, obj_wall)) {
                finalKbY = kbY;
            } else {
                // Hit vertical wall - apply bounce force instead
                finalKbY = -kbY * knockback.bounce_dampening;
            }
            
            // Apply the calculated forces
            other.knockback.AddForce(finalKbX, finalKbY, true); // true = replace existing
        }
        
        // Only apply cooldown if we actually transferred knockback
        if (other.knockback.IsActive()) {
            other.knockback.cooldown = 5;
            knockback.has_transferred = true;
            AwardArcadeScore("Dominoes");
            
            // Reduce our knockback by 20%
            knockback.x_velocity *= 0.8;
            knockback.y_velocity *= 0.8;
        }
    }
}
// NORMAL SEPARATION: Regular pushing when enemies overlap
else if (!knockback.IsActive() && !other.knockback.IsActive()) {
    var pushDir = point_direction(other.x, other.y, x, y);
    var pushForce = 0.5;
    
    var pushX = lengthdir_x(pushForce, pushDir);
    var pushY = lengthdir_y(pushForce, pushDir);
    
    // Check walls before pushing THIS enemy
    if (!place_meeting(x + pushX, y + pushY, obj_wall)) {
        // No collision, apply full push
        x += pushX;
        y += pushY;
    } else {
        // Check each axis separately for sliding
        if (!place_meeting(x + pushX, y, obj_wall)) {
            x += pushX; // Slide horizontally
        }
        if (!place_meeting(x, y + pushY, obj_wall)) {
            y += pushY; // Slide vertically
        }
    }
    
    // Also push the OTHER enemy away (with wall check)
    var otherPushX = -pushX * 0.5;
    var otherPushY = -pushY * 0.5;
    
    with (other) {
        if (!place_meeting(x + otherPushX, y + otherPushY, obj_wall)) {
            // No collision, apply full push
            x += otherPushX;
            y += otherPushY;
        } else {
            // Check each axis separately for sliding
            if (!place_meeting(x + otherPushX, y, obj_wall)) {
                x += otherPushX; // Slide horizontally
            }
            if (!place_meeting(x, y + otherPushY, obj_wall)) {
                y += otherPushY; // Slide vertically
            }
        }
    }
}