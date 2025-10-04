/// @description
// obj_lightning: Draw Event
var segments = 5;
var points = [];

for (var i = 0; i <= segments; i++) {
    var t = i / segments;
    var _x = lerp(x, x2, t);
    var _y = lerp(y, y2, t);
    if (i > 0 && i < segments) _y += random_range(-6, 6);
    array_push(points, [_x, _y]);
}

draw_set_alpha(alpha);
draw_set_color(c_aqua);
for (var i = 0; i < array_length(points) - 1; i++) {
    var p1 = points[i];
    var p2 = points[i + 1];
    draw_line_width(p1[0], p1[1], p2[0], p2[1], 2);
}
draw_set_alpha(1);
