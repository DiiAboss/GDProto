/// @description Insert description here
// You can write your code in this editor
/// @description Insert description here
// You can write your code in this editor
var kb = instance_create_depth(x, y, depth, obj_knockback);
var _dir = point_direction(other.x, other.y, x, y);
kb.force = 15;
knockback.Apply(_dir, 4);