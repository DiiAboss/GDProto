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
        var speedMod = 1 + (comboCount * 0.2); // Each combo level adds 20% speed
        swingProgress += (swingSpeed * speedMod) / 100;
        
        if (swingProgress <= 1) {
            // Interpolate between positions
            var startOffset = (currentPosition == SwingPosition.Down) ? downAngleOffset : upAngleOffset;
            var endOffset = (targetPosition == SwingPosition.Up) ? upAngleOffset : downAngleOffset;
            
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
            currentAngleOffset = (currentPosition == SwingPosition.Down) ? downAngleOffset : upAngleOffset;
            
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
        actualDistance = swordLength * 0.9;
    }
    
    x = owner.x + lengthdir_x(actualDistance, image_angle);
    y = owner.y + lengthdir_y(actualDistance, image_angle);
    
    // Collision detection during swing
    if (swinging && swingProgress > 0.2 && swingProgress < 0.8) {
        // Check for enemy collisions
        var hit = instance_place(x, y, obj_enemy); // Assuming you have obj_enemy
        
       if (hit != noone && ds_list_find_index(hitList, hit) == -1) {
    // Add to hit list to prevent multiple hits
    ds_list_add(hitList, hit);
    
    // Increment combo if within window
    if (comboTimer > 0) {
        comboCount++;
        if (comboCount > 5) comboCount = 5; // Cap combo at 5
    } else {
        comboCount = 1;
    }
    
    // Calculate damage with combo bonus
    var baseDamage = 10;
    var damage = baseDamage * (1 + comboCount * 0.25); // +25% per combo
    
    // Deal damage
    hit.hp -= damage;
    
    // Apply knockback using custom knockback variables
    if (hit.knockbackCooldown <= 0) {
        var knockbackDir = point_direction(owner.x, owner.y, hit.x, hit.y);
        knockbackForce = 64 + (comboCount * 1); // Stronger knockback with combo
        
        // Set the enemy's knockback velocity
        hit.knockbackX = lengthdir_x(knockbackForce, knockbackDir);
        hit.knockbackY = lengthdir_y(knockbackForce, knockbackDir);
        
        // Set cooldown to prevent knockback stacking
        hit.knockbackCooldown = hit.knockbackCooldownMax;
    }
    
    // Create hit effect (if you have one)
    // instance_create_depth(hit.x, hit.y, depth-100, obj_hit_effect);
    
    // Screen shake for impact (optional)
    // with (obj_camera) { shake = 2 + comboCount; }
}
    }
} else {
    // Owner doesn't exist, destroy sword
    instance_destroy();
}