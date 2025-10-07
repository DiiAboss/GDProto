var hitPlayer = instance_place(x, y, obj_player);
if (hitPlayer != noone) {
    
    // === SEPARATION FIRST (Prevent Sticking) ===
    // Calculate overlap and push apart
    var pushDir = point_direction(hitPlayer.x, hitPlayer.y, x, y);
    var overlap = (sprite_width/2 + hitPlayer.sprite_width/2) - point_distance(x, y, hitPlayer.x, hitPlayer.y);
    
    if (overlap > 0) {
        // Push enemy away from player to prevent sticking
        var separateX = lengthdir_x(overlap * 0.5, pushDir);
        var separateY = lengthdir_y(overlap * 0.5, pushDir);
        
        // Move enemy if not blocked by wall
        if (!place_meeting(x + separateX, y + separateY, obj_wall)) {
            x += separateX;
            y += separateY;
        } else if (!place_meeting(x + separateX, y, obj_wall)) {
            x += separateX; // Try just horizontal
        } else if (!place_meeting(x, y + separateY, obj_wall)) {
            y += separateY; // Try just vertical
        }
        
        // Also push player in opposite direction
        var playerPushX = lengthdir_x(overlap * 0.5, pushDir + 180);
        var playerPushY = lengthdir_y(overlap * 0.5, pushDir + 180);
        
        if (!place_meeting(hitPlayer.x + playerPushX, hitPlayer.y + playerPushY, obj_wall)) {
            hitPlayer.x += playerPushX;
            hitPlayer.y += playerPushY;
        }
    }
    
    // === HANDLE PLAYER CANNON KNOCKBACK ===
    // Check if player is moving fast (from cannon or other knockback)
    if (abs(hitPlayer.knockbackX) > 3 || abs(hitPlayer.knockbackY) > 3) {
        // Player is flying from cannon - transfer momentum to enemy
        var playerSpeed = point_distance(0, 0, hitPlayer.knockbackX, hitPlayer.knockbackY);
        var transferForce = playerSpeed * 0.75; // Transfer 75% of player's momentum
        
        if (transferForce > 2) {
            // Calculate transfer direction
            var transferDir = point_direction(hitPlayer.x, hitPlayer.y, x, y);
            var kbX = lengthdir_x(transferForce, transferDir);
            var kbY = lengthdir_y(transferForce, transferDir);
            
            // Apply knockback with wall checking
            var testX = x + kbX;
            var testY = y + kbY;
            
            if (!place_meeting(testX, testY, obj_wall)) {
                knockbackX = kbX;
                knockbackY = kbY;
            } else {
                // Check each axis separately
                if (!place_meeting(testX, y, obj_wall)) {
                    knockbackX = kbX;
                } else {
                    knockbackX = -kbX * bounceDampening * 0.5;
                }
                
                if (!place_meeting(x, testY, obj_wall)) {
                    knockbackY = kbY;
                } else {
                    knockbackY = -kbY * bounceDampening * 0.5;
                }
            }
            
            // Reduce player's momentum (they hit something)
            hitPlayer.knockbackX *= 0.5;
            hitPlayer.knockbackY *= 0.5;
            
            // Set knockback cooldown
            knockbackCooldown = 10;
            
            // Damage based on impact speed
            var impactDamage = round(playerSpeed * 2); // Speed-based damage
            takeDamage(self, impactDamage);
            
            
            // Screen shake for hard impact
            if (playerSpeed > 15) {
                // with (obj_camera) { shake = 5; }
            }
            
            return; // Don't do normal collision damage
        }
    }
    
    // === NORMAL COLLISION (Player not cannoning) ===
    // Only do normal damage if player isn't flying
    if (abs(hitPlayer.knockbackX) <= 1 && abs(hitPlayer.knockbackY) <= 1) {
        // Deal normal contact damage to player if not marked for death
        if (!marked_for_death) hitPlayer.hp -= damage;
        
        // Apply gentle knockback to player
        var kbDir = point_direction(x, y, hitPlayer.x, hitPlayer.y);
        hitPlayer.knockbackX = lengthdir_x(knockbackForce, kbDir);
        hitPlayer.knockbackY = lengthdir_y(knockbackForce, kbDir);
        
        // Small bounce for enemy
        var enemyBounceDir = point_direction(hitPlayer.x, hitPlayer.y, x, y);
        knockbackX = lengthdir_x(2, enemyBounceDir);
        knockbackY = lengthdir_y(2, enemyBounceDir);
        
        // Visual feedback
        hitFlashTimer = 5;
    }
}

