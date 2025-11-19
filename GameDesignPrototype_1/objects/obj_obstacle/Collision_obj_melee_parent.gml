/// @description Insert description here
// You can write your code in this editor


if (other.isSwinging)
{
	var _dir = point_direction(x, y, other.x, other.y);
	with (other.owner)
	{
		knockback.Apply(_dir, 2);
	}
}