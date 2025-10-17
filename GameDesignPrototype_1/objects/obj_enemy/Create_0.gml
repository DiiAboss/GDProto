/// @desc Enemy Create Event - Component-based

mySprite = spr_enemy_1;
size = sprite_get_height(mySprite);
img_index = 0;

marked_for_death = false;

// ==========================================
// COMPONENTS (matching player)
// ==========================================
damage_sys = new DamageComponent(100); // 100 base HP
knockback = new KnockbackComponent(0.85, 0.1);

// Legacy compatibility
hp = damage_sys.hp;
maxHp = damage_sys.max_hp;

// Movement
moveSpeed = 2;
myDir = 0;

// Visual effects
hitFlashTimer = 0;
breathTimer = 0;
breathSpeed = 0.05;
breathScaleAmount = 0.05;
baseScale = 1;
wobbleTimer = 0;
wobbleSpeed = 0.3;
wobbleAmount = 10;
isMoving = false;
lastX = x;
lastY = y;
breathOffset = random(2 * pi);
wobbleOffset = random(2 * pi);

// Knockback tracking
knockbackX = 0;
knockbackY = 0;
knockbackFriction = 0.85;
knockbackThreshold = 0.1;
knockbackCooldown = 0;
knockbackCooldownMax = 10;
knockbackForce = 8;

// Wall impact
minImpactSpeed = 3;
impactDamageMultiplier = 0.1;
maxImpactDamage = 999;
wallHitCooldown = 0;
hasHitWall = false;

// Wall bounce
bounceDampening = 1.1;
minBounceSpeed = 0;
wallBounceCooldown = 0;
lastBounceDir = 0;

// Separation
separationRadius = 24;
pushForce = 0.5;

// Damage tracking
damage = 1; // Damage enemy deals to player
last_hit_by = noone;
last_damage_taken = 0;
took_damage = 0;

// Chain knockback
isKnockingBack = false;
knockbackPower = 0;
hasTransferredKnockback = false;

// Decay
levelDecayTimer = 0;

depth = -y;

is_burning = false;
burn_timer = 0;
burn_damage_per_tick = 2;
burn_tick_counter = 0;

// NEW: Holy water chain reaction tracking
holy_water_splash_direction = 0;
killed_by_holy_water = false;

// ==========================================
// ADD THESE TO obj_enemy CREATE EVENT
// (or in a script if you prefer)
// ==========================================

/// @function controller_step(_delta, _player_exists, _player_x, _player_y, _player_instance)
controller_step = function(_delta, _player_exists, _player_x, _player_y, _player_instance) {
    // ==========================================
    // COMPONENT UPDATES
    // ==========================================
    damage_sys.Update();
    hp = damage_sys.hp;
    
    // ==========================================
    // BURNING DAMAGE OVER TIME
    // ==========================================
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
        
        return; // Exit early, controller will handle dead enemies separately
    }
    
    // ==========================================
    // TIMER UPDATES
    // ==========================================
    if (knockbackCooldown > 0) knockbackCooldown = timer_tick(knockbackCooldown);
    if (wallBounceCooldown > 0) wallBounceCooldown = timer_tick(wallBounceCooldown);
    if (wallHitCooldown > 0) wallHitCooldown = timer_tick(wallHitCooldown);
    if (hitFlashTimer > 0) hitFlashTimer = timer_tick(hitFlashTimer);
    
    // ==========================================
    // KNOCKBACK PHYSICS
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
    // MOVEMENT
    // ==========================================
    if (knockbackCooldown <= 0 && abs(knockbackX) < 1 && abs(knockbackY) < 1 && _player_exists) {
        var _dir = point_direction(x, y, _player_x, _player_y);
        var _spd = scale_movement(moveSpeed);
        
        var moveX = lengthdir_x(_spd, _dir);
        var moveY = lengthdir_y(_spd, _dir);
        
        if (!place_meeting(x + moveX, y, obj_obstacle)) x += moveX;
        if (!place_meeting(x, y + moveY, obj_obstacle)) y += moveY;
    }
    
    // ==========================================
    // VISUAL EFFECTS
    // ==========================================
    var moveDistance = point_distance(x, y, lastX, lastY);
    isMoving = (moveDistance > 0.5);
    lastX = x;
    lastY = y;
    
    breathTimer += breathSpeed * _delta;
    
    if (isMoving) {
        wobbleTimer += wobbleSpeed * _delta;
        if (wobbleTimer > 2 * pi) wobbleTimer -= 2 * pi;
    } else {
        wobbleTimer = lerp(wobbleTimer, 0, 0.1 * _delta);
    }
    
    // ==========================================
    // DAMAGE NUMBERS
    // ==========================================
    if (took_damage != 0) {
        var dmg = spawn_damage_number(x, y - 16, took_damage, c_white, false);
        dmg.owner = self;
        took_damage = 0;
    }
    
    depth = -y;
}

/// @function controller_step_dead(_delta)
controller_step_dead = function(_delta) {
    // Continue physics until stopped
    if (abs(knockbackX) > 0.5 || abs(knockbackY) > 0.5) {
        var nextX = x + knockbackX * _delta;
        var nextY = y + knockbackY * _delta;
        
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
        
        knockbackX *= power(knockbackFriction, _delta);
        knockbackY *= power(knockbackFriction, _delta);
    } else {
        // Stopped - trigger effects and destroy
        knockbackX = 0;
        knockbackY = 0;
        
        if (killed_by_holy_water && variable_instance_exists(id, "holy_water_splash_direction")) {
            CreateHolyWaterSplash(x, y, obj_player, holy_water_splash_direction);
            CreateFireworkEffect(x, y);
        }
        
        var orbCount = irandom_range(1, 3);
        for (var i = 0; i < orbCount; i++) {
            var _exp = instance_create_depth(x, y, depth - 1, obj_exp);
            var _coin = instance_create_depth(x, y, depth - 1, obj_coin);
            _exp.direction = irandom(359);
            _exp.speed = 3;
        }
        
        instance_destroy();
    }
    
    depth = -y;
}