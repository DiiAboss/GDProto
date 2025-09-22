/// @description Insert description here
// You can write your code in this editor
if (spawner_timer > 0)
{
	spawner_timer--;
	nextX = irandom_range(x_min, x_max);
	nextY = irandom_range(y_min, y_max);
	summon_timer = 60;
}
else
{
	if (summon_timer > 0)
	{
		summon_timer--;
	}
	else
	{
		nextType = irandom(1);
		var _enemy = obj_enemy;
		
		switch(nextType)
		{
			case ENEMY_TYPE.CIRCLE:
			_enemy = obj_enemy;
			break;
			
			case ENEMY_TYPE.TRIANGLE:
			_enemy = obj_enemy_triangle;
			break;
		}
		
		instance_create_depth(nextX, nextY, depth, _enemy);
		spawner_timer = 300;
	}
	
}