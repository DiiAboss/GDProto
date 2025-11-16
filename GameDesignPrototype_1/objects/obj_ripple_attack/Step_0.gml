/// @description Insert description here
// You can write your code in this editor
// oRipple Step Event
outer_radius += expansion_rate * myGameSpeed;

// Destroy the ripple if it exceeds the maximum radius
if (outer_radius >= max_radius) {
    instance_destroy();
}



if instance_exists(target)
{
	// Check for collision with the player within the ring
	var inner_radius = max(0, outer_radius - ring_thickness);
	if (collision_circle(x, y, outer_radius, target, false, true) && !collision_circle(x, y, inner_radius, target, false, true)) {
	    // Apply damage to the player
	
			//if myState != STATE.DASHING
			//{
			//    flashing = true;
			//    flashTimer = 0; // Reset timer when starting the flash
			//	with (oControl)
			//	{
			//		take_damage();
			//	}
			//}
			takeDamage(target, 10, self);
		
	}
	if (collision_circle(x, y, outer_radius, obj_enemy, false, true) && !collision_circle(x, y, inner_radius, obj_enemy, false, true)) {
	    // Apply damage to the player
	
			//if myState != STATE.DASHING
			//{
			//    flashing = true;
			//    flashTimer = 0; // Reset timer when starting the flash
			//	with (oControl)
			//	{
			//		take_damage();
			//	}
			//}
			var _enemy = (collision_circle(x, y, outer_radius, obj_enemy, false, true));
			takeDamage(_enemy, 10, self);
		
	}
}