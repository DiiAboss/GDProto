if (!other || other.hp <= 0) exit;

other.last_hit_by = owner;
other.last_damage_taken = damage;

DealDamage(other, damage, owner);

var hit_event = CreateHitEvent(self, other, damage, AttackType.RANGED);
if (owner != noone) {
    TriggerModifiers(owner, MOD_TRIGGER.ON_HIT, hit_event);
}