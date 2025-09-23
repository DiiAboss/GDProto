// Flash effect when hit
var drawColor = currentColor;
if (hitFlashTimer > 0) {
    drawColor = merge_color(currentColor, c_white, hitFlashTimer / 10);
}

// Draw main sprite
draw_sprite_ext(
    sprite_index,
    image_index,
    x,
    y,
    image_xscale * (1 + level * 0.1), // Slightly bigger at higher levels
    image_yscale * (1 + level * 0.1),
    0,
    drawColor,
    image_alpha
);

// Draw level indicator (optional - remove if you don't want UI)
if (level > 0) {
    // Draw small dots or stars around ball to show level
    for (var i = 0; i < level; i++) {
        var dotAngle = (360 / level) * i + current_time * 0.1;
        var dotX = x + lengthdir_x(20, dotAngle);
        var dotY = y + lengthdir_y(20, dotAngle);
        draw_circle_color(dotX, dotY, 2, currentColor, currentColor, false);
    }
}

// Speed trail when moving fast
if (currentSpeed > mySpeed || level > 3) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(
        sprite_index,
        image_index,
        x - lengthdir_x(10, myDir),
        y - lengthdir_y(10, myDir),
        image_xscale * (1 + level * 0.1) * 0.7,
        image_yscale * (1 + level * 0.1) * 0.7,
        0,
        drawColor,
        0.3
    );
    gpu_set_blendmode(bm_normal);
}