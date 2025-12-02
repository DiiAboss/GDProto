if (!other.isSwinging) exit;

direction = point_direction(other.x, other.y, x, y);
speed *= 1.5;
deflected = true;

// Effects
repeat(5) {
    var p = instance_create_depth(x, y, depth - 1, obj_particle);
    p.direction = direction + random_range(-30, 30);
    p.speed = random_range(2, 4);
}
obj_main_controller._audio_system.PlaySFX(snd_hit_sound);
