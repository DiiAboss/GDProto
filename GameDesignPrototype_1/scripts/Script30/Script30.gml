/// @function draw_text_outlined(_x, _y, _text, _outline_color)
function draw_text_outlined(_x, _y, _text, _outline_color) {
    // Draw outline
    draw_set_color(_outline_color);
    for (var ox = -1; ox <= 1; ox++) {
        for (var oy = -1; oy <= 1; oy++) {
            if (ox != 0 || oy != 0) {
                draw_text(_x + ox, _y + oy, _text);
            }
        }
    }
    
    // Draw main text
    draw_set_color(c_white);
    draw_text(_x, _y, _text);
}