/// @function apply_knockback(_target, _from_x, _from_y, _force)
/// @desc Standard knockback application (used everywhere)
function apply_knockback(_target, _from_x, _from_y, _force) {
    if (!instance_exists(_target)) return;
    if (!variable_instance_exists(_target, "knockback")) return;
    
    var dir = point_direction(_from_x, _from_y, _target.x, _target.y);
    _target.knockback.Apply(dir, _force);
}

/// @function apply_hit_effects(_target, _flash_time, _shake)
/// @desc Common hit feedback (flash + shake)
function apply_hit_effects(_target, _flash_time = 5, _shake = 3) {
    if (!instance_exists(_target)) return;
    
    if (variable_instance_exists(_target, "hitFlashTimer")) {
        _target.hitFlashTimer = _flash_time;
    }
    if (variable_instance_exists(_target, "shake")) {
        _target.shake = _shake;
    }
}

/// @function damage_in_radius(_x, _y, _radius, _damage, _source, _falloff)
/// @desc AOE damage (used in bombs, explosions)
function damage_in_radius(_x, _y, _radius, _damage, _source = noone, _falloff = 0.25) {
    with (obj_enemy) {
        var dist = point_distance(x, y, _x, _y);
        if (dist <= _radius) {
            var damage_mult = 1 - ((dist / _radius) * (1 - _falloff));
            var actual_damage = _damage * damage_mult;
            damage_sys.TakeDamage(actual_damage, _source);
            apply_knockback(id, _x, _y, actual_damage * 0.3);
        }
    }
}