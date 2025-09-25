/// @description Insert description here
// You can write your code in this editor



draw_sprite_ext(mySprite, -1, x, y, 1, 1, 0, c_white, 1);

if (currentWeapon == Weapon.Bow)
{
	draw_sprite_ext(spr_crossbow, 0, x, y, 1, -img_xscale, mouseDirection, c_white, 1);
}



//draw_sprite_ext(spr_air_cannon, 0, x, y, 1, -img_xscale, mouseDirection, c_white, 1);