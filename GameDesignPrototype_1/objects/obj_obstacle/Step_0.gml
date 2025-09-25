/// @description
if (place_meeting(x, y, obj_canhit))
{
	var hit = instance_nearest(x, y, obj_canhit)
	if (hit != noone)
	{
		with (hit)
		{
			instance_destroy();
		}	
	}
}