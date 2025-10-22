/// @description Summoner - Collision with obj_melee_parent

if (!other.isSwinging) exit;

// Check if already hit by this swing
if (ds_list_find_index(other.hit_enemies, id) != -1) exit;

ds_list_add(other.hit_enemies, id);

// Get damage from the weapon owner (player)
var base_damage = 0;
if (other.owner != noone && instance_exists(other.owner)) {
    base_damage = other.owner.attack;
}

// Apply melee damage (normal effectiveness)
var actual_damage = base_damage * melee_resistance;

//takeDamage(self, actual_damage, other.owner);
damage_sys.TakeDamage(actual_damage, other.owner)
hitFlashTimer = 5;

// Show damage number
spawn_damage_number(x, y - 32, actual_damage, c_white, false);

// Visual effect
repeat(8) {
    var p = instance_create_depth(x, y, depth - 1, obj_particle);
    p.direction = point_direction(other.x, other.y, x, y) + random_range(-30, 30);
    p.speed = random_range(2, 5);
}

show_debug_message("Summoner hit by melee for " + string(actual_damage));