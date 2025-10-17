/// @description
// Calculate current wobble angle
var wobbleAngle = 0;
if (isMoving) {
    wobbleAngle = sin(wobbleTimer + wobbleOffset) * wobbleAmount  * global.gameSpeed;
}

// Apply breathing scale
var currentScale = baseScale + sin(breathTimer + breathOffset) * breathScaleAmount;

var dir_to_player = point_direction(x, y, obj_player.x, obj_player.y);

var spr_dir = dir_to_player > 270 || dir_to_player < 90 ? 1 : -1;

// Draw the main enemy sprite with effects
draw_sprite_ext(
    sprite_index,
    img_index,
    x,
    y,
    currentScale * image_xscale * spr_dir,
    currentScale * image_yscale,
    image_angle + wobbleAngle,
    image_blend,
    image_alpha
);