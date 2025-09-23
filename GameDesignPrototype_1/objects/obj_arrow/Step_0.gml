/// @description Insert description here
// You can write your code in this editor
direction = myDir;



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