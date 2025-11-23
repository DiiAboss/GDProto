/// @description Insert description here
// You can write your code in this editor
if (other.knockback.is_active)
{
	damage_sys.TakeDamage(50, obj_player, ELEMENT.PHYSICAL);
	with (other) instance_destroy();
}