// Handle knockback cooldown
if (knockbackCooldown > 0) {
    knockbackCooldown--;
}

// Movement toward player (when not in heavy knockback)
if (knockbackCooldown <= 0 && abs(knockbackX) < 1 && abs(knockbackY) < 1 && instance_exists(obj_player)) {
    var _dir = point_direction(x, y, obj_player.x, obj_player.y);
    var _spd = moveSpeed;
    
    var moveX = lengthdir_x(_spd, _dir);
    var moveY = lengthdir_y(_spd, _dir);
    
    if (!place_meeting(x + moveX, y, obj_wall)) {
        x += moveX;
    }
    if (!place_meeting(x, y + moveY, obj_wall)) {
        y += moveY;
    }
    
    image_angle = _dir;
}

// Apply knockback movement
if (abs(knockbackX) > knockbackThreshold || abs(knockbackY) > knockbackThreshold) {
    // We're being knocked back
    isKnockingBack = true;
    
    // Calculate current knockback power (for chain reaction)
    knockbackPower = point_distance(0, 0, knockbackX, knockbackY);
    
    // Move with knockback
    if (!place_meeting(x + knockbackX, y, obj_wall)) {
        x += knockbackX;
    } else {
        knockbackX = 0;
    }
    
    if (!place_meeting(x, y + knockbackY, obj_wall)) {
        y += knockbackY;
    } else {
        knockbackY = 0;
    }
    
    // Apply friction
    knockbackX *= knockbackFriction;
    knockbackY *= knockbackFriction;
} else {
    // Knockback ended
    knockbackX = 0;
    knockbackY = 0;
    isKnockingBack = false;
    knockbackPower = 0;
    hasTransferredKnockback = false; // Reset for next knockback
}

// Death check
if (hp <= 0) {
    instance_destroy();
}