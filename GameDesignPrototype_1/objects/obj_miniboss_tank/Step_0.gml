/// @desc Miniboss Step Event - Self-Contained Logic
var _dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);
if (_dist_to_player) < 400
{
	activated = true;
}

if !activated exit;
	
// Early exit if paused
if (global.gameSpeed <= 0) exit;

var _delta = game_speed_delta();
var _player_exists = instance_exists(obj_player);
var _player_x = _player_exists ? obj_player.x : x;
var _player_y = _player_exists ? obj_player.y : y;
var _player_instance = _player_exists ? obj_player : noone;

// ==========================================
// DEAD STATE - Use inherited controller
// ==========================================
if (marked_for_death) {
    controller_step_dead(_delta);
    exit;
}

// ==========================================
// COMPONENT UPDATES (from base enemy)
// ==========================================
damage_sys.Update();
hp = damage_sys.hp;

// Burning damage (inherited)
if (is_burning && burn_timer > 0) {
    burn_timer = timer_tick(burn_timer);
    
    burn_tick_counter += _delta;
    if (burn_tick_counter >= 30) {
        burn_tick_counter = 0;
        damage_sys.TakeDamage(burn_damage_per_tick, noone);
    }
    
    if (burn_timer <= 0) {
        is_burning = false;
        burn_tick_counter = 0;
        image_blend = c_white;
    }
}

// ==========================================
// DEATH DETECTION
// ==========================================
if (damage_sys.IsDead() && !marked_for_death) {
    marked_for_death = true;
    miniboss_defeated = true;
    image_angle = choose(90, 270);
    knockbackFriction = 0.01;
    
    if (is_burning && variable_instance_exists(id, "holy_water_splash_direction")) {
        killed_by_holy_water = true;
    }
    
    if (_player_instance != noone && instance_exists(_player_instance)) {
        var kill_event = {
            enemy_x: x,
            enemy_y: y,
            damage: _player_instance.attack,
            kill_source: is_burning ? "holy_water" : "direct",
            enemy_type: object_index
        };
        TriggerModifiers(_player_instance, MOD_TRIGGER.ON_KILL, kill_event);
    }
    
    exit;
}

// ==========================================
// TIMER UPDATES
// ==========================================
if (knockbackCooldown > 0) knockbackCooldown = timer_tick(knockbackCooldown);
if (wallBounceCooldown > 0) wallBounceCooldown = timer_tick(wallBounceCooldown);
if (wallHitCooldown > 0) wallHitCooldown = timer_tick(wallHitCooldown);
if (hitFlashTimer > 0) hitFlashTimer = timer_tick(hitFlashTimer);
if (attackTimer > 0) attackTimer = timer_tick(attackTimer);

// ==========================================
// KNOCKBACK PHYSICS (inherited)
// ==========================================
if (abs(knockbackX) > knockbackThreshold || abs(knockbackY) > knockbackThreshold) {
    isKnockingBack = true;
    knockbackPower = point_distance(0, 0, knockbackX, knockbackY);
    
    var nextX = x + knockbackX * _delta;
    var nextY = y + knockbackY * _delta;
    
    var hitWall = false;
    var impactSpeed = 0;
    
    // Horizontal collision
    if (place_meeting(nextX, y, obj_obstacle) && wallBounceCooldown == 0) {
        hitWall = true;
        impactSpeed = abs(knockbackX);
        
        if (impactSpeed > minImpactSpeed && wallHitCooldown == 0) {
            var impactDamage = clamp(round(impactSpeed * impactDamageMultiplier), 0, maxImpactDamage);
            damage_sys.TakeDamage(impactDamage, obj_wall);
            wallHitCooldown = 30;
            
            if (impactSpeed > 8 && _player_exists) {
                _player_instance.camera.add_shake(impactSpeed * 0.3);
            }
        }
        
        knockbackX = (abs(knockbackX) > minBounceSpeed) ? -knockbackX * bounceDampening : 0;
    } else if (!place_meeting(nextX, y, obj_obstacle)) {
        x = nextX;
    }
    
    // Vertical collision
    if (place_meeting(x, nextY, obj_obstacle) && wallBounceCooldown == 0) {
        hitWall = true;
        impactSpeed = abs(knockbackY);
        
        if (impactSpeed > minImpactSpeed && wallHitCooldown == 0) {
            var impactDamage = clamp(round(impactSpeed * impactDamageMultiplier), 0, maxImpactDamage);
            damage_sys.TakeDamage(impactDamage, obj_wall);
            wallHitCooldown = 30;
            
            if (impactSpeed > 8 && _player_exists) {
                _player_instance.camera.add_shake(impactSpeed * 0.3);
            }
        }
        
        knockbackY = (abs(knockbackY) > minBounceSpeed) ? -knockbackY * bounceDampening : 0;
    } else if (!place_meeting(x, nextY, obj_obstacle)) {
        y = nextY;
    }
    
    if (hitWall) {
        wallBounceCooldown = 2;
        lastBounceDir = point_direction(0, 0, knockbackX, knockbackY);
        hasHitWall = true;
    }
    
    knockbackX *= power(knockbackFriction, _delta);
    knockbackY *= power(knockbackFriction, _delta);
} else {
    knockbackX = 0;
    knockbackY = 0;
    isKnockingBack = false;
    knockbackPower = 0;
    hasTransferredKnockback = false;
    hasHitWall = false;
    if (wallHitCooldown > 0) wallHitCooldown = 0;
}

