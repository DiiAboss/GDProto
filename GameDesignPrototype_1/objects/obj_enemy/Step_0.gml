
// Handle knockback cooldown
if (knockbackCooldown > 0) {
    knockbackCooldown--;
}

if (wallBounceCooldown > 0) {
    wallBounceCooldown--;
}

if (wallHitCooldown > 0) {
    wallHitCooldown--;
}



// Apply knockback with wall bouncing AND damage
if (abs(knockbackX) > knockbackThreshold || abs(knockbackY) > knockbackThreshold) {
    isKnockingBack = true;
    knockbackPower = point_distance(0, 0, knockbackX, knockbackY);
    
    // Check for wall collision
    var nextX = x + knockbackX;
    var nextY = y + knockbackY;
    
    var hitWall = false;
    var impactSpeed = 0;
    
    // Horizontal wall check (left/right walls)
    if (place_meeting(nextX, y, obj_obstacle) && wallBounceCooldown == 0) {
        hitWall = true;
        impactSpeed = abs(knockbackX);
        
        // Check if we should take damage
        if (impactSpeed > minImpactSpeed && wallHitCooldown == 0) {
            // Calculate impact damage
            var impactDamage = impactSpeed * impactDamageMultiplier;
            impactDamage = min(impactDamage, maxImpactDamage);
            impactDamage = round(impactDamage);
            
   
            wallHitCooldown = 30; // Prevent multiple hits
            takeDamage(self, impactDamage);
   
            
            // Screen shake for hard impacts
            if (impactSpeed > 8) {
                // with (obj_camera) { shake = impactSpeed * 0.3; }
            }
            
            // Impact effect at wall
            var wallX = x + sign(knockbackX) * (sprite_width / 2);
            // effect_create_above(ef_spark, wallX, y, 0, c_white);
            
            // Sound based on impact force
            if (impactSpeed > 10) {
                // audio_play_sound(snd_heavy_impact, 1, false);
            } else if (impactSpeed > 5) {
                // audio_play_sound(snd_medium_impact, 1, false);
            } else {
                // audio_play_sound(snd_light_impact, 1, false);
            }
        }
        
        // Bounce or stop based on speed
        if (abs(knockbackX) > minBounceSpeed) {
            knockbackX = -knockbackX * bounceDampening;
        } else {
            knockbackX = 0;
        }
    } else if (!place_meeting(nextX, y, obj_obstacle)) {
        x = nextX;
    }
    
    // Vertical wall check (top/bottom walls)
    if (place_meeting(x, nextY, obj_obstacle) && wallBounceCooldown == 0) {
        hitWall = true;
        impactSpeed = abs(knockbackY);
        
        // Check if we should take damage
        if (impactSpeed > minImpactSpeed && wallHitCooldown == 0) {
            // Calculate impact damage
            var impactDamage = impactSpeed * impactDamageMultiplier;
            impactDamage = min(impactDamage, maxImpactDamage);
            impactDamage = round(impactDamage);
            
            // Apply damage
            takeDamage(self, impactDamage);
            wallHitCooldown = 30;
			

            
            // Screen shake for hard impacts
            if (impactSpeed > 8) {
                // with (obj_camera) { shake = impactSpeed * 0.3; }
				if (hp <= 0)
				{
					knockbackFriction = 0.01;
					marked_for_death = true;
				}
            }
            
            // Impact effect at wall
            var wallY = y + sign(knockbackY) * (sprite_height / 2);
            // effect_create_above(ef_spark, x, wallY, 0, c_white);
            
            // Sound
            if (impactSpeed > 10) {
                // audio_play_sound(snd_heavy_impact, 1, false);
            } else if (impactSpeed > 5) {
                // audio_play_sound(snd_medium_impact, 1, false);
            }
        }
        
        // Bounce or stop
        if (abs(knockbackY) > minBounceSpeed) {
            knockbackY = -knockbackY * bounceDampening;
        } else {
            knockbackY = 0;
        }
    } else if (!place_meeting(x, nextY, obj_obstacle)) {
        y = nextY;
    }
    
    // Set bounce cooldown if we hit a wall
    if (hitWall) {
        wallBounceCooldown = 2;
        lastBounceDir = point_direction(0, 0, knockbackX, knockbackY);
        
        // Track wall hit for combo scoring
        // global.wallBounceCombo++;
        
        // Credit damage to whoever knocked them
        if (hp <= 0 && instance_exists(lastKnockedBy)) {
            // lastKnockedBy.score += 50; // Wall kill bonus
        }
    }
    
    // Apply friction
    knockbackX *= knockbackFriction;
    knockbackY *= knockbackFriction;
} else {
    // Knockback ended - reset wall hit tracking
    knockbackX = 0;
    knockbackY = 0;
    isKnockingBack = false;
    knockbackPower = 0;
    hasTransferredKnockback = false;
    hasHitWall = false;
    
    // Allow wall damage again after knockback ends
    if (wallHitCooldown > 0 && !isKnockingBack) {
        wallHitCooldown = 0;
    }
}




if !(marked_for_death)
{
	
	// Movement toward player (when not in heavy knockback)
	if (knockbackCooldown <= 0 && abs(knockbackX) < 1 && abs(knockbackY) < 1 && instance_exists(obj_player)) {
	    var _dir = point_direction(x, y, obj_player.x, obj_player.y);
	    var _spd = moveSpeed;
    
	    var moveX = lengthdir_x(_spd, _dir);
	    var moveY = lengthdir_y(_spd, _dir);
    
	    if (!place_meeting(x + moveX, y, obj_obstacle)) {
	        x += moveX;
	    }
	    if (!place_meeting(x, y + moveY, obj_obstacle)) {
	        y += moveY;
	    }
    
	    //image_angle = _dir;
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


if (hp <= 0 && !marked_for_death) {
    marked_for_death = true;
    image_angle = choose(90, 270);
    
    // IMPORTANT: Trigger ON_KILL only ONCE when first marked for death
    var killer = obj_player;  // Or whoever killed them
    
    if (killer != noone && instance_exists(killer)) {
        var kill_event = {
            enemy_x: x,
            enemy_y: y,
            damage: killer.attack,
            kill_source: "direct",
            enemy_type: object_index
        };
        
        TriggerModifiers(killer, MOD_TRIGGER.ON_KILL, kill_event);
    }
}

if (marked_for_death) {
    if (knockbackX == 0 && knockbackY == 0) {
        // Spawn EXP
        var orbCount = irandom_range(1, 3);
        for (var i = 0; i < orbCount; i++) {
            var _exp = instance_create_depth(x, y, depth -1, obj_exp);
            _exp.direction = irandom(359);
            _exp.speed = 3;
        }
        
        // NOW destroy - no more ON_KILL triggers here!
        instance_destroy();
    }
}


