/// @desc Fire Effect - Apply to nearby enemies
if (lifetime <= 0) {
    instance_destroy();
    exit;
}
lifetime--;

// Get all enemies in radius
var hit_list = ds_list_create();
collision_circle_list(x, y, effect_radius, obj_enemy, false, true, hit_list, false);

for (var i = 0; i < ds_list_size(hit_list); i++) {
    var enemy = hit_list[| i];
    if (enemy.marked_for_death) continue;
    
    // Apply burn status
    enemy.status.ApplyBurn(burn_duration, burn_damage);
    
    // Visual feedback
    repeat(5) {
        var p = instance_create_depth(enemy.x, enemy.y, -100, obj_particle);
        p.sprite_index = spr_fire_particle;
        p.image_blend = choose(c_red, c_orange, c_yellow);
        p.direction = random(360);
        p.speed = random_range(1, 3);
    }
}

ds_list_destroy(hit_list);