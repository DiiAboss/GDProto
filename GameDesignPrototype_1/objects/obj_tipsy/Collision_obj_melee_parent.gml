/// @description Detect melee hits

if (other.isSwinging && hitFlashTimer <= 0) {
    // Take damage
    damage_sys.TakeDamage(other.attack, other.owner, ELEMENT.PHYSICAL);
    obj_player.knockback.Apply(point_direction(x, y, obj_player.x, obj_player.y), 16);
	
    // Trigger state change if not in boss mode
    if (state < TIPSY_STATE.ENEMY) {
        OnMeleeHit();
        other.isSwinging = false;
    }
}