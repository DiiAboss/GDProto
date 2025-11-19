/// @description Insert description here
// You can write your code in this editor
if !(other.isSwinging) exit;
var kb = instance_create_depth(x, y, depth, obj_knockback);
var _dir = point_direction(other.x, other.y, x, y);
kb.force = 15;
knockback.Apply(_dir, 12);
_ra = instance_create_depth(x, y, depth, obj_ripple_attack);
_ra.max_radius = 32;