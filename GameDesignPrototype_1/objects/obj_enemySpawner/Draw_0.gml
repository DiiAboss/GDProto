/// @description Insert description here
// You can write your code in this editor
if (spawner_timer == 0)
{
	var _scale = 1 - (summon_timer / 60);
	draw_sprite_ext(spr_enemy_spawn, -1, nextX, nextY, _scale, _scale, 1, c_white, _scale);
}