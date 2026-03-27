event_inherited();

if (marked_for_death) exit;

var delta = game_speed_delta();

switch (state) {
    case "idle":
        idle_duration -= delta;
        current_movement_speed = base_speed * 0.2; // Barely moving
        moveSpeed = current_movement_speed;
        
        // Squash down (preparing to burst)
        squash_scale_x = lerp(squash_scale_x, 1.1, 0.1);
        squash_scale_y = lerp(squash_scale_y, 0.9, 0.1);
        
        if (idle_duration <= 0) {
            state = "bursting";
            burst_progress = 0;
            burst_timer = 0;
        }
        break;
    
    case "bursting":
        burst_timer += delta;
        burst_progress = burst_timer / burst_duration;
        
        // Quick acceleration then deceleration
        var burst_curve;
        if (burst_progress < 0.3) {
            // Fast acceleration (0 -> 0.3)
            burst_curve = power(burst_progress / 0.3, 0.5);
        } else {
            // Slow deceleration (0.3 -> 1.0)
            burst_curve = 1.0 - power((burst_progress - 0.3) / 0.7, 2);
        }
        
        current_movement_speed = base_speed + (burst_speed - base_speed) * burst_curve;
        moveSpeed = current_movement_speed;
        
        // Stretch during burst
        squash_scale_x = lerp(1.0, 0.9, burst_curve);
        squash_scale_y = lerp(1.0, 1.1, burst_curve);
        
        // End burst
        if (burst_progress >= 1) {
            state = "idle";
            idle_duration = irandom_range(idle_min, idle_max);
            moveSpeed = base_speed * 0.2;
        }
        break;
}
