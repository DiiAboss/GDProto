/// @description Bomb Object - Step Event
event_inherited(); // Call parent obj_can_carry step

// Only tick timer if armed
if (is_armed) {
    timer = timer_tick(timer);
    
    // Calculate timer progress (1.0 = just armed, 0.0 = about to explode)
    var timer_progress = timer / timer_max;
    
    // === PULSING ANIMATION ===
    if (timer > timer_critical_threshold) {
        // Normal/Warning phase
        pulse_speed = lerp(0.05, 0.05, 0.1 - timer_progress);
    } else {
        // Critical phase - FAST pulse
        pulse_speed = 0.25;
    }
    
    pulse_scale = 1.0 + sin(current_time * pulse_speed) * 0.15;
    
    // === COLOR SHIFT ===
    if (timer > timer_warning_threshold) {
        // White to Yellow (early phase)
        var early_progress = 1.0 - ((timer - timer_warning_threshold) / (timer_max - timer_warning_threshold));
        bomb_color = merge_color(c_white, c_yellow, early_progress);
    } else if (timer > timer_critical_threshold) {
        // Yellow to Orange (warning phase)
        var warning_progress = 1.0 - ((timer - timer_critical_threshold) / (timer_warning_threshold - timer_critical_threshold));
        bomb_color = merge_color(c_yellow, c_orange, warning_progress);
    } else {
        // Orange to Red (critical phase)
        var critical_progress = 1.0 - (timer / timer_critical_threshold);
        bomb_color = merge_color(c_orange, c_red, critical_progress);
    }
    
    // === FLASHING ===
    if (timer <= timer_critical_threshold) {
        flash_speed = 0.05;
    } else if (timer <= timer_warning_threshold) {
        flash_speed = 0.15;
    } else {
        flash_speed = 0.05;
    }
    
    flash_timer = (sin(current_time * flash_speed) + 1) * 0.5; // 0.0 to 1.0
    
    // === TIMER PARTICLES ===
    if (timer <= timer_critical_threshold) {
        // Emit danger particles in critical phase
        if (random(1) < 0.3) {
            var p = instance_create_depth(x, y, depth - 1, obj_particle);
            p.direction = random(360);
            p.speed = random_range(0.5, 2);
            p.image_blend = c_red;
        }
    }
    
    // === EXPLODE ===
    if (timer <= 0) {
        Explode();
    }
}

// Special case: Lob shot that landed - arm it now
if (is_lob_shot && !is_projectile && !is_armed && armed_by != noone) {
    ArmBomb(armed_by);
}