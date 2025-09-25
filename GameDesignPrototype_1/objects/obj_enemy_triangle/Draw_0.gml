/// @description Insert description here
// You can write your code in this editor
event_inherited();
var wobbleAngle = 0;
if (isMoving) {
    wobbleAngle = sin(wobbleTimer + wobbleOffset) * wobbleAmount;
}

// Apply breathing scale
var currentScale = baseScale + sin(breathTimer + breathOffset) * breathScaleAmount;



if (shotTimer > 0)
{
	var _alpha = 1 - (shotTimer / 60);
		// Draw the main enemy sprite with effects
	draw_sprite_ext(
	    sprite_index,
	    img_index,
	    x,
	    y,
	    currentScale * image_xscale,
	    currentScale * image_yscale,
	    image_angle + wobbleAngle,
	    c_red,
	    _alpha
	);
}