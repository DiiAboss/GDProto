/// @description
// Calculate current wobble angle
var wobbleAngle = 0;
if (isMoving) {
    wobbleAngle = sin(wobbleTimer + wobbleOffset) * wobbleAmount  * global.gameSpeed;
}

// Apply breathing scale
var currentScale = baseScale + sin(breathTimer + breathOffset) * breathScaleAmount;

// Draw the main enemy sprite with effects
draw_sprite_ext(
    sprite_index,
    img_index,
    x,
    y,
    currentScale * image_xscale,
    currentScale * image_yscale,
    image_angle + wobbleAngle,
    image_blend,
    image_alpha
);