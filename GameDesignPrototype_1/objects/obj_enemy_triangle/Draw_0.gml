/// @description Insert description here
// You can write your code in this editor
draw_self();



if (shotTimer > 0)
{
	var _alpha = 1 - (shotTimer / 60);
	draw_sprite_ext(spr_triangle, -1, x, y, image_xscale, image_yscale, image_angle, c_red, _alpha)
}