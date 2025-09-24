/// @description
// Draw with shake effect
var drawX = x;
var drawY = y;

if (shake > 0) {
    drawX += random_range(-shake, shake);
    drawY += random_range(-shake, shake);
}

// Draw base spike
draw_sprite_ext(
    sprite_index,
    image_index,
    drawX,
    drawY,
    image_xscale,
    image_yscale,
    image_angle,
    image_blend,
    image_alpha
);

// Draw blood effect (temporary after hit)
if (bloodTimer > 0) {
    draw_set_alpha(bloodTimer / 20 * 0.5);
    draw_sprite_ext(
        sprite_index,
        image_index,
        drawX,
        drawY,
        image_xscale,
        image_yscale,
        image_angle,
        c_red,
        draw_get_alpha()
    );
    draw_set_alpha(1);
}
