/// @description
if (life > 0)
{
	life--;
}
else
{
	instance_destroy();
}



 var hit = instance_place(x, y, obj_enemy); // Assuming you have obj_enemy
		
if (hit != noone) {
	hit.lastKnockedBy = owner; // owner = player who swung sword

	// Calculate damage with combo bonus
	var baseDamage = 20;
	var damage = baseDamage;
	
	// Deal damage
	hit.damage_sys.TakeDamage(damage, owner);
	//takeDamage(hit, damage, owner);
	// Apply knockback using custom knockback variables
	if (hit.knockback.cooldown <= 0) {
		var knockbackDir = point_direction(owner.x, owner.y, hit.x, hit.y);
		var knockbackForce = 5; // Stronger knockback with combo
        
		// Set the enemy's knockback velocity
		hit.knockback.Apply(knockbackDir, knockbackForce);
	}
}