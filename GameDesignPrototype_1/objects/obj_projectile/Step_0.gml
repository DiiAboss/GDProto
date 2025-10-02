//direction = myDir;



if (projectileType == PROJECTILE_TYPE.NORMAL)
{
	if (life > 0)
	{
		life -= 1;
	}
	else
	{
		instance_destroy();
	}
	
	
	if (active)
	{
		if (place_meeting(x,y,obj_enemy))
		{
			var enemy = instance_nearest(x,y,obj_enemy);
			 // Apply knockback using custom knockback variables
		    if (enemy.knockbackCooldown <= 0) {
		        var knockbackDir = point_direction(x, y, enemy.x, enemy.y);
		        var knockbackForce = 5; // Stronger knockback with combo
	        
		        // Set the enemy's knockback velocity
		        enemy.knockbackX = lengthdir_x(knockbackForce, knockbackDir);
		        enemy.knockbackY = lengthdir_y(knockbackForce, knockbackDir);
	        
		        // Set cooldown to prevent knockback stacking
		        enemy.knockbackCooldown = enemy.knockbackCooldownMax;
		    }
			
			active = false;
		}
	}
	else
	{
		instance_destroy();
	}		
} 

if (projectileType == PROJECTILE_TYPE.LOB)
{
	lobStep = lobShot(self, 0.02, direction, xStart, yStart, targetDistance);//arcHeight, oval_height, oval_width);

	if (lobStep >= 1)
	{
		instance_create_depth(x,y,depth,obj_knockback);
		instance_destroy();
	}
	
	var currentDistanceX = abs(_self.x - xStart);
    var totalDistanceX   = abs(_outlineX - xStart);
    var _progress		 = min(1, currentDistanceX / totalDistanceX);
	
	// Calculate next position's progress
	var next_progress = min(1, (currentDistanceX + _spd) / totalDistanceX);
	
	var outlineX = xStart + oval_width * cos(radDirection);
	var outlineY = yStart - oval_height * sin(radDirection); // Note the minus sign to adjust for GameMaker's coordinate system
	
	// Calculate next position based on estimated next progress
	var nextX = lerp(_xStart, _outlineX, next_progress);
	var nextY = lerp(_yStart, _outlineY, next_progress) - sin(pi * next_progress) * _arcHeight * 2;

	// Calculate angle to next position
	var angleToNext = point_direction(_self.x, _self.y, nextX, nextY);

	// Update object's draw direction
	_self.drawDir = angleToNext;
	
	
	depth = -(bbox_bottom + 32 + (point_distance(x, y, x, yStart)));
}




