/// @description Insert description here
// You can write your code in this editor
/// @description Shatter on wall collision


if (knockback.GetSpeed() > min_shatter_speed) {
    death_from_wall = true;
    
    // Drop rewards
    repeat(irandom_range(1, 3)) {
        var exp_drop = instance_create_depth(x, y, depth - 1, obj_exp);
        exp_drop.direction = random(360);
        exp_drop.speed = random_range(2, 5);
    }
    
    repeat(irandom_range(5, 10)) {
        var coin = instance_create_depth(x, y, depth - 1, obj_coin);
        coin.direction = random(360);
        coin.speed = random_range(2, 5);
    }
    
    var soul = instance_create_depth(x, y, depth - 1, obj_soul_drop);
    soul.direction = random(360);
    soul.speed = random_range(2, 5);
    
    // Shatter effects
    spawn_death_particles(x, y, [c_red, c_white]);
    
    // Destroy
    instance_destroy();
}