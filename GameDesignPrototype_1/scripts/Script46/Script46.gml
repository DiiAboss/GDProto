/// @function scr_spawn_element_particles(_target, _sprite, _color_array, _count, _size_range, _speed_range, _lifetime_range)
/// @desc Spawns configurable element particles around a target object.
/// Example:
/// scr_spawn_element_particles(obj_enemy, spr_fire_particle, [c_orange, c_red, c_yellow], 3, [1.5,3], [0.5,1], [15,30]);
function scr_spawn_element_particles(
    _target,
    _sprite,
    _color_array = [c_white],
    _count = 3,
    _size_range = [1, 2],
    _speed_range = [0.5, 1],
    _lifetime_range = [15, 30]
) {
    if (!instance_exists(_target)) return;

    for (var i = 0; i < _count; i++) {
        var _p = instance_create_depth(
            _target.x + random_range(-8, 8),
            _target.y + random_range(-8, 8),
            _target.depth - 1,
            obj_particle
        );

        with (_p) {
            sprite = _sprite;

            // Pick a color from the array, blending randomly if more than one
            if (array_length(_color_array) > 1)
                particle_color = merge_color(
                    _color_array[irandom(array_length(_color_array) - 1)],
                    _color_array[irandom(array_length(_color_array) - 1)],
                    irandom(255)
                );
            else
                particle_color = _color_array[0];

            size = random_range(_size_range[0], _size_range[1]);
            speed = random_range(_speed_range[0], _speed_range[1]);
            direction = irandom_range(0, 359);
            lifetime = irandom_range(_lifetime_range[0], _lifetime_range[1]);
            trail_alpha = 0.3;
            trail_length = 2;
            friction_amount = 0.90;
        }
    }
}
