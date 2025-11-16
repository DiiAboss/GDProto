/// @description Insert description here
// You can write your code in this editor
if (other.isSwinging)
{
	alarm[1] = 60;
    amount = 0;
	obj_player.knockback.Apply(point_direction(x, y, obj_player.x, obj_player.y), 16);
}
