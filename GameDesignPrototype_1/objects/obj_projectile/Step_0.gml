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

if (projectileType == PROJECTILE_TYPE.LOB) {
    lobStep = lobShot(self, 0.02, direction, xStart, yStart, targetDistance);
    
    if (lobStep >= 1) {
        instance_create_depth(x, y, depth, obj_knockback);
        instance_destroy();
    }
    
    // Use lengthdir functions which handle degrees and GML's coordinate system correctly
    targetX = xStart + lengthdir_x(targetDistance, direction);
    targetY = yStart + lengthdir_y(targetDistance, direction);
    groundShadowY = yStart;
    
    // Calculate arc for next frame (for rotation)
    var arcHeight = targetDistance * 0.25;
    var next_progress = min(1, lobStep + 0.02);
    
    var nextX = lerp(xStart, targetX, next_progress);
    var nextY = lerp(yStart, targetY, next_progress) - sin(pi * next_progress) * arcHeight * 2;
    
    drawDir = point_direction(x, y, nextX, nextY);
    depth = -(bbox_bottom + 32 + (point_distance(x, y, x, yStart)));
}




