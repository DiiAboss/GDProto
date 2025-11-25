/// @description Insert description here
// You can write your code in this editor


draw_sprite(sprite_index, image, x, y);

if (show_timer > 0)
{
	show_timer--;
	draw_text(x, y - 64, hp);
}
else
{
	just_hit = false;
}


if (hp <= 0)
{
	image = 1;
	is_dead = true;
	
}