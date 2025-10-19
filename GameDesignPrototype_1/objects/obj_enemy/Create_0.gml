/// @desc Enemy Create Event - Component-based

mySprite = spr_enemy_1;
size = sprite_get_height(mySprite);
img_index = 0;

marked_for_death = false;
// Pit fall state
is_falling = false;
fall_timer = 0;
fall_duration = 60; // 1 second
fall_entry_x = 0;
fall_entry_y = 0;
fall_start_depth = 0;

// Tile layer reference
tile_layer = "Tiles_2";
tile_layer_id = layer_get_id(tile_layer);
tilemap_id = layer_tilemap_get_id(tile_layer_id);

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


scored_this_death = false;    // Prevents double-scoring
total_damage_taken = 0;       // Track actual damage for overkill

// Score value (set based on enemy type)
score_value = 10;             // Default, override in child enemies

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
killed_by_modifier = undefined;  // Tracks if killed by modifier (prevents chain reactions)
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
    // DEATH DETECTION - FIXED
    // ==========================================
    if (damage_sys.IsDead() && !marked_for_death) {
        marked_for_death = true;
        image_angle = choose(90, 270);
        knockbackFriction = 0.01;
        
        // ==========================================
        // DETERMINE KILL SOURCE
        // ==========================================
        var kill_source = "direct"; // Default
        
        // Check if killed by a modifier (prevents chain reactions)
        if (variable_instance_exists(id, "killed_by_modifier")) {
            kill_source = killed_by_modifier;
        }
        // Check if killed by burning
        else if (is_burning) {
            if (variable_instance_exists(id, "holy_water_splash_direction")) {
                kill_source = "holy_water";
                killed_by_holy_water = true;
            } else {
                kill_source = "burning";
            }
        }
        // Check if killed by wall impact
        else if (variable_instance_exists(id, "last_hit_by") && last_hit_by == obj_wall) {
            kill_source = "wall_impact";
        }
        
        // ==========================================
        // TRIGGER ON_KILL MODIFIERS - FIXED
        // ==========================================
        if (_player_instance != noone && instance_exists(_player_instance)) {
            // Use the proper event helper
            var kill_event = CreateKillEvent(
                _player_instance,  // entity/owner
                x,                 // enemy_x
                y,                 // enemy_y
                total_damage_taken > 0 ? total_damage_taken : maxHp,  // damage
                kill_source,       // kill_source
                object_index       // enemy_type
            );
            
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
    
   //// @description Enemy Pit System - Only Fall When Knocked Back
// ==========================================
// MOVEMENT WITH PIT AVOIDANCE (Normal Movement Only)
// ==========================================
if (knockbackCooldown <= 0 && abs(knockbackX) < 1 && abs(knockbackY) < 1 && _player_exists) {
    var _dir = point_direction(x, y, _player_x, _player_y);
    var _spd = scale_movement(moveSpeed);
    
    var moveX = lengthdir_x(_spd, _dir);
    var moveY = lengthdir_y(_spd, _dir);
    
    // Check ahead distance
    var check_ahead = 12;
    var next_check_x = x + lengthdir_x(check_ahead, _dir);
    var next_check_y = y + lengthdir_y(check_ahead, _dir);
    
    // Check if pit ahead (tile > 446 OR tile == 0 = PIT)
    var tile_ahead = tilemap_get_at_pixel(tilemap_id, next_check_x, next_check_y);
    var is_pit_ahead = (tile_ahead > 446 || tile_ahead == 0);
    
    if (is_pit_ahead) {
        // PIT DETECTED - Find alternative direction
        var try_angles = [45, -45, 90, -90, 135, -135];
        var found_safe_path = false;
        
        for (var i = 0; i < array_length(try_angles); i++) {
            var test_dir = _dir + try_angles[i];
            var test_x = x + lengthdir_x(check_ahead, test_dir);
            var test_y = y + lengthdir_y(check_ahead, test_dir);
            
            var test_tile = tilemap_get_at_pixel(tilemap_id, test_x, test_y);
            
            // Safe tile: NOT 0 AND <= 446
            var is_safe = (test_tile != 0 && test_tile <= 446);
            
            if (is_safe && 
                !place_meeting(x + lengthdir_x(_spd, test_dir), y, obj_obstacle) &&
                !place_meeting(x, y + lengthdir_y(_spd, test_dir), obj_obstacle)) {
                
                moveX = lengthdir_x(_spd, test_dir);
                moveY = lengthdir_y(_spd, test_dir);
                found_safe_path = true;
                break;
            }
        }
        
        // No safe path - stop
        if (!found_safe_path) {
            moveX = 0;
            moveY = 0;
        }
    }
    
    // Apply movement
    if (!place_meeting(x + moveX, y, obj_obstacle)) x += moveX;
    if (!place_meeting(x, y + moveY, obj_obstacle)) y += moveY;
}

// ==========================================
// PIT FALL CHECK (Only During Knockback or Already Falling)
// ==========================================
if (!is_falling) {
    // Only check for pit fall if being knocked back OR moving fast
    var is_being_knocked = (abs(knockbackX) > knockbackThreshold || abs(knockbackY) > knockbackThreshold);
    
    if (is_being_knocked) {
        // Check center point
        var tile_check = tilemap_get_at_pixel(tilemap_id, x, y);
        var center_is_pit = (tile_check > 446 || tile_check == 0);
        
        // Safety buffer
        var buffer_radius = 6;
        var unsafe_count = 0;
        
        // Check 4 points around enemy
        var check_points = [
            [x + buffer_radius, y],
            [x - buffer_radius, y],
            [x, y + buffer_radius],
            [x, y - buffer_radius]
        ];
        
        for (var i = 0; i < array_length(check_points); i++) {
            var tile = tilemap_get_at_pixel(tilemap_id, check_points[i][0], check_points[i][1]);
            var is_pit = (tile > 446 || tile == 0);
            if (is_pit) unsafe_count++;
        }
        
        // Fall if center is pit AND at least 2 buffer points are also pit
        if (center_is_pit && unsafe_count >= 2) {
            is_falling = true;
            fall_timer = 0;
            fall_entry_x = x;
            fall_entry_y = y;
            fall_start_depth = depth;
            
            // Stop knockback momentum
            knockbackX = 0;
            knockbackY = 0;
            
            show_debug_message("ENEMY KNOCKED INTO PIT! Center tile: " + string(tile_check) + " Unsafe: " + string(unsafe_count) + "/4");
        }
    }
}

// ==========================================
// PROCESS FALLING ANIMATION
// ==========================================
if (is_falling) {
    fall_timer++;
    var fall_progress = fall_timer / fall_duration;
    
    // Shrink, spin, fade
    image_xscale = lerp(1.0, 0.0, fall_progress);
    image_yscale = lerp(1.0, 0.0, fall_progress);
    image_angle += 15 * _delta;
    image_alpha = lerp(1.0, 0.0, fall_progress);
    
    // Push behind tiles (200 = Tiles_2 depth)
    depth = lerp(fall_start_depth, 300, fall_progress);
    
    // Complete fall
    if (fall_timer >= fall_duration) {
        // Drop XP at entry point
        var orbCount = irandom_range(1, 3);
        for (var i = 0; i < orbCount; i++) {
            var _exp = instance_create_depth(fall_entry_x, fall_entry_y, -9999, obj_exp);
            var _coin = instance_create_depth(fall_entry_x, fall_entry_y, -9999, obj_coin);
            _exp.direction = irandom(359);
            _exp.speed = 3;
        }
        
        marked_for_death = true;
        hp = 0;
    }
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