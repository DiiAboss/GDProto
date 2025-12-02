/// @description Draw direction indicator

if (!indicator_visible) exit;
if (indicator_target == noone || !instance_exists(indicator_target)) exit;
if (!instance_exists(obj_player)) exit;

var player = obj_player;
var dir = point_direction(player.x, player.y, indicator_target.x, indicator_target.y);

// Position arrow in front of player
var dist = 40;
var ax = player.x + lengthdir_x(dist, dir);
var ay = player.y + lengthdir_y(dist, dir);

// Bob animation
var bob = sin(current_time * 0.01) * 4;
ax += lengthdir_x(bob, dir);
ay += lengthdir_y(bob, dir);

draw_sprite_ext(spr_arrow, 0, ax, ay, 1, 1, dir, c_yellow, 0.9);