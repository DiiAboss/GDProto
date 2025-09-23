/// @description
// Set drawing properties
draw_set_alpha(currentAlpha);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
// draw_set_font(textFont); // Uncomment if you have a custom font

// Draw position with crit shake
var drawX = x;
var drawY = y;
if (isCrit) {
    drawX += critShake;
}

// Draw outline/shadow for readability
var outlineSize = 2;
draw_set_color(outlineColor);
for (var ox = -outlineSize; ox <= outlineSize; ox++) {
    for (var oy = -outlineSize; oy <= outlineSize; oy++) {
        if (ox != 0 || oy != 0) {
            draw_text_transformed(
                drawX + ox,
                drawY + oy,
                damageString,
                scale,
                scale,
                0
            );
        }
    }
}

// Draw main text
draw_set_color(textColor);
draw_text_transformed(
    drawX,
    drawY,
    damageString,
    scale,
    scale,
    0
);

// Reset drawing properties
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);