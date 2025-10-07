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
}

// Create explosion damage in area
var hit_list = ds_list_create();
var hit_count = collision_circle_list(x, y, 50, obj_enemy, false, true, hit_list, false);

for (var i = 0; i < hit_count; i++) {
    var enemy = hit_list[| i];
    
    // IMPORTANT: Skip enemies that are already marked for death
    if (variable_instance_exists(enemy, "marked_for_death") && enemy.marked_for_death) {
        continue;
    }
    
    enemy.hp -= damage * 2;
    
    // Check if this killed the enemy
    if (enemy.hp <= 0 && source_entity != noone && instance_exists(source_entity)) {
        var kill_event = {
            enemy_x: enemy.x,
            enemy_y: enemy.y,
            damage: damage * 2,
            kill_source: "explosion",
            enemy_type: enemy.object_index
        };
        
        TriggerModifiers(source_entity, MOD_TRIGGER.ON_KILL, kill_event);
    }
}

ds_list_destroy(hit_list);


// Create visual explosion
//repeat(30) {
    //var part = instance_create_depth(x, y, depth - 20, obj_explosion_particle);
    //part.direction = random(360);
    //part.speed = random_range(2, 10);
    //part.image_blend = choose(c_orange, c_yellow, c_red);
//}

// Screen shake if you have it
if (instance_exists(obj_camera)) {
    obj_camera.shake = 10;
}

// Cleanup
instance_destroy();