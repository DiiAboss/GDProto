/// @description Summoner - Collision with obj_projectile
// Apply ranged resistance
if (other.owner != noone && other.owner == obj_player) {
    var actual_damage = other.damage * ranged_resistance;
    
    takeDamage(self, actual_damage, other);
    hitFlashTimer = 5;
    
    // Show reduced damage number in gray to indicate resistance
    spawn_damage_number(x, y - 32, actual_damage, c_gray, false);
    
    show_debug_message("Summoner hit by projectile for " + string(actual_damage) + " (resisted)");
}

instance_destroy(other);