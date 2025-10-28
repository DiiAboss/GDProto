if (!loaded) exit;

/// @description Handle carrying and projectile physics

// ==========================================
// FALLING STATE
// ==========================================
if (is_falling) {
    fall_timer++;
    var fall_progress = fall_timer / fall_duration;
    
    // Visual fade out
    image_xscale = lerp(1.0, 0.1, fall_progress);
    image_yscale = lerp(1.0, 0.1, fall_progress);
    image_angle += 12 * game_speed_delta();
    image_alpha = lerp(1.0, 0.0, fall_progress);
    depth = lerp(fall_start_depth, 300, fall_progress);
    shadow_alpha = lerp(0.3, 0.0, fall_progress);
    
    if (fall_timer >= fall_duration) {
        instance_destroy();
    }
    
    exit; // Stop all other processing
}

// ==========================================
// BEING CARRIED STATE
// ==========================================
if (is_being_carried && instance_exists(carrier)) {
    // Follow carrier position
    x = carrier.x + carry_offset_x;
    y = carrier.y + carry_offset_y;
    depth = carrier.depth + carry_depth_offset;
    image_angle = 0;
    
    // Shadow matches carrier
    shadowX = carrier.x;
    shadowY = carrier.y + shadow_offset;
    shadow_scale = 0.8;
    shadow_alpha = 0.25;
    
    exit; // Skip other physics
}

// ==========================================
// PROJECTILE STATE
// ==========================================
if (is_projectile) {
    
    // --- HOMING LOGIC (Both lob and straight throws) ---
    if (variable_instance_exists(id, "is_homing") && is_homing) {
        // Validate or find new target
        if (!instance_exists(homing_target) || homing_target.marked_for_death) {
            homing_target = instance_nearest(x, y, obj_enemy);
            if (!instance_exists(homing_target)) {
                is_homing = false;
            }
        }
        
        // Apply homing adjustment
        if (is_homing && instance_exists(homing_target)) {
            var target_dir = point_direction(x, y, homing_target.x, homing_target.y);
            var current_dir = point_direction(0, 0, moveX, moveY);
            var current_speed = point_distance(0, 0, moveX, moveY);
            
            // Smoothly turn toward target
            var adjusted_dir = lerp_angle(current_dir, target_dir, homing_strength);
            moveX = lengthdir_x(current_speed, adjusted_dir);
            moveY = lengthdir_y(current_speed, adjusted_dir);
            
            // Update lob target for arc physics
            if (is_lob_shot) {
                targetX = homing_target.x;
                targetY = homing_target.y;
            }
        }
    }
    
    // --- LOB SHOT PHYSICS ---
    if (is_lob_shot) {
        lobProgress += projectile_speed * game_speed_delta();
        
        // Calculate progress
        var dist_traveled = point_distance(xStart, yStart, x, y);
        var total_distance = point_distance(xStart, yStart, targetX, targetY);
        lobStep = (total_distance > 0) ? clamp(dist_traveled / total_distance, 0, 1) : 0;
        var progress_ratio = clamp(dist_traveled / targetDistance, 0, 1);
        
        // Parabolic arc
        var arc_offset = -lobHeight * sin(progress_ratio * pi);
        
        // Move with arc
        x += moveX * game_speed_delta();
        y += (moveY * game_speed_delta()) + arc_offset * 0.1;
        
        // Shadow follows ground position
        shadowX = lerp(xStart, targetX, lobStep);
        shadowY = lerp(yStart, targetY, lobStep) + shadow_offset;
        var height_factor = abs(sin(progress_ratio * pi));
        shadow_scale = lerp(1.0, 0.5, height_factor);
        shadow_alpha = lerp(0.3, 0.15, height_factor);
        
        if (progress_ratio >= 0.95 || place_meeting(x, y, obj_wall)) {
    // Land the object (don't call HandleProjectileHit yet)
    is_projectile = false;
    is_lob_shot = false;
    moveX = 0;
    moveY = 0;
    image_angle = 0;
    
    shadowX = x;
    shadowY = y + shadow_offset;
    shadow_scale = 1.0;
    shadow_alpha = 0.3;
    
    can_be_carried = true;
    
    // Check if we landed ON an enemy
    var enemy = instance_place(x, y, obj_enemy);
    if (enemy != noone && !enemy.marked_for_death) {
        HandleProjectileHit(enemy);
		AwardStylePoints("PROJECTILE HIT", 10, 1);
    }
}
    }
    // --- STRAIGHT THROW PHYSICS ---
    else {
        // Move in straight line
        x += moveX * game_speed_delta();
        y += moveY * game_speed_delta();
        
        // Shadow at ground level
        shadowX = x;
        shadowY = y + shadow_offset;
        shadow_scale = 1.0;
        shadow_alpha = 0.3;
        
        // Trail effect for charged throws
        if (has_trail && is_charged_throw) {
            var trail = instance_create_depth(x, y, depth + 1, obj_particle);
            trail.image_blend = trail_color;
            trail.image_alpha = 0.6;
        }
    }
    
    if (!is_lob_shot) {
    var enemy = instance_place(x, y, obj_enemy);
    if (enemy != noone && !enemy.marked_for_death) {
        HandleProjectileHit(enemy);
    }
}
    
    // Check wall collision for straight throws
    if (!is_lob_shot && place_meeting(x, y, obj_wall)) {
        if (destroy_on_impact) {
            SpawnImpactParticles(15);
            instance_destroy();
        } else {
            is_projectile = false;
            moveX *= -bounce_dampening;
            moveY *= -bounce_dampening;
        }
    }
    
    exit; // Skip normal physics
}

// ==========================================
// NORMAL PHYSICS (Idle on ground)
// ==========================================

// Update knockback
knockback.Update(self);

// Update timers
if (hit_cooldown > 0) hit_cooldown = timer_tick(hit_cooldown);
if (hitFlashTimer > 0) hitFlashTimer = timer_tick(hitFlashTimer);
if (shake > 0) {
    shake *= 0.8;
    if (shake < 0.1) shake = 0;
}

// Apply friction when not being knocked back
if (!knockback.IsActive()) {
    moveX *= friction_amount;
    moveY *= friction_amount;
    
    if (abs(moveX) < speed_threshold) moveX = 0;
    if (abs(moveY) < speed_threshold) moveY = 0;
}

// Apply movement
x += moveX * game_speed_delta();
y += moveY * game_speed_delta();

// Wall collision
if (place_meeting(x, y, obj_wall)) {
    x = xprevious;
    y = yprevious;
    moveX *= -bounce_dampening;
    moveY *= -bounce_dampening;
}

// Update shadow
shadowX = x;
shadowY = y + shadow_offset;
shadow_scale = 1.0;
shadow_alpha = 0.3;

// ==========================================
// PIT DETECTION (Only when idle and slow)
// ==========================================
var current_speed = point_distance(0, 0, moveX, moveY);
var is_slow = (current_speed < 2.0);
var is_moving = (current_speed > speed_threshold);

if (is_slow && is_moving) {
    var tile_check = tilemap_get_at_pixel(tilemap_id, x, y);
    var center_is_pit = (tile_check > 446 || tile_check == 0);
    
    if (center_is_pit) {
        // Check surrounding area
        var unsafe_count = 0;
        var check_points = [
            [x + 4, y], [x - 4, y],
            [x, y + 4], [x, y - 4]
        ];
        
        for (var i = 0; i < 4; i++) {
            var tile = tilemap_get_at_pixel(tilemap_id, check_points[i][0], check_points[i][1]);
            if (tile > 446 || tile == 0) unsafe_count++;
        }
        
        // Start falling if mostly over pit
        if (unsafe_count >= 2) {
            is_falling = true;
            fall_timer = 0;
            fall_entry_x = x;
            fall_entry_y = y;
            fall_start_depth = depth;
            moveX = 0;
            moveY = 0;
        }
    }
}

depth = -y;

// ==========================================
// HELPER FUNCTIONS
// ==========================================

/// @function HandleProjectileHit([enemy])
/// @description Handle collision with enemy or landing
function HandleProjectileHit(_enemy = noone) {
    show_debug_message("HandleProjectileHit called. Enemy: " + string(_enemy != noone) + ", destroy_on_impact: " + string(destroy_on_impact));
    
    // Hit an enemy
    if (_enemy != noone && instance_exists(_enemy)) {
        // Deal damage - check if owner exists first
        var damage_source = variable_instance_exists(id, "owner") ? owner : id;
        _enemy.damage_sys.TakeDamage(damage, damage_source);
        
		if ((_enemy.damage_sys.hp - damage) < 0) AwardStylePoints("THROW KILL", 200, 1);
		
        // Apply knockback
        var kb_dir = point_direction(xprevious, yprevious, x, y);
        _enemy.knockbackX = lengthdir_x(damage * 0.5, kb_dir);
        _enemy.knockbackY = lengthdir_y(damage * 0.5, kb_dir);
        _enemy.hitFlashTimer = 5;
        
        // Impact particles
        SpawnImpactParticles(10, kb_dir);
        
        // Destroy or bounce
        if (destroy_on_impact) {
            show_debug_message("Destroying object due to destroy_on_impact = true");
            instance_destroy();
            return;
        } else {
            show_debug_message("Not destroying - bouncing instead");
            is_projectile = false;
            moveX *= -0.3;
            moveY *= -0.3;
        }
    }
    // Just landed (no enemy hit)
    else {
        show_debug_message("Landed without hitting enemy - becoming idle");
        is_projectile = false;
        is_lob_shot = false;
        moveX = 0;
        moveY = 0;
        image_angle = 0;
        
        shadowX = x;
        shadowY = y + shadow_offset;
        shadow_scale = 1.0;
        shadow_alpha = 0.3;
        
        can_be_carried = true;
    }
}

/// @function SpawnImpactParticles(count, [direction])
/// @description Spawn particle burst on impact
function SpawnImpactParticles(_count, _dir = noone) {
    repeat(_count) {
        var p = instance_create_depth(x, y, depth - 1, obj_particle);
        if (_dir != noone) {
            p.direction = _dir + random_range(-30, 30);
        } else {
            p.direction = random(360);
        }
        p.speed = random_range(2, 6);
    }
}

/// @function lerp_angle(from, to, amount)
/// @description Smooth angle interpolation
function lerp_angle(_from, _to, _amount) {
    var diff = angle_difference(_to, _from);
    return _from + diff * _amount;
}