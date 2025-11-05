if (!loaded) exit;

/// @description Handle carrying and projectile physics
// At the VERY TOP of step event:
if (is_falling) {
    fall_timer++;
    var fall_progress = fall_timer / fall_duration;
    
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

if (is_being_carried && instance_exists(carrier)) {
    // Follow carrier
    x = carrier.x + carry_offset_x;
    y = carrier.y + carry_offset_y;
    depth = carrier.depth + carry_depth_offset;
    image_angle = 0;
    
    // === SHADOW: Match carrier's ground position ===
    shadowX = carrier.x;
    shadowY = carrier.y + shadow_offset;
    shadow_scale = 0.8;
    shadow_alpha = 0.25;
}
else if (is_projectile) {
    // PROJECTILE MODE
    
    if (is_lob_shot) {
        // === LOB ARC PHYSICS ===
        lobProgress += projectile_speed * game_speed_delta();
        
        var dist_traveled = point_distance(xStart, yStart, x, y);
        var total_distance = point_distance(xStart, yStart, targetX, targetY);
        
        if (total_distance > 0) {
            lobStep = clamp(dist_traveled / total_distance, 0, 1);
        } else {
            lobStep = 0;
        }
        
        var progress_ratio = clamp(dist_traveled / targetDistance, 0, 1);
        
        // Parabolic arc
        var arc_offset = -lobHeight * sin(progress_ratio * pi);
        
        // Move forward
        x += moveX * game_speed_delta();
        y += (moveY * game_speed_delta()) + arc_offset * 0.1;
        
        // === SHADOW: Track ground position ===
        shadowX = lerp(xStart, targetX, lobStep);
        shadowY = lerp(yStart, targetY, lobStep) + shadow_offset;
        
        var height_factor = abs(sin(progress_ratio * pi));
        shadow_scale = lerp(1.0, 0.5, height_factor);
        shadow_alpha = lerp(0.3, 0.15, height_factor);
        
        // Check if landed
        if (progress_ratio >= 0.95 || place_meeting(x, y, obj_wall)) {
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
    else {
        // === STRAIGHT THROW PHYSICS ===
        x += moveX * game_speed_delta();
        y += moveY * game_speed_delta();
        
        // === SHADOW: Simple ground tracking ===
        shadowX = x;
        shadowY = y + shadow_offset;
        shadow_scale = 1.0;
        shadow_alpha = 0.3;
        
        // Check collision with enemies
        var enemy = instance_place(x, y, obj_enemy);
        if (enemy != noone && !enemy.marked_for_death) {
            //enemy.hp  -= damage;
			//takeDamage(enemy, enemy.hp, self)
            enemy.damage_sys.TakeDamage(enemy.hp, self);
            var kb_dir = point_direction(xprevious, yprevious, x, y);
            enemy.knockbackX = lengthdir_x(damage * 0.5, kb_dir);
            enemy.knockbackY = lengthdir_y(damage * 0.5, kb_dir);
            enemy.hitFlashTimer = 5;
            
            repeat(10) {
                var p = instance_create_depth(x, y, depth - 1, obj_particle);
                p.direction = kb_dir + random_range(-30, 30);
                p.speed = random_range(2, 6);
            }
            
            if (destroy_on_impact) {
                instance_destroy();
                return;
            } else {
                is_projectile = false;
                moveX *= -0.3;
                moveY *= -0.3;
            }
        }
        
        // Check collision with walls
        if (place_meeting(x, y, obj_wall)) {
            if (destroy_on_impact) {
                repeat(15) {
                    var p = instance_create_depth(x, y, depth - 1, obj_particle);
                    p.direction = random(360);
                    p.speed = random_range(3, 8);
                }
                instance_destroy();
                return;
            } else {
                is_projectile = false;
                moveX *= -bounce_dampening;
                moveY *= -bounce_dampening;
            }
        }
        
        if (has_trail && is_charged_throw) {
            var trail = instance_create_depth(x, y, depth + 1, obj_particle);
            trail.image_blend = trail_color;
            trail.image_alpha = 0.6;
        }
    }
}
else {
    // === NORMAL PHYSICS (not carried, not projectile) ===
    
    // Update knockback component
    knockback.Update(self);
    
    // Update hit cooldown
    if (hit_cooldown > 0) {
        hit_cooldown = timer_tick(hit_cooldown);
    }
    
    // Apply friction to regular movement (not knockback)
    if (!knockback.IsActive()) {
        moveX *= friction_amount;
        moveY *= friction_amount;
        
        if (abs(moveX) < speed_threshold) moveX = 0;
        if (abs(moveY) < speed_threshold) moveY = 0;
    }
    
    // Apply regular movement
    x += moveX * game_speed_delta();
    y += moveY * game_speed_delta();
    
    // Collision with walls
    if (place_meeting(x, y, obj_wall)) {
        x = xprevious;
        y = yprevious;
        moveX *= -bounce_dampening;
        moveY *= -bounce_dampening;
    }
    
    // === SHADOW: Normal ground position ===
    shadowX = x;
    shadowY = y + shadow_offset;
    shadow_scale = 1.0;
    shadow_alpha = 0.3;
    
    // Update visual effects
    if (hitFlashTimer > 0) {
        hitFlashTimer = timer_tick(hitFlashTimer);
    }
    if (shake > 0) {
        shake *= 0.8;
        if (shake < 0.1) shake = 0;
    }
}

if (!is_being_carried && !is_projectile) {
    // Calculate current speed
    var current_speed = point_distance(0, 0, moveX, moveY);
    var fall_speed_threshold = 2.0; // Only fall if moving slower than this
    
    // Only check for pit if moving slowly (not flying fast)
    var is_slow_enough = (current_speed < fall_speed_threshold);
    var has_some_momentum = (current_speed > speed_threshold); // Still moving, but slow
    
    if (is_slow_enough && has_some_momentum) {
        var tile_check = tilemap_get_at_pixel(tilemap_id, x, y);
        var center_is_pit = (tile_check > 446 || tile_check == 0);
        
        if (center_is_pit) {
            var buffer_radius = 4;
            var unsafe_count = 0;
            
            var check_points = [
                [x + buffer_radius, y],
                [x - buffer_radius, y],
                [x, y + buffer_radius],
                [x, y - buffer_radius]
            ];
            
            for (var i = 0; i < array_length(check_points); i++) {
                var tile = tilemap_get_at_pixel(tilemap_id, check_points[i][0], check_points[i][1]);
                if (tile > 446 || tile == 0) unsafe_count++;
            }
            
            if (unsafe_count >= 2) {
                is_falling = true;
                fall_timer = 0;
                fall_entry_x = x;
                fall_entry_y = y;
                fall_start_depth = depth;
                moveX = 0;
                moveY = 0;
                
                show_debug_message("Object falling at speed: " + string(current_speed));
            }
        }
    }
}

depth = -y;