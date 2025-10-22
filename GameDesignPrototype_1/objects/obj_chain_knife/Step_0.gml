/// @description obj_chain_knife
/// STEP EVENT

if (!instance_exists(owner)) {
    instance_destroy();
    exit;
}

var delta = game_speed_delta();

if (!is_returning) {
    // OUTBOUND
    distance_traveled += speed * delta;
    
    // Max distance check
    if (distance_traveled >= max_distance) {
        is_returning = true;
        speed = return_speed;
    }
    
    // Enemy collision
    var enemy = instance_place(x, y, obj_enemy);
    if (enemy != noone && !enemy.marked_for_death && !has_hit) {
        //takeDamage(enemy, damage, owner);
		enemy.damage_sys.TakeDamage(damage, owner);
        
        var kb_dir = direction;
        enemy.knockback.Apply(kb_dir, 8);
        enemy.hitFlashTimer = 5;
        
        repeat(8) {
            var p = instance_create_depth(x, y, depth - 1, obj_particle);
            p.direction = kb_dir + random_range(-30, 30);
            p.speed = random_range(2, 5);
        }
        
        has_hit = true;
        is_returning = true;
        speed = return_speed;
    }
    
    // Wall collision
    if (place_meeting(x, y, obj_wall)) {
        is_returning = true;
        speed = return_speed;
    }
    
    image_angle = direction;
    
} else {
    // RETURNING
    direction = point_direction(x, y, owner.x, owner.y);
    image_angle = direction;
    speed = return_speed;
    
    // Reached owner
    if (point_distance(x, y, owner.x, owner.y) < 16) {
        if (weapon_struct != noone) {
            weapon_struct.active_knife = noone;
        }
        instance_destroy();
    }
}

depth = -y;