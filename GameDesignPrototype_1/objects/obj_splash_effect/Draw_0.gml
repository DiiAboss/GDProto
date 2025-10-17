/// @desc Draw directional cone splash

draw_set_alpha(0.01);

// Draw cone shape
var cone_half_angle = cone_angle / 2;
var segments = 16; // Smoothness of cone

// Outer cone arc
draw_set_color(splash_color);
for (var i = 0; i < segments; i++) {
    var angle1 = splash_direction - cone_half_angle + (cone_angle / segments) * i;
    var angle2 = splash_direction - cone_half_angle + (cone_angle / segments) * (i + 1);
    
    var x1 = x + lengthdir_x(splash_radius * scale, angle1);
    var y1 = y + lengthdir_y(splash_radius * scale, angle1);
    var x2 = x + lengthdir_x(splash_radius * scale, angle2);
    var y2 = y + lengthdir_y(splash_radius * scale, angle2);
    
    draw_line_width(x1, y1, x2, y2, 2);
}

// Draw cone edges
draw_line_width(
    x, 
    y, 
    x + lengthdir_x(splash_radius * scale, splash_direction - cone_half_angle),
    y + lengthdir_y(splash_radius * scale, splash_direction - cone_half_angle),
    3
);
draw_line_width(
    x, 
    y, 
    x + lengthdir_x(splash_radius * scale, splash_direction + cone_half_angle),
    y + lengthdir_y(splash_radius * scale, splash_direction + cone_half_angle),
    3
);

// Inner fill (triangle fan)
draw_set_alpha(alpha * 0.3);
draw_primitive_begin(pr_trianglefan);
draw_vertex_color(x, y, splash_color, alpha * 0.3);

for (var i = 0; i <= segments; i++) {
    var angle = splash_direction - cone_half_angle + (cone_angle / segments) * i;
    var px = x + lengthdir_x(splash_radius * scale, angle);
    var py = y + lengthdir_y(splash_radius * scale, angle);
    draw_vertex_color(px, py, splash_color, alpha * 0.1);
}

draw_primitive_end();

// Center glow
draw_set_alpha(alpha * 0.6);
draw_circle_color(x, y, 8 * scale, splash_color, splash_color, false);

draw_set_alpha(1);
draw_set_color(c_white);