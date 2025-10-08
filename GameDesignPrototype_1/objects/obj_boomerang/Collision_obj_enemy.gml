if (!other || other.hp <= 0) exit;

// who owns this attack
other.last_hit_by = owner;
other.last_damage_taken = damage;

// apply damage (call your existing damage function)
takeDamage(other, damage);

// Build a normalized hit event
var hit_event = {
    attack_type: AttackType.RANGED,
    attack_direction: point_direction(x, y, other.x, other.y),
    attack_position_x: x,
    attack_position_y: y,
    damage: damage,
    projectile: id,
    weapon: (variable_instance_exists(owner, "weaponCurrent") ? owner.weaponCurrent : noone),
    target: other
};

// Trigger modifiers on the owner
if (owner != noone) {
    TriggerModifiers(owner, MOD_TRIGGER.ON_HIT, hit_event);
}

// optionally start returning immediately
//if (!returning) returning = true;