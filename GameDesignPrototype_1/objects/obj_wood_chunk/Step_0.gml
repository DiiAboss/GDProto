/// @desc Wood Chunk Physics

event_inherited(); // Base physics

if (is_being_carried) exit; // Skip when carried

var delta = game_speed_delta();

// Rotation while flying
if (abs(moveX) > speed_threshold || abs(moveY) > speed_threshold) {
    image_angle += rotation_speed * delta;
    rotation_speed *= power(0.95, delta);
    
    // DAMAGE ENEMIES WHILE MOVING
    if (damage_cooldown <= 0) {
        var hit = instance_place(x, y, obj_enemy);
        if (hit != noone && !hit.marked_for_death) {
            var velocity = point_distance(0, 0, moveX, moveY);
            var damage = base_damage + (velocity * velocity_damage_multiplier);
            damage = round(damage);
            
            hit.damage_sys.TakeDamage(damage, obj_player);
            
            // Knockback
            var hit_dir = point_direction(x, y, hit.x, hit.y);
            hit.knockbackX = lengthdir_x(velocity * knockback_multiplier, hit_dir);
            hit.knockbackY = lengthdir_y(velocity * knockback_multiplier, hit_dir);
            
            // Bounce
            moveX *= -0.6;
            moveY *= -0.6;
            
            damage_cooldown = damage_cooldown_max;
            hit_flash = 5;
        }
    }
}
if (loaded)
{
	// Timers
if (damage_cooldown > 0) damage_cooldown = timer_tick(damage_cooldown);
if (hit_flash > 0) hit_flash = timer_tick(hit_flash);
}
