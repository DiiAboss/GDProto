/// @description Insert description here
// You can write your code in this editor

if (global.gameSpeed <= 0) exit;

var _dist = distance_to_object(obj_player);
var _speed = 3 * game_speed_delta();
var _dir = point_direction(x, y, obj_player.x, obj_player.y);


switch (state)
{
	case ENEMY_STATE.IDLE:
	break;
	
	case ENEMY_STATE.FOLLOW:
		//image_angle = _dir;
		myDir = _dir;
			
		if (_dist < 128 && state == ENEMY_STATE.FOLLOW)
		{
			state = ENEMY_STATE.ATTACK;
			shotTimer = 60;
			moveSpeed = 0;
		}
		else
		{
			
			moveSpeed = baseSpeed;
		}
	break;
	
	case ENEMY_STATE.ATTACK:
		if (shotTimer > 0)
		{
			image_xscale += 0.005 * game_speed_delta();
			image_yscale += 0.005 * game_speed_delta();
			shotTimer -=  game_speed_delta();
			//image_angle = _dir;
			myDir = _dir;
			image_index = 0;
		}
		else
		{
			image_index = 1;
			image_xscale = 1;
			image_yscale = 1;
			var _bullet = instance_create_depth(x, y - 24, depth - 1, obj_enemy_attack_orb);
			_bullet.direction = myDir;
			_bullet.speed = 6;
			_bullet.mySpeed = 6;
			state = ENEMY_STATE.FOLLOW;
		}
	break;
}

event_inherited();