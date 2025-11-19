/// @description Insert description here
// You can write your code in this editor
knockback.Update(self);

if (_ra != noone && instance_exists(_ra))
{
	_ra.x = x;
	_ra.y = y;
}
else
{
	_ra = noone;
}