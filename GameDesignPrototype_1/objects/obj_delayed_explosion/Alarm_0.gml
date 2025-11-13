/// @desc obj_delayed_explosion - Complete Fixed Step Event


// FAILSAFE: Prevent too many explosions

if (instance_number(obj_delayed_explosion) > 15) {
    instance_destroy();
    exit;
}

var angle_step = 360 / projectile_count;
for (var i = 0; i < projectile_count; i++) {
    var proj = instance_create_depth(x, y, depth, projectile_type);
    proj.direction = i * angle_step + random_range(-10, 10);
    proj.speed = projectile_speed + random_range(-1, 1);
    
    if (variable_instance_exists(proj, "damage")) {
        proj.damage = damage;
    }
    
    if (variable_instance_exists(proj, "owner")) {
        proj.owner = owner;
    }
    
    
    // CRITICAL: Mark projectiles to prevent chains
    
    proj.from_corpse_explosion = true;
}


// AOE DAMAGE - WITHOUT TRIGGERING MODIFIERS

var hit_list = ds_list_create();
var hit_count = collision_circle_list(x, y, 50, obj_enemy, false, true, hit_list, false);

for (var i = 0; i < hit_count; i++) {
    var enemy = hit_list[| i];
    
    // Skip dead enemies
    if (!instance_exists(enemy)) continue;
    if (variable_instance_exists(enemy, "marked_for_death") && enemy.marked_for_death) {
        continue;
    }
    
    // Apply damage using the proper damage system
    if (variable_instance_exists(enemy, "damage_sys")) {
        enemy.damage_sys.TakeDamage(damage * 2, owner);
    } else {
        enemy.hp -= damage * 2;
    }
    
    // Visual feedback
    if (variable_instance_exists(enemy, "took_damage")) {
        enemy.took_damage = damage * 2;
    }
    if (variable_instance_exists(enemy, "hitFlashTimer")) {
        enemy.hitFlashTimer = 5;
    }
    
    
    // CRITICAL FIX: Mark enemies killed by explosion
    // This prevents the modifier from triggering again
    
    if (variable_instance_exists(enemy, "damage_sys")) {
        if (enemy.damage_sys.IsDead() || enemy.hp <= 0) {
            // Mark this enemy so modifiers know it died from explosion
            enemy.killed_by_modifier = "corpse_explosion";
            
            // OPTIONAL: Still award score, but don't trigger modifiers
            // (The death will be handled in the normal enemy controller)
        }
    } else if (enemy.hp <= 0) {
        enemy.killed_by_modifier = "corpse_explosion";
    }
    
    
    // DO NOT TRIGGER MODIFIERS HERE
    // Let the enemy's normal death flow handle it
    // The marked flag will prevent recursive explosions
    
}

ds_list_destroy(hit_list);


// VISUAL EFFECTS

// Create visual explosion
repeat(20) {
    var part = instance_create_depth(x, y, depth - 20, obj_firework_particle);
	part.particle_color = c_fuchsia;
    part.direction = random(360);
    part.speed = random_range(2, 8);
    part.image_blend = choose(c_orange, c_yellow, c_red);
}

// Screen shake
if (instance_exists(obj_camera_controller)) {
    obj_camera_controller.shake = 8;
} else if (instance_exists(obj_player) && variable_instance_exists(obj_player, "camera")) {
    obj_player.camera.add_shake(8);
}

// Cleanup
instance_destroy();