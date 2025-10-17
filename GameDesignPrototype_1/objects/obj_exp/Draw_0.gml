/// @description
var alpha = 1 - (timer / lifetime);

// Draw trail (motion blur effect)
for (var i = 1; i <= trail_length; i++) {
    var trail_x = x - lengthdir_x(speed * i, direction);
    var trail_y = y - lengthdir_y(speed * i, direction);
    var trail_size = size * (1 - i / trail_length);
    var trail_alpha_mult = 1 - (i / trail_length);
    
    draw_set_alpha(alpha * trail_alpha * trail_alpha_mult);
    draw_set_color(particle_color);
    draw_circle(trail_x, trail_y, trail_size, false);
}

// Draw main particle
draw_set_alpha(alpha);
draw_set_color(particle_color);
draw_circle(x, y, size, false);

// Bright core
draw_set_color(c_white);
draw_circle(x, y, size * 0.5, false);

draw_set_alpha(1);
draw_set_color(c_white);