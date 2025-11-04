/// @description Insert description here
// You can write your code in this editor
if (life > 0)
{
    life -= game_speed_delta();
}
else {
	if (stages > 0)
    {
        for (var i = -limit; i < -limit + amount; i++)
        {
            if (i==0) && (amount * 0.5 == 0) continue;
            
            var _spawn = instance_create_depth(x, y, depth, obj_split_projectile);
            _spawn.stages = stages - 1;
            var _new_dir = direction + (30 * i);
            _spawn.direction = _new_dir;
            _spawn.base_life = base_life * 0.75;
            _spawn.life = base_life * 0.75;
            _spawn.speed = speed * 1.25;
        }
    }
    
    instance_destroy();
}