/// @function draw_text_outlined(_x, _y, _text, _outline_color)
/// -------------------------------------------------------------
/// Simple utility to render readable text by layering a colored
/// outline around white foreground text.
/// Typical use:
///     draw_text_outlined(320, 240, "Paused", c_black);
/// -------------------------------------------------------------
/// Parameters:
///   _x, _y          – Draw coordinates.
///   _text           – String to render.
///   _outline_color  – Color applied to surrounding offset text.
/// -------------------------------------------------------------
/// Notes:
///   • Uses an 8-pass loop (one per surrounding pixel).
///   • Does not alter font/halign/valign—caller sets them.
///   • Lightweight alternative to using shaders or surface blur.
function draw_text_outlined(_x, _y, _text, _outline_color) {
    // Outline pass: draw 8 neighboring offsets
    draw_set_color(_outline_color);
    for (var ox = -1; ox <= 1; ox++) {
        for (var oy = -1; oy <= 1; oy++) {
            if (ox != 0 || oy != 0) {
                draw_text(_x + ox, _y + oy, _text);
            }
        }
    }
    
    // Foreground pass
    draw_set_color(c_white);
    draw_text(_x, _y, _text);
}