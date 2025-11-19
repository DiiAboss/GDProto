/// @description Insert description here
// You can write your code in this editor
 var hit = other; // Assuming you have obj_enemy
		
if (hit != noone) {
	hit.lastKnockedBy = owner; // owner = player who swung sword

	// Deal damage
	hit.damage_sys.TakeDamage(damage, owner);
	//takeDamage(hit, damage, owner);
	// Apply knockback using custom knockback variables
	if (hit.knockback.cooldown <= 0) {
		var knockbackDir = point_direction(owner.x, owner.y, hit.x, hit.y);
        
		// Set the enemy's knockback velocity
		hit.knockback.Apply(knockbackDir, force);
	}
}