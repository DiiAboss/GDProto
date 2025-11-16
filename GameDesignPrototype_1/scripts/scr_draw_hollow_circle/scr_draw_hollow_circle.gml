
function draw_circle_hollow_quality(x, y, radius, offset, width, quality)
{
    draw_primitive_begin(pr_trianglelist);
    for(var i = offset; i < 360 + offset; i += 360 / quality)
    {
        var r = max(0, radius - width);
        var next_i = (i + (360 / quality));
             
        var inner_x = x + lengthdir_x(r, i);
        var inner_y = y + lengthdir_y(r, i);
        var outer_x = x + lengthdir_x(radius, i);
        var outer_y = y + lengthdir_y(radius, i);
             
        var next_inner_x = x + lengthdir_x(r, next_i);
        var next_inner_y = y + lengthdir_y(r, next_i);
        var next_outer_x = x + lengthdir_x(radius, next_i);
        var next_outer_y = y + lengthdir_y(radius, next_i);
             
        // First triangle
        draw_vertex(inner_x, inner_y);              // inner
        draw_vertex(outer_x, outer_y);              // outer
        draw_vertex(next_inner_x, next_inner_y);    // next inner
             
        // Second triangle
        draw_vertex(next_inner_x, next_inner_y);    // next inner
        draw_vertex(outer_x, outer_y);              // outer
        draw_vertex(next_outer_x, next_outer_y);    // next outer
    }
    draw_primitive_end();
}