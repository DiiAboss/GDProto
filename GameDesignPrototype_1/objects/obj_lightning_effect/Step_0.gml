/// @desc Lightning Effect - Apply to nearby enemies
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
    
    // Apply shock using existing status system
    enemy.status.shock_timer = shock_duration;
    enemy.status.shock_stun = true;
    
    // Visual feedback
    repeat(8) {
        var p = instance_create_depth(enemy.x, enemy.y, -100, obj_particle);
        p.sprite_index = spr_lightning_particle;
        p.image_blend = choose(c_yellow, c_white, c_aqua);
        p.direction = random(360);
        p.speed = random_range(2, 4);
    }
}

ds_list_destroy(hit_list);