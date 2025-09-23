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
    
    //image_angle = _dir;
}


if (abs(knockbackX) > knockbackThreshold || abs(knockbackY) > knockbackThreshold) {
    isKnockingBack = true;
    knockbackPower = point_distance(0, 0, knockbackX, knockbackY);
    
    // Store original position
    var prevX = x;
    var prevY = y;
    
    // Try to move
    var nextX = x + knockbackX;
    var nextY = y + knockbackY;
    
    var hitHorizontal = false;
    var hitVertical = false;
    
    // Check both axes simultaneously for corner detection
    if (place_meeting(nextX * 1.01, nextY * 1.01, obj_wall)) {
        // We hit something, figure out what
        
        // Check horizontal collision
        if (place_meeting(nextX * 1.01, y, obj_wall)) {
            hitHorizontal = true;
        }
        
        // Check vertical collision
        if (place_meeting(x, nextY * 1.01, obj_wall)) {
            hitVertical = true;
        }
        
        // Apply bounces with dampening
        if (hitHorizontal && abs(knockbackX) > minBounceSpeed && wallBounceCooldown == 0) {
            knockbackX = -knockbackX * bounceDampening;
        } else if (hitHorizontal) {
            knockbackX = 0;
        }
        
        if (hitVertical && abs(knockbackY) > minBounceSpeed && wallBounceCooldown == 0) {
            knockbackY = -knockbackY * bounceDampening;
        } else if (hitVertical) {
            knockbackY = 0;
        }
        
        // Set bounce cooldown if we bounced
        if (hitHorizontal || hitVertical) {
            wallBounceCooldown = 2;
            
            // Corner bounce effect (both axes hit)
            if (hitHorizontal && hitVertical) {
                // effect_create_above(ef_star, x, y, 1, c_yellow);
                // Special corner bounce bonus
                // global.cornerBounceBonus += 100;
            }
        }
    }
    
    // Move to new position if not blocked
    if (!place_meeting(x + knockbackX, y, obj_wall)) {
        x += knockbackX;
    }
    if (!place_meeting(x, y + knockbackY, obj_wall)) {
        y += knockbackY;
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
    hasTransferredKnockback = false;
}


// Check if enemy is moving (for wobble effect)
var moveDistance = point_distance(x, y, lastX, lastY);
isMoving = (moveDistance > 0.5); // Moving if we've moved more than 0.5 pixels
lastX = x;
lastY = y;

// Update breathing/pulse effect (always active)
breathTimer += breathSpeed;
var breathScale = baseScale + sin(breathTimer + breathOffset) * breathScaleAmount;

// Update walking wobble
if (isMoving) {
    wobbleTimer += wobbleSpeed;
    // Reset wobble smoothly when starting to move
    if (wobbleTimer > 2 * pi) wobbleTimer -= 2 * pi;
} else {
    // Smoothly return to center when stopped
    wobbleTimer = lerp(wobbleTimer, 0, 0.1);
}


if (took_damage != 0)
{
	// Spawn damage number
	//var isCrit = (random(1) < 0.1); // 10% crit chance
	//if (isCrit) took_damage *= 2;
	var isCrit = false;
	var dmg = spawn_damage_number(x, y - 16, took_damage, c_white, isCrit);
	dmg.owner = self;
	took_damage = 0;
}


// Death check
if (hp <= 0) {
    instance_destroy();
}