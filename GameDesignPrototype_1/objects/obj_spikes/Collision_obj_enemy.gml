/// @description

// Check if this enemy is already in hit list
var canHit = true;
for (var i = 0; i < ds_list_size(hitList); i++) {
	if (hitList[| i][0] == other) {
		canHit = false;
		break;
	}
}

if (canHit && other != noone) {
var impactSpeed = point_distance(0, 0, other.knockback.x_velocity, other.knockback.y_velocity);
var damage = baseDamage + (impactSpeed * velocityDamageMultiplier);
damage = min(damage, maxDamage);

DealDamage(other, round(damage), self, 0);


// Stop knockback and bounce
other.knockback.x_velocity = 0;
other.knockback.y_velocity = 0;
var bounceDir = point_direction(x, y, other.x, other.y);
other.x += lengthdir_x(5, bounceDir);
other.y += lengthdir_y(5, bounceDir);

ds_list_add(hitList, [other, hitCooldown]);
bloodTimer = 20;
shake = min(impactSpeed * 0.5, 5);
}
