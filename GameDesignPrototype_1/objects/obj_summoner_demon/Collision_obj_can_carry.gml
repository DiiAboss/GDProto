/// @description Summoner - Collision with thrown objects

// Only damage if it's a projectile (thrown)
if (!other.is_projectile) exit;

// Apply extra damage from thrown objects
var actual_damage = other.damage * thrown_resistance;

//takeDamage(self, actual_damage, other);
damage_sys.TakeDamage(actual_damage, other.owner)
hitFlashTimer = 5;

// Show CRIT damage for thrown objects!
spawn_damage_number(x, y - 32, actual_damage, c_yellow, true);

// Big visual impact
repeat(12) {
    var p = instance_create_depth(x, y, depth - 1, obj_particle);
    p.direction = random(360);
    p.speed = random_range(3, 7);
    p.image_blend = c_yellow;
}

show_debug_message("Summoner SMASHED by thrown object for " + string(actual_damage) + "!");

// Destroy the thrown object
if (other.destroy_on_impact) {
    instance_destroy(other);
}