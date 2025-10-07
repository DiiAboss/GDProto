// --- Step Event ---
if (instance_exists(owner)) {
    // Update sword position to follow player
    x = owner.x;
    y = owner.y;
    
    // Handle combo timer
    if (comboTimer > 0) {
        comboTimer--;
        if (comboTimer == 0) {
            // Combo window expired, reset combo
            comboCount = 0;
        }
    }
    
    // Handle swing initiation
    if (startSwing && !swinging) {
        swinging = true;
        swingProgress = 0;
        startSwing = false;
        hasHitThisSwing = false;
        ds_list_clear(hitList);
        
        // Determine swing direction based on current position
        if (currentPosition == SwingPosition.Down) {
            targetPosition = SwingPosition.Up;
        } else {
            targetPosition = SwingPosition.Down;
        }
    }
    
    // Handle swing animation
    if (swinging) {
        // Increment swing progress (faster swings for higher combo)
        var speedMod = 1;// + (comboCount * 0.2); // Each combo level adds 20% speed
        swingProgress += (swingSpeed * speedMod) / 100;
        
        if (swingProgress <= 1) {
            // Interpolate between positions
            var startOffset = (currentPosition == SwingPosition.Down) ? angleOffset : -angleOffset;
            var endOffset = (targetPosition == SwingPosition.Up) ? -angleOffset : angleOffset;
            
            // Smooth easing curve for more dynamic swing
            var t = swingProgress;
            // Use ease-out curve for more punch
            t = 1 - power(1 - t, 3);
            
            currentAngleOffset = lerp(startOffset, endOffset, t);
        } else {
            // Swing complete
            swinging = false;
            swingProgress = 0;
            
            // Update current position to where we swung to
            currentPosition = targetPosition;
            currentAngleOffset = (currentPosition == SwingPosition.Down) ? angleOffset : -angleOffset;
            
            // Reset combo timer
            comboTimer = comboWindow;
        }
    }
    
    // Calculate sword angle based on player's aim direction
    var baseAngle = owner.mouseDirection;
    image_angle = baseAngle + currentAngleOffset;
    
    // Position sword at correct distance from player
    var actualDistance = swordLength;
    // Pull sword closer during mid-swing for arc effect
    if (swinging && swingProgress > 0.3 && swingProgress < 0.7) {
        actualDistance = swordLength;
    }
    
    x = owner.x + lengthdir_x(actualDistance, image_angle);
    y = owner.y + lengthdir_y(actualDistance, image_angle);
    
    // Collision detection during swing
    if (swinging && swingProgress > 0.05 && swingProgress < 0.95) {
        // Check for enemy collisions
        var hit = instance_place(x, y, obj_enemy); // Assuming you have obj_enemy
		
       if (hit != noone && ds_list_find_index(hitList, hit) == -1) {
		    // Add to hit list to prevent multiple hits
		    ds_list_add(hitList, hit);
			hit.lastKnockedBy = owner; // owner = player who swung sword
		    // Increment combo if within window
		    if (comboTimer > 0) {
		        comboCount++;
		    } else {
		        comboCount = 1;
		    }
    
		    // Calculate damage with combo bonus
		    var baseDamage = attack;
		    var damage = baseDamage * (1 + comboCount * 0.25); // +25% per combo
				
		    // Deal damage
		
		    takeDamage(hit, damage);
		    
			if (hit.hp <= 0)
			{
				obj_game_manager.gm_trigger_event("on_kill", obj_player, self);
			}
			else
			{
				// Fire mods with on_attack trigger
				obj_game_manager.gm_trigger_event("on_attack", obj_player, self);
			}
			
			// Apply knockback using custom knockback variables
		    if (hit.knockbackCooldown <= 0) {
		        var knockbackDir = point_direction(owner.x, owner.y, hit.x, hit.y);
		        knockbackForce = 64 + (comboCount * 1); // Stronger knockback with combo
        
		        // Set the enemy's knockback velocity
		        hit.knockbackX = lengthdir_x(knockbackForce, knockbackDir);
		        hit.knockbackY = lengthdir_y(knockbackForce, knockbackDir);
        
		        // Set cooldown to prevent knockback stacking
		        hit.knockbackCooldown = hit.knockbackCooldownMax;
				return;
		    }
		}

		hit = instance_place(x, y, obj_canhit);

if (hit != noone && hit.hitCooldown <= 0) {
    // Calculate base knockback force
    var baseForce = 10; // Base sword knockback
    var comboMultiplier = 1 + (comboCount * 0.25); // From your combo system
    
    // Sword weight (different weapons have different impact)
    var swordWeight = 30; // Medium sword, could vary by weapon type
    // Light dagger = 10, Heavy hammer = 50
    
    // Calculate force based on weight difference
    var forceMultiplier = 1;
    if (hit.weight > 0) {
        // Heavier objects are harder to move
        forceMultiplier = swordWeight / (swordWeight + hit.weight);
        forceMultiplier = max(forceMultiplier, 0.1); // Minimum 10% force
    }
    // Weight 0 objects (projectiles) always get full force
    
    // Calculate final force
    var finalForce = baseForce * comboMultiplier * forceMultiplier;
    
    // Apply directional knockback
    var knockbackDir = point_direction(x, y, hit.x, hit.y);
    hit.velocityX = lengthdir_x(finalForce, knockbackDir);
    hit.velocityY = lengthdir_y(finalForce, knockbackDir);
    
    // Special handling for projectiles
    if (hit.isProjectile) {
        // Redirect projectile back toward enemies
        hit.direction = knockbackDir;
        hit.speed = finalForce;
        
        // Change ownership (projectile now helps player)
        hit.isHazard = true;
        hit.hazardDamage *= 1.5; // Reflected projectiles do more damage
    }
    
    // Set hit state
    hit.wasHit = true;
    hit.hitCooldown = 10;
    hit.hitFlashTimer = 8;
    
	return;
}


    }
} else {
    // Owner doesn't exist, destroy sword
    instance_destroy();
}