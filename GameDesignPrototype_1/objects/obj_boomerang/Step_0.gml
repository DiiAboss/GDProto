// obj_boomerang Step Event
event_inherited();
speed = 0; // Disable built-in movement

if (!returning) {
    // Add some curve to the outward flight
    direction += arc_direction * 2; // Rotate 2 degrees per frame
    
    x += lengthdir_x(_speed, direction);
    y += lengthdir_y(_speed, direction);
    
    distance_traveled += _speed;
    
    if (distance_traveled >= max_distance) {
        returning = true;
    }
}
else { // RETURN
    if (instance_exists(owner)) {
        // Point directly at owner and chase
        direction = point_direction(x, y, owner.x, owner.y);
        
        x += lengthdir_x(_speed, direction);
        y += lengthdir_y(_speed, direction);
        
        // Catch when close
        if (point_distance(x, y, owner.x, owner.y) < 32) {
            var attack_event = {
                attack_type: "ranged_return",
                attack_direction: direction,
                attack_position_x: x,
                attack_position_y: y,
                damage: damage,
                projectile: id,
                weapon: (variable_instance_exists(owner, "weaponCurrent") ? owner.weaponCurrent : noone)
            };
            TriggerModifiers(owner, MOD_TRIGGER.ON_RETURN, attack_event);
            instance_destroy();
        }
    } else {
        instance_destroy();
    }
}

image_angle = direction;