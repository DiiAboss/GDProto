/// @description Melee Parent - Step Event (FIXED)

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
        isSwinging = true;
        swingProgress = 0;
        startSwing = false;
        hasHitThisSwing = false;
        ds_list_clear(hitList);
        
		var swing_sound = choose(snd_swing_1, snd_swing_2, snd_swing_3);
		obj_main_controller._audio_system.PlaySFX(swing_sound);
		
        // Determine swing direction
        if (currentPosition == SwingPosition.Down) {
            targetPosition = SwingPosition.Up;
        } else {
            targetPosition = SwingPosition.Down;
        }
        
        
        // TRIGGER ON_ATTACK MODIFIERS
        
        if (instance_exists(owner)) {
            var attack_event = CreateAttackEvent(
                owner,
                AttackType.MELEE,
                owner.mouseDirection,
                self
            );
			
			
            TriggerModifiers(owner, MOD_TRIGGER.ON_ATTACK, attack_event);
			owner.invincibility.Activate();
        }
    }
    
    // Handle swing animation
    if (swinging) {
        var speedMod = 1;
        swingProgress += (swingSpeed * speedMod) / 100;
        
        if (swingProgress <= 1) {
            var startOffset = (currentPosition == SwingPosition.Down) ? angleOffset : -angleOffset;
            var endOffset = (targetPosition == SwingPosition.Up) ? -angleOffset : angleOffset;
            
            var t = swingProgress;
            t = 1 - power(1 - t, 3);
            
            currentAngleOffset = lerp(startOffset, endOffset, t);
        } else {
            swinging = false;
            isSwinging = false;
            swingProgress = 0;
            
            currentPosition = targetPosition;
            currentAngleOffset = (currentPosition == SwingPosition.Down) ? angleOffset : -angleOffset;
            
            comboTimer = comboWindow;
        }
    }
    
    // Check if weapon has synergy projectile spawning
    if (variable_instance_exists(id, "synergy_data") && 
        synergy_data.projectile_behavior != SynergyProjectileBehavior.NONE) {
        
        var should_spawn = false;
        
        switch (synergy_data.projectile_behavior) {
            case SynergyProjectileBehavior.ON_SWING:
                if (startSwing && !variable_instance_exists(id, "spawned_projectiles_this_swing")) {
                    should_spawn = true;
                    spawned_projectiles_this_swing = true;
                }
                if (swingProgress >= 360) {
                    spawned_projectiles_this_swing = false;
                }
                break;
                
            case SynergyProjectileBehavior.ON_HIT:
                // Handled in collision
                break;
                
            case SynergyProjectileBehavior.ON_COMBO_FINISH:
                if (current_combo_hit == owner.weaponCurrent.max_combo - 1 && startSwing) {
                    should_spawn = true;
                }
                break;
        }
        
        if (should_spawn) {
            SpawnSynergyProjectiles(synergy_data, owner);
        }
    }
    
    // Calculate weapon angle
    var baseAngle = owner.mouseDirection;
    image_angle = baseAngle + currentAngleOffset;
    
    // Position weapon
    var actualDistance = swordLength;
    if (swinging && swingProgress > 0.3 && swingProgress < 0.7) {
        actualDistance = swordLength;
    }
    
    x = owner.x + lengthdir_x(actualDistance, image_angle);
    y = owner.y + lengthdir_y(actualDistance, image_angle);
    
    
    // COLLISION DETECTION DURING SWING
    
    if (swinging && swingProgress > 0.05 && swingProgress < 0.95) {
        
        // ===== HIT ENEMIES =====
        var hit = instance_place(x, y, obj_enemy);
        
        if (hit != noone && ds_list_find_index(hitList, hit) == -1) {
            // Skip dead enemies
			obj_main_controller._audio_system.PlaySFX(snd_hit_sound);
            if (variable_instance_exists(hit, "marked_for_death") && hit.marked_for_death) {
                // Don't process this hit
            } else {
                // Add to hit list
                ds_list_add(hitList, hit);
                hit.lastKnockedBy = owner;
                
                // Increment combo
                if (comboTimer > 0) {
                    comboCount++;
                } else {
                    comboCount = 1;
                }
                
                // Calculate damage with combo bonus
                var baseDamage = attack;
                var damage = baseDamage * (1 + comboCount * 0.25);
                
                // Deal damage
                //takeDamage(hit, damage, owner);
                hit.damage_sys.TakeDamage(damage, owner);
                
                // TRIGGER ON_HIT MODIFIERS
                
                if (instance_exists(owner)) {
                    var hit_event = CreateHitEvent(
                        owner,
                        hit,
                        damage,
                        AttackType.MELEE
                    );
                    TriggerModifiers(owner, MOD_TRIGGER.ON_HIT, hit_event);
                }
                
				// SPAWN ELEMENTAL EFFECTS FROM MELEE
    if (instance_exists(owner)) {
        // Check for fire effect
        if (variable_instance_exists(id, "has_fire_effect") && has_fire_effect) {
            var fire = instance_create_depth(hit.x, hit.y, depth, obj_fire_effect);
            fire.burn_duration = burn_duration;
            fire.burn_damage = burn_damage;
            fire.owner = owner;
        }
        
        // Check for ice effect
        if (variable_instance_exists(id, "has_ice_effect") && has_ice_effect) {
            var ice = instance_create_depth(hit.x, hit.y, depth, obj_ice_effect);
            ice.slow_duration = slow_duration;
            ice.slow_amount = slow_amount;
            ice.owner = owner;
        }
        
        // Check for lightning effect
        if (variable_instance_exists(id, "has_lightning_effect") && has_lightning_effect) {
            var lightning = instance_create_depth(hit.x, hit.y, depth, obj_lightning_effect);
            lightning.shock_duration = shock_duration;
            lightning.owner = owner;
        }
        
        // Check for poison effect
        if (variable_instance_exists(id, "has_poison_effect") && has_poison_effect) {
            var poison = instance_create_depth(hit.x, hit.y, depth, obj_poison_effect);
            poison.poison_duration = poison_duration;
            poison.poison_damage = poison_damage;
            poison.owner = owner;
        }
    }
                
                // CHECK FOR KILL (let enemy system handle it naturally)
                
                // The enemy will die in its next step if hp <= 0
                // The controller will trigger ON_KILL modifiers properly
                
                // Synergy projectiles on hit
                if (variable_instance_exists(id, "synergy_data") && 
                    synergy_data.projectile_behavior == SynergyProjectileBehavior.ON_HIT) {
                    SpawnSynergyProjectiles(synergy_data, owner);
                }
                
                // Apply knockback
                if (hit.knockback.cooldown <= 0) {
                    var knockbackDir = point_direction(owner.x, owner.y, hit.x, hit.y);
                    var kbForce = knockbackForce;
                    hit.knockback.Apply(knockbackDir, kbForce);
                }
            }
        }
        
        // ===== HIT CARRIABLE OBJECTS =====
        hit = instance_place(x, y, obj_can_carry);
        
        if (hit != noone && !hit.is_being_carried && ds_list_find_index(hitList, hit) == -1) {
            ds_list_add(hitList, hit);
            
            var knockbackDir = point_direction(owner.x, owner.y, hit.x, hit.y);
			
            
			
			
            var resistance = 1.0;
            if (variable_instance_exists(hit, "hit_resistance")) {
                resistance = hit.hit_resistance;
            }
            
            var kbForce = (knockbackForce / resistance);
            
            if (variable_instance_exists(hit, "knockback")) {
                hit.knockback.Apply(knockbackDir, kbForce);
            }
            
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
            
            repeat(5) {
                var p = instance_create_depth(hit.x, hit.y, hit.depth - 1, obj_particle);
                p.direction = knockbackDir + random_range(-30, 30);
                p.speed = random_range(2, 5);
            }
            
			
			AwardStylePoints("MELEE HIT", 2, 1); // this is wrong, this should be on meelee hit for enemies, and the item melee should have its own medla
			// Track streaks
			melee_streak++;
			if (melee_streak >= 5) {
			    AwardStylePoints("MELEE MASTER", 10, 1); // see above comment for style points awarded
				melee_streak = 0;
			}
        }
    }
} else {
    instance_destroy();
}
