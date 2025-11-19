/// @description Insert description here
// You can write your code in this editor
// You can write your code in this editor
if (other.isSwinging && !justhit)
{
	hp -= other.attack;
	obj_player.knockback.Apply(point_direction(x, y, obj_player.x, obj_player.y), 2);
	justhit = true;
	show_timer = 30;
	
	if (hp < 0)
	{
		instance_create_depth(x, y, depth, obj_wood_chunk);
	}
}