// ==========================================
// MINIBOSS STATE MACHINE
// ==========================================
if (!_player_exists) {
    state = BOSS_STATE.IDLE;
} else {
    var _dist = distance_to_object(obj_player);
    var _dir = point_direction(x, y, _player_x, _player_y);
    myDir = _dir;
    
    switch (state) {
        case BOSS_STATE.IDLE:
            currentSprite = mySprite;
            animationLocked = false;
            state = BOSS_STATE.FOLLOW;
        break;
        
        case BOSS_STATE.FOLLOW:
            currentSprite = mySprite;
            animationLocked = false;
            isCharging = false;
            chargeScale = 1.0;
            
            // Normal movement when not being knocked back
            if (knockbackCooldown <= 0 && abs(knockbackX) < 1 && abs(knockbackY) < 1) {
                var _spd = scale_movement(moveSpeed);
                var moveX = lengthdir_x(_spd, _dir);
                var moveY = lengthdir_y(_spd, _dir);
                
                if (!place_meeting(x + moveX, y, obj_obstacle)) x += moveX;
                if (!place_meeting(x, y + moveY, obj_obstacle)) y += moveY;
            }
            
            // Check attack range
            if (_dist < attackRange && attackTimer <= 0) {
                state = BOSS_STATE.ATTACK;
                attackTimer = attackWindupTime;
                moveSpeed = 0;
                isCharging = true;
                chargeProgress = 0;
            }
        break;
        
        case BOSS_STATE.ATTACK:
            currentSprite = attackSprite;
            animationLocked = true;
            
            if (attackTimer > 0) {
                // Charging phase - visual telegraph
                chargeProgress = 1 - (attackTimer / attackWindupTime);
                chargeScale = lerp(1.0, maxChargeScale, chargeProgress);
                
                image_xscale = chargeScale;
                image_yscale = chargeScale;
                image_index = 0;
                
                // Optional: Add charging color effect
                if (chargeProgress > 0.5) {
                    image_blend = merge_color(c_white, c_red, (chargeProgress - 0.5) * 2);
                }
            } else {
                // Fire projectiles
                image_index = 1;
                image_xscale = 1;
                image_yscale = 1;
                image_blend = c_white;
                
                FireProjectiles(_dir);
                
                state = BOSS_STATE.COOLDOWN;
                attackTimer = attackCooldownTime;
                isCharging = false;
            }
        break;
        
        case BOSS_STATE.COOLDOWN:
            currentSprite = mySprite;
            animationLocked = false;
            chargeScale = 1.0;
            image_blend = c_white;
            
            if (attackTimer <= 0) {
                state = BOSS_STATE.FOLLOW;
                moveSpeed = baseSpeed;
            }
        break;
    }
}

// ==========================================
// VISUAL EFFECTS (inherited)
// ==========================================
var moveDistance = point_distance(x, y, lastX, lastY);
isMoving = (moveDistance > 0.5);
lastX = x;
lastY = y;

breathTimer += breathSpeed * _delta;

if (isMoving && !isCharging) {
    wobbleTimer += wobbleSpeed * _delta;
    if (wobbleTimer > 2 * pi) wobbleTimer -= 2 * pi;
} else {
    wobbleTimer = lerp(wobbleTimer, 0, 0.1 * _delta);
}

// ==========================================
// DAMAGE NUMBERS
// ==========================================
if (took_damage != 0) {
    var dmg = spawn_damage_number(x, y - 32, took_damage, c_white, false);
    dmg.owner = self;
    took_damage = 0;
}

depth = -y;

// ==========================================
// PROJECTILE FIRING FUNCTION
// ==========================================
/// @function FireProjectiles(_direction)
function FireProjectiles(_direction) {
    if (!instance_exists(obj_enemy_attack_orb)) return;
    
    // Calculate spread angles
    var startAngle = _direction - (projectileSpread * (projectileCount - 1) / 2);
    
    for (var i = 0; i < projectileCount; i++) {
        var angle = startAngle + (projectileSpread * i);
        
        var _bullet = instance_create_depth(x, y - size/2, depth - 1, obj_enemy_attack_orb);
        _bullet.direction = angle;
        _bullet.speed = projectileSpeed;
        
        // Set projectile properties if available
        if (variable_instance_exists(_bullet, "mySpeed")) {
            _bullet.mySpeed = projectileSpeed;
        }
        if (variable_instance_exists(_bullet, "damage")) {
            _bullet.damage = projectileDamage;
        }
    }
    
    // Optional: Camera shake on attack
    if (instance_exists(obj_player) && variable_instance_exists(obj_player, "camera")) {
        obj_player.camera.add_shake(3);
    }
}

