// ==========================================
// EARLY EXIT IF PAUSED
// ==========================================
if (global.gameSpeed <= 0) exit;

// ==========================================
// COMPONENT UPDATES
// ==========================================
damage_sys.Update();

// Sync legacy HP variable
hp = damage_sys.hp;

// Check if just died (FIRST TIME ONLY)
if (damage_sys.IsDead() && !marked_for_death) {
    marked_for_death = true;
    image_angle = choose(90, 270);
    knockbackFriction = 0.01; // Slow to a stop
    
    // Trigger ON_KILL modifiers
    var killer = obj_player;
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

// ==========================================
// MARKED FOR DEATH - CONTINUE PHYSICS UNTIL STOPPED
// ==========================================
if (marked_for_death) {
    // Still apply knockback physics until stopped
    if (abs(knockbackX) > knockbackThreshold || abs(knockbackY) > knockbackThreshold) {
        var kb_delta = game_speed_delta();
        var nextX = x + knockbackX * kb_delta;
        var nextY = y + knockbackY * kb_delta;
        
        // Simple wall collision (no damage when dead)
        if (!place_meeting(nextX, y, obj_obstacle)) {
            x = nextX;
        } else {
            knockbackX = 0;
        }
        
        if (!place_meeting(x, nextY, obj_obstacle)) {
            y = nextY;
        } else {
            knockbackY = 0;
        }
        
        // Apply friction
        knockbackX *= power(knockbackFriction, kb_delta);
        knockbackY *= power(knockbackFriction, kb_delta);
    } else {
        // Knockback stopped - NOW destroy and drop loot
        knockbackX = 0;
        knockbackY = 0;
        
        // Spawn drops
        var orbCount = irandom_range(1, 3);
        for (var i = 0; i < orbCount; i++) {
            var _exp = instance_create_depth(x, y, depth - 1, obj_exp);
            var _coin = instance_create_depth(x, y, depth - 1, obj_coin);
            _exp.direction = irandom(359);
            _exp.speed = 3;
        }
        
        instance_destroy();
    }
    
    // Update depth and EXIT - don't process living enemy logic
    depth = -y;
    exit;
}

// ==========================================
// TIMER UPDATES (LIVING ENEMIES ONLY)
// ==========================================
if (knockbackCooldown > 0) {
    knockbackCooldown = timer_tick(knockbackCooldown);
}

if (wallBounceCooldown > 0) {
    wallBounceCooldown = timer_tick(wallBounceCooldown);
}

if (wallHitCooldown > 0) {
    wallHitCooldown = timer_tick(wallHitCooldown);
}

if (hitFlashTimer > 0) {
    hitFlashTimer = timer_tick(hitFlashTimer);
}

// ==========================================
// KNOCKBACK PHYSICS WITH WALL DAMAGE
// ==========================================
if (abs(knockbackX) > knockbackThreshold || abs(knockbackY) > knockbackThreshold) {
    isKnockingBack = true;
    knockbackPower = point_distance(0, 0, knockbackX, knockbackY);
    
    var kb_delta = game_speed_delta();
    var nextX = x + knockbackX * kb_delta;
    var nextY = y + knockbackY * kb_delta;
    
    var hitWall = false;
    var impactSpeed = 0;
    
    // ===== HORIZONTAL WALL COLLISION =====
    if (place_meeting(nextX, y, obj_obstacle) && wallBounceCooldown == 0) {
        hitWall = true;
        impactSpeed = abs(knockbackX);
        
        // Wall impact damage
        if (impactSpeed > minImpactSpeed && wallHitCooldown == 0) {
            var impactDamage = impactSpeed * impactDamageMultiplier;
            impactDamage = clamp(impactDamage, 0, maxImpactDamage);
            impactDamage = round(impactDamage);
            
            damage_sys.TakeDamage(impactDamage, obj_wall);
            wallHitCooldown = 30;
            
            // Screen shake for hard impacts
            if (impactSpeed > 8 && instance_exists(obj_player)) {
                obj_player.camera.add_shake(impactSpeed * 0.3);
            }
        }
        
        // Bounce or stop
        if (abs(knockbackX) > minBounceSpeed) {
            knockbackX = -knockbackX * bounceDampening;
        } else {
            knockbackX = 0;
        }
    } else if (!place_meeting(nextX, y, obj_obstacle)) {
        x = nextX;
    }
    
    // ===== VERTICAL WALL COLLISION =====
    if (place_meeting(x, nextY, obj_obstacle) && wallBounceCooldown == 0) {
        hitWall = true;
        impactSpeed = abs(knockbackY);
        
        // Wall impact damage
        if (impactSpeed > minImpactSpeed && wallHitCooldown == 0) {
            var impactDamage = impactSpeed * impactDamageMultiplier;
            impactDamage = clamp(impactDamage, 0, maxImpactDamage);
            impactDamage = round(impactDamage);
            
            damage_sys.TakeDamage(impactDamage, obj_wall);
            wallHitCooldown = 30;
            
            // Screen shake
            if (impactSpeed > 8 && instance_exists(obj_player)) {
                obj_player.camera.add_shake(impactSpeed * 0.3);
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
    
    // Track wall bounce
    if (hitWall) {
        wallBounceCooldown = 2;
        lastBounceDir = point_direction(0, 0, knockbackX, knockbackY);
        hasHitWall = true;
    }
    
    // Apply friction (scaled by game speed)
    knockbackX *= power(knockbackFriction, kb_delta);
    knockbackY *= power(knockbackFriction, kb_delta);
    
} else {
    // Knockback ended - reset flags
    knockbackX = 0;
    knockbackY = 0;
    isKnockingBack = false;
    knockbackPower = 0;
    hasTransferredKnockback = false;
    hasHitWall = false;
    
    // Clear wall damage cooldown when not knocked back
    if (wallHitCooldown > 0) {
        wallHitCooldown = 0;
    }
}

// ==========================================
// MOVEMENT (when not knocked back)
// ==========================================
if (knockbackCooldown <= 0 && abs(knockbackX) < 1 && abs(knockbackY) < 1 && instance_exists(obj_player)) {
    var _dir = point_direction(x, y, obj_player.x, obj_player.y);
    var _spd = scale_movement(moveSpeed);
    
    var moveX = lengthdir_x(_spd, _dir);
    var moveY = lengthdir_y(_spd, _dir);
    
    if (!place_meeting(x + moveX, y, obj_obstacle)) {
        x += moveX;
    }
    if (!place_meeting(x, y + moveY, obj_obstacle)) {
        y += moveY;
    }
}

// ==========================================
// VISUAL EFFECTS
// ==========================================
// Check if moving (for wobble)
var moveDistance = point_distance(x, y, lastX, lastY);
isMoving = (moveDistance > 0.5);
lastX = x;
lastY = y;

// Breathing/pulse animation
breathTimer += breathSpeed * game_speed_delta();

// Wobble animation
if (isMoving) {
    wobbleTimer += wobbleSpeed * game_speed_delta();
    if (wobbleTimer > 2 * pi) wobbleTimer -= 2 * pi;
} else {
    wobbleTimer = lerp(wobbleTimer, 0, 0.1 * game_speed_delta());
}

// ==========================================
// DAMAGE NUMBERS
// ==========================================
if (took_damage != 0) {
    var isCrit = false;
    var dmg = spawn_damage_number(x, y - 16, took_damage, c_white, isCrit);
    dmg.owner = self;
    took_damage = 0;
}

// ==========================================
// DEPTH SORTING
// ==========================================
depth = -y;