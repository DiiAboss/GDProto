/// @description Insert description here
// You can write your code in this editor

if (place_meeting(x, y, obj_melee_parent))
{
	if (obj_melee_parent.isSwinging)
	{
		image_speed = 1;
		direction = point_direction(obj_melee_parent.x, obj_melee_parent.y, x, y)
		speed = 4;
	}
}

