if (!other || other.hp <= 0) exit;

// who owns this attack
other.last_hit_by = owner;
other.last_damage_taken = damage;

// apply damage (call your existing damage function)
other.damage_sys.TakeDamage(damage, owner);

var hit_event = CreateHitEvent(self, other, damage, AttackType.RANGED);

// Trigger modifiers on the owner
if (owner != noone) {
    TriggerModifiers(owner, MOD_TRIGGER.ON_HIT, hit_event);
}

// optionally start returning immediately
//if (!returning) returning = true;