/// @description Insert description here
// You can write your code in this editor


if (other.isSwinging)
{
	var _dir = point_direction(x, y, other.x, other.y);
	with (other.owner)
	{
		knockback.Apply(_dir, 2);
	}
	
	if (variable_instance_exists(self, "sound_played")&& sound_played = false)
	{
		self.sound_played = true;
		alarm[1] = 30;
	obj_main_controller._audio_system.PlaySFXAt(sfx_damage_hit2, x, y);
	}

}