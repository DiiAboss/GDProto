/// @desc Poison Effect - Apply to nearby enemies
if (lifetime <= 0) {
    instance_destroy();
    exit;
}
lifetime--;

var hit_list = ds_list_create();
collision_circle_list(x, y, effect_radius, obj_enemy, false, true, hit_list, false);

for (var i = 0; i < ds_list_size(hit_list); i++) {
    var enemy = hit_list[| i];
    if (enemy.marked_for_death) continue;
    
    // Apply poison using existing status system
    enemy.status.poison_timer = poison_duration;
    enemy.status.poisoned = true;
    enemy.status.poison_dps = poison_damage;
    
    // Visual feedback
    repeat(6) {
        var p = instance_create_depth(enemy.x, enemy.y, -100, obj_particle);
        p.sprite_index = spr_poison_particle;
        p.image_blend = make_color_rgb(irandom_range(80, 120), irandom_range(220, 255), irandom_range(80, 150));
        p.direction = random(360);
        p.speed = random_range(0.5, 2);
    }
}

ds_list_destroy(hit_list);