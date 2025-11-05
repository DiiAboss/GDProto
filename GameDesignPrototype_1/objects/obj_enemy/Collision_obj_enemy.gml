if (global.gameSpeed <= 0) exit;
if (isKnockingBack && !hasTransferredKnockback) {
    var transferDir = point_direction(x, y, other.x, other.y);
    var transferForce = knockbackPower * 0.75;
    
    if (transferForce > 0.5 && other.knockbackCooldown <= 0) {
        var kbX = lengthdir_x(transferForce, transferDir);
        var kbY = lengthdir_y(transferForce, transferDir);
        
        // Check if the knockback would push enemy into wall
        var testX = other.x + kbX;
        var testY = other.y + kbY;
        
        // Smart knockback application with wall detection
        if (!place_meeting(testX, testY, obj_wall)) {
            // No wall collision, apply full knockback
            other.knockbackX = kbX;
            other.knockbackY = kbY;
        } else {
            // Will hit wall, check each axis separately
            
            // Try horizontal knockback
            if (!place_meeting(testX, other.y, obj_wall)) {
                other.knockbackX = kbX;
            } else {
                // Hit horizontal wall - apply bounce force instead
                other.knockbackX = -kbX * bounceDampening; // Bounce back
            }
            
            // Try vertical knockback
            if (!place_meeting(other.x, testY, obj_wall)) {
                other.knockbackY = kbY;
            } else {
                // Hit vertical wall - apply bounce force instead
                other.knockbackY = -kbY * bounceDampening; // Bounce back
            }
        }
        
        // Only apply cooldown if we actually transferred knockback
        if (other.knockbackX != 0 || other.knockbackY != 0) {
            other.knockbackCooldown = 5;
            hasTransferredKnockback = true;
            
            // Reduce our knockback
            knockbackX *= 0.8;
            knockbackY *= 0.8;
        }
    }
}
// NORMAL SEPARATION: Regular pushing when enemies overlap
else if (!isKnockingBack && !other.isKnockingBack) {
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
    
    if (!place_meeting(other.x + otherPushX, other.y + otherPushY, obj_wall)) {
        // No collision, apply full push
        other.x += otherPushX;
        other.y += otherPushY;
    } else {
        // Check each axis separately for sliding
        if (!place_meeting(other.x + otherPushX, other.y, obj_wall)) {
            other.x += otherPushX; // Slide horizontally
        }
        if (!place_meeting(other.x, other.y + otherPushY, obj_wall)) {
            other.y += otherPushY; // Slide vertically
        }
    }
}

