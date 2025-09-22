/// @description Insert description here
// You can write your code in this editor
event_inherited();


var _dist = distance_to_object(obj_player);
var _speed = 3;
var _dir = point_direction(x, y, obj_player.x, obj_player.y);


switch (state)
{
	case ENEMY_STATE.IDLE:
	break;
	
	case ENEMY_STATE.FOLLOW:
		image_angle = _dir;
		myDir = _dir;
			
		if (_dist < 128 && state == ENEMY_STATE.FOLLOW)
		{
			state = ENEMY_STATE.ATTACK;
			shotTimer = 60;
			moveSpeed = 0;
		}
		else
		{
			
			moveSpeed = 4;
		}
	break;
	
	case ENEMY_STATE.ATTACK:
		if (shotTimer > 0)
		{
			image_xscale += 0.005;
			image_yscale += 0.005;
			shotTimer -= 1;
			image_angle = _dir;
			myDir = _dir;
		}
		else
		{
			
			image_xscale = 1;
			image_yscale = 1;
			var _bullet = instance_create_depth(x + lengthdir_x(32, myDir), y + lengthdir_y(32, myDir), depth - 1, obj_enemyAttack);
			_bullet.direction = myDir;
			_bullet.speed = 6;
			
			state = ENEMY_STATE.FOLLOW;
		}
	break;
}