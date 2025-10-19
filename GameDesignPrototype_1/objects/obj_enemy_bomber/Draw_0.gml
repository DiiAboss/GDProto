/// @description
// Draw shadow / blob if needed
event_inherited();

// Draw dash indicator if showing
if (showIndicator) {
    var endX = x + lengthdir_x(indicatorLength, indicatorDir);
    var endY = y + lengthdir_y(indicatorLength, indicatorDir);

    draw_set_color(indicatorColor);
    draw_set_alpha(0.7);
    draw_line_width(x, y, endX, endY, 4);
    draw_set_alpha(1);
}
