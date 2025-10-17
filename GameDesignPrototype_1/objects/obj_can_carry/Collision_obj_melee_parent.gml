/// @description
/// @description obj_can_carry - Collision with obj_melee_parent

// Safety checks
if (!can_be_knocked || is_being_carried || hit_cooldown > 0) {
    exit;
}

// Check if weapon is swinging
if (!other.isSwinging) {
    exit;
}

// Check if already hit by this swing
if (ds_list_find_index(other.hit_enemies, id) != -1) {
    exit;
}

// Add to hit list
ds_list_add(other.hit_enemies, id);

// Calculate knockback
var kb_dir = point_direction(other.owner.x, other.owner.y, x, y);
var kb_force = other.knockbackForce / hit_resistance;

// Apply knockback
knockback.Apply(kb_dir, kb_force);
isProjectile = true;

// Visual effects
hitFlashTimer = 5;
shake = 3;
hit_cooldown = hit_cooldown_max;
last_hit_by = other.owner;

// Particles
repeat(5) {
    var p = instance_create_depth(x, y, depth - 1, obj_particle);
    p.direction = kb_dir + random_range(-30, 30);
    p.speed = random_range(2, 5);
}

// Custom callback
if (variable_instance_exists(self, "OnMeleeHit")) {
    OnMeleeHit(other.owner, other, kb_dir);
}

show_debug_message("Carriable object hit by " + object_get_name(other.object_index));