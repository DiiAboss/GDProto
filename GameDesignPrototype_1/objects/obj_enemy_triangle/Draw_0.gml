/// @description Insert description here
// You can write your code in this editor
var wobbleAngle = 0;


event_inherited();

if (isMoving) {
    wobbleAngle = sin(wobbleTimer + wobbleOffset) * wobbleAmount;
}

// Apply breathing scale
var currentScale = baseScale + sin(breathTimer + breathOffset) * breathScaleAmount;


if (shotTimer > 0)
{
	var dir_to_player = point_direction(x, y, obj_player.x, obj_player.y);

	var spr_dir = dir_to_player > 270 || dir_to_player < 90 ? 1 : -1;
	var _alpha = 1 - (shotTimer / 60);
		// Draw the main enemy sprite with effects

	draw_sprite_ext(spr_enemyAttack, 0, x, y - 24, _alpha, _alpha, 0, c_white, _alpha);
	draw_sprite_ext(
	    sprite_index,
	    image_index,
	    x,
	    y,
	    currentScale * image_xscale * spr_dir,
	    currentScale * image_yscale,
	    image_angle + wobbleAngle,
	    c_red,
	    _alpha
	);
}

