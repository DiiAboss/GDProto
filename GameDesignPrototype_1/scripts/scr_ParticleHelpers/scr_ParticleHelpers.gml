/// @function spawn_particles(_x, _y, _count, _color1, _color2, _speed_min, _speed_max, _dir)
function spawn_particles(_x, _y, _count, _color1 = c_white, _color2 = c_gray, _speed_min = 2, _speed_max = 6, _dir = -1) {
    repeat(_count) {
        var p = instance_create_depth(_x, _y, -9999, obj_particle);
        p.direction = (_dir == -1) ? random(360) : _dir + random_range(-30, 30);
        p.speed = random_range(_speed_min, _speed_max);
        p.image_blend = choose(_color1, _color2);
    }
}

/// @function spawn_impact_particles(_x, _y, _count, _direction)
/// @desc Impact burst pattern (used in combat)
function spawn_impact_particles(_x, _y, _count = 8, _direction = 0) {
    spawn_particles(_x, _y, _count, c_white, c_gray, 2, 5, _direction);
}

/// @function spawn_death_particles(_x, _y, _colors)
/// @desc Death explosion pattern
function spawn_death_particles(_x, _y, _colors = [c_red, c_orange]) {
    repeat(15) {
        var p = instance_create_depth(_x, _y, -9999, obj_particle);
        p.direction = random(360);
        p.speed = random_range(2, 6);
        p.image_blend = _colors[irandom(array_length(_colors) - 1)];
    }
}

/// @function spawn_elemental_particles(_x, _y, _element)
/// @desc Element-specific particles (consolidates switch statements)
function spawn_elemental_particles(_x, _y, _element, _count = 12) {
    var color1, color2;
    switch (_element) {
        case ELEMENT.FIRE: color1 = c_red; color2 = c_orange; break;
        case ELEMENT.ICE: color1 = c_aqua; color2 = c_blue; break;
        case ELEMENT.LIGHTNING: color1 = c_yellow; color2 = c_white; break;
        case ELEMENT.POISON: color1 = make_color_rgb(100, 255, 100); color2 = make_color_rgb(50, 200, 50); break;
        default: color1 = c_white; color2 = c_gray;
    }
    spawn_particles(_x, _y, _count, color1, color2, 3, 8);
}