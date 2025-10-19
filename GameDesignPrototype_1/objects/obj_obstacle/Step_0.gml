/// @description
if (place_meeting(x, y, obj_projectile))
{
	var hit = instance_place(x, y, obj_projectile)
	if (hit != noone)
	{
		with (hit)
		{
			instance_destroy();
		}	
	}
}