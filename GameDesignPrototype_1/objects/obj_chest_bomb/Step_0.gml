/// @description
if (exploded) exit;

// Movement with friction
if (move_speed > 0.5) {
    x += lengthdir_x(move_speed, move_direction);
    y += lengthdir_y(move_speed, move_direction);
    move_speed *= friction_amount;
}

depth = -y;

// Fuse countdown
if (fuse_lit) {
    fuse_timer++;
    
    if (fuse_timer >= fuse_duration) {
        Explode();
    }
}

// Hit by player weapon to activate/knock
if (!fuse_lit && hit_cooldown <= 0) {
    // Check collision with player weapons
    var hit_weapon = noone;
    
    if (place_meeting(x, y, obj_sword)) hit_weapon = instance_place(x, y, obj_sword);
    else if (place_meeting(x, y, obj_baseball_bat)) hit_weapon = instance_place(x, y, obj_baseball_bat);
    // Add more weapon checks as needed
    
    if (hit_weapon != noone && instance_exists(hit_weapon)) {
        // Light fuse
        fuse_lit = true;
        
        // Calculate knockback direction from hit
        move_direction = point_direction(hit_weapon.x, hit_weapon.y, x, y);
        move_speed = 8;
        
        hit_cooldown = 30;
        
        show_debug_message("Bomb activated!");
    }
}

if (hit_cooldown > 0) hit_cooldown--;

/// @func Explode
function Explode() {
    if (exploded) return;
    exploded = true;
    
    // Camera shake
    if (instance_exists(obj_player)) {
        obj_player.camera.add_shake(12);
    }
    
    // Damage enemies in radius
    with (obj_enemy) {
        var dist = point_distance(x, y, other.x, other.y);
        if (dist <= other.explosion_radius) {
            var damage_falloff = 1 - (dist / other.explosion_radius);
            var final_damage = other.damage * damage_falloff;
            
            // Apply damage (adjust to your damage system)
            if (variable_instance_exists(id, "hp")) {
                hp -= final_damage;
            }
            
            // Knockback
            var kb_dir = point_direction(other.x, other.y, x, y);
            if (variable_instance_exists(id, "knockbackX")) {
                knockbackX = lengthdir_x(other.knockback_force, kb_dir);
                knockbackY = lengthdir_y(other.knockback_force, kb_dir);
            }
        }
    }
    
    // Optional: spawn explosion effect particle/sprite
    // instance_create_depth(x, y, depth-1, obj_explosion);
    
    // Destroy self
    instance_destroy();
}