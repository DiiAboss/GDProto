/// @description Handle carrying and projectile physics

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
            enemy.hp -= damage;
            
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

depth = -y;