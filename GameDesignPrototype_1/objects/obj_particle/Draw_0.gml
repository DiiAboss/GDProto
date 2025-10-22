/// Draw Event - obj_particle
var alpha = 1 - (timer / lifetime);

for (var i = 1; i <= trail_length; i++) {
    var trail_x = x - lengthdir_x(speed * i, direction);
    var trail_y = y - lengthdir_y(speed * i, direction);
    var trail_size = size * (1 - i / trail_length);
    var trail_alpha_mult = 1 - (i / trail_length);

    draw_set_alpha(alpha * trail_alpha * trail_alpha_mult);
    draw_set_color(particle_color);
    draw_circle(trail_x, trail_y, trail_size, false);
}

// Main particle
draw_set_alpha(alpha);
draw_set_color(particle_color);

if (sprite != noone) {
    draw_sprite_ext(sprite, 0, x, y, size * 0.5, size * 0.5, rotation, particle_color, alpha);
} else {
    draw_circle(x, y, size, false);
}

// Bright core
draw_set_color(c_white);
draw_set_alpha(alpha * 0.6);
draw_circle(x, y, size * 0.4, false);

// Reset
draw_set_alpha(1);
draw_set_color(c_white);
