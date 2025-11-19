/// Step Event - obj_particle
timer++;

x += lengthdir_x(speed, direction);
y += lengthdir_y(speed, direction);
//speed *= friction_amount;

if (gravity_strength != 0) {
    vspeed += gravity_strength;
}

if (timer >= lifetime) instance_destroy();
