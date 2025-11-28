/// @description

if (place_meeting(x, y, obj_projectile))
{
	hp -= 1;
	var hit = instance_place(x, y, obj_projectile)
	if (hit != noone)
	{
		with (hit)
		{
			instance_destroy();
		}	
	}
}

if (place_meeting(x, y, obj_melee_parent))
{
	
	var hit = instance_place(x, y, obj_melee_parent)
	if (hit == noone) exit;
	
if (hit.isSwinging)
	{
		var _dir = point_direction(x, y, hit.x, hit.y);
		with (hit.owner)
		{
			knockback.Apply(_dir, 2);
		}
	
		if (variable_instance_exists(self, "sound_played")&& sound_played = false)
		{
			self.sound_played = true;
			alarm[1] = 30;
		obj_main_controller._audio_system.PlaySFXAt(sfx_damage_hit2, x, y);
		}
		hp -= hit.attack * 0.1;
	}
}