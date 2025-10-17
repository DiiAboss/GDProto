/// @description Melee Parent - Step Event

if (instance_exists(owner)) {
    // Update weapon position to follow player
    x = owner.x;
    y = owner.y;
    
    // Handle combo timer
    if (comboTimer > 0) {
        comboTimer--;
        if (comboTimer == 0) {
            comboCount = 0;
        }
    }
    
    // Handle swing initiation
    if (startSwing && !swinging) {
        swinging = true;
        isSwinging = true; // Set both for compatibility
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
        // Increment swing progress
        var speedMod = 1;
        swingProgress += (swingSpeed * speedMod) / 100;
        
        if (swingProgress <= 1) {
            // Interpolate between positions
            var startOffset = (currentPosition == SwingPosition.Down) ? angleOffset : -angleOffset;
            var endOffset = (targetPosition == SwingPosition.Up) ? -angleOffset : angleOffset;
            
            // Smooth easing curve for more dynamic swing
            var t = swingProgress;
            t = 1 - power(1 - t, 3); // Use ease-out curve
            
            currentAngleOffset = lerp(startOffset, endOffset, t);
        } else {
            // Swing complete
            swinging = false;
            isSwinging = false;
            swingProgress = 0;
            
            // Update current position to where we swung to
            currentPosition = targetPosition;
            currentAngleOffset = (currentPosition == SwingPosition.Down) ? angleOffset : -angleOffset;
            
            // Reset combo timer
            comboTimer = comboWindow;
        }
    }
	
	
	// Check if weapon has synergy projectile spawning
	if (variable_instance_exists(id, "synergy_data") && 
	    synergy_data.projectile_behavior != SynergyProjectileBehavior.NONE) {
	    
	    var should_spawn = false;
	    
	    // Determine if we should spawn projectile this frame
	    switch (synergy_data.projectile_behavior) {
	        case SynergyProjectileBehavior.ON_SWING:
	            // Spawn once when swing starts
	            if (startSwing && !variable_instance_exists(id, "spawned_projectiles_this_swing")) {
	                should_spawn = true;
	                spawned_projectiles_this_swing = true;
	            }
	            // Reset flag when swing ends
	            if (swingProgress >= 360) {
	                spawned_projectiles_this_swing = false;
	            }
	            break;
	            
	        case SynergyProjectileBehavior.ON_HIT:
	            // Spawn when weapon hits enemy (handled in collision)
	            break;
	            
	        case SynergyProjectileBehavior.ON_COMBO_FINISH:
	            // Only spawn on final combo hit
	            if (current_combo_hit == owner.weaponCurrent.max_combo - 1 && startSwing) {
	                should_spawn = true;
	            }
	            break;
	    }
	    
	    // Actually spawn projectiles
	    if (should_spawn) {
	        SpawnSynergyProjectiles(synergy_data, owner);
	    }
	}
	
	
    
    // Calculate weapon angle based on player's aim direction
    var baseAngle = owner.mouseDirection;
    image_angle = baseAngle + currentAngleOffset;
    
    // Position weapon at correct distance from player
    var actualDistance = swordLength;
    // Pull weapon closer during mid-swing for arc effect
    if (swinging && swingProgress > 0.3 && swingProgress < 0.7) {
        actualDistance = swordLength;
    }
    
    x = owner.x + lengthdir_x(actualDistance, image_angle);
    y = owner.y + lengthdir_y(actualDistance, image_angle);
    
    // Collision detection during swing
    if (swinging && swingProgress > 0.05 && swingProgress < 0.95) {
        
        // ===== HIT ENEMIES =====
        var hit = instance_place(x, y, obj_enemy);
        
        if (hit != noone && ds_list_find_index(hitList, hit) == -1) {
            // Add to hit list to prevent multiple hits
            ds_list_add(hitList, hit);
            hit.lastKnockedBy = owner;
			
            // After dealing damage, check for ON_HIT projectile behavior
			if (variable_instance_exists(id, "synergy_data") && 
			    synergy_data.projectile_behavior == SynergyProjectileBehavior.ON_HIT) {
			    
			    SpawnSynergyProjectiles(synergy_data, owner);
			}
			
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
            takeDamage(hit, damage, owner);
            
            if (hit.hp <= 0) {
                obj_game_manager.gm_trigger_event("on_kill", obj_player, self);
            } else {
                obj_game_manager.gm_trigger_event("on_attack", obj_player, self);
            }
            
            // Apply knockback
            if (hit.knockbackCooldown <= 0) {
                var knockbackDir = point_direction(owner.x, owner.y, hit.x, hit.y);
                var kbForce = knockbackForce;
                
                hit.knockbackX = lengthdir_x(kbForce, knockbackDir);
                hit.knockbackY = lengthdir_y(kbForce, knockbackDir);
                hit.knockbackCooldown = hit.knockbackCooldownMax;
            }
        }
        
        // ===== HIT CARRIABLE OBJECTS =====
        hit = instance_place(x, y, obj_can_carry);
        
        if (hit != noone && !hit.is_being_carried && ds_list_find_index(hitList, hit) == -1) {
            // Add to hit list
            ds_list_add(hitList, hit);
            
            // Calculate knockback
            var knockbackDir = point_direction(owner.x, owner.y, hit.x, hit.y);
            
            // Get resistance (with safety check)
            var resistance = 1.0;
            if (variable_instance_exists(hit, "hit_resistance")) {
                resistance = hit.hit_resistance;
            }
            
            var kbForce = (knockbackForce / resistance);
            
            // Apply knockback to object
            if (variable_instance_exists(hit, "knockback")) {
                hit.knockback.Apply(knockbackDir, kbForce);
            }
            
            // Visual feedback
            if (variable_instance_exists(hit, "hitFlashTimer")) {
                hit.hitFlashTimer = 5;
            }
            if (variable_instance_exists(hit, "shake")) {
                hit.shake = 3;
            }
            if (variable_instance_exists(hit, "hit_cooldown")) {
                hit.hit_cooldown = hit.hit_cooldown_max;
            }
            if (variable_instance_exists(hit, "last_hit_by")) {
                hit.last_hit_by = owner;
            }
            
            // Particles
            repeat(5) {
                var p = instance_create_depth(hit.x, hit.y, hit.depth - 1, obj_particle);
                p.direction = knockbackDir + random_range(-30, 30);
                p.speed = random_range(2, 5);
            }
            // In melee parent, when hitting carriable:
			show_debug_message("=== HIT CARRIABLE ===");
			show_debug_message("Base knockbackForce: " + string(knockbackForce));
			show_debug_message("Combo count: " + string(comboCount));
			show_debug_message("Resistance: " + string(resistance));
			show_debug_message("Final force: " + string(kbForce));
			show_debug_message("Object weight: " + string(hit.weight));
            show_debug_message("Hit carriable object: " + object_get_name(hit.object_index));
        }
    }
} else {
    // Owner doesn't exist, destroy weapon
    instance_destroy();
}

/// @desc Spawn projectiles based on synergy config
function SpawnSynergyProjectiles(_synergy, _owner) {
    var count = _synergy.projectile_count ?? 1;
    var spread = _synergy.projectile_spread ?? 0;
    var base_dir = point_direction(_owner.x, _owner.y, mouse_x, mouse_y);
    
    // Calculate starting angle for spread
    var start_angle = base_dir - (spread * (count - 1)) / 2;
    
    for (var i = 0; i < count; i++) {
        var proj_dir = start_angle + (spread * i);
        
        var proj = instance_create_depth(
            _owner.x, 
            _owner.y, 
            _owner.depth - 1, 
            _synergy.projectile
        );
        
        proj.direction = proj_dir;
        proj.image_angle = proj_dir;
        proj.speed = 8;
        proj.owner = _owner;
        
        if (variable_instance_exists(proj, "damage")) {
            proj.damage = _owner.attack * 0.7; // 70% of base attack
        }
    }
}