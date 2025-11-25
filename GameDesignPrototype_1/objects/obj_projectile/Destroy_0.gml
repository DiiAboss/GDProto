/// @description Insert description here
// You can write your code in this editor
/// @desc Projectile Destroy - Spawn Elemental Effects

// Fire effect
if (has_fire_effect) {
    var fire_effect = instance_create_depth(x, y, depth, obj_fire_effect);
    fire_effect.burn_duration = fire_burn_duration;
    fire_effect.burn_damage = fire_burn_damage;
    fire_effect.owner = owner;
}

// Ice effect
if (has_ice_effect) {
    var ice_effect = instance_create_depth(x, y, depth, obj_ice_effect);
    ice_effect.slow_duration = ice_slow_duration;
    ice_effect.slow_amount = ice_slow_amount;
    ice_effect.owner = owner;
}

// Lightning effect
if (has_lightning_effect) {
    var lightning_effect = instance_create_depth(x, y, depth, obj_lightning_effect);
    lightning_effect.shock_duration = shock_duration;
    lightning_effect.owner = owner;
}

// Poison effect
if (has_poison_effect) {
    var poison_effect = instance_create_depth(x, y, depth, obj_poison_effect);
    poison_effect.poison_duration = poison_duration;
    poison_effect.poison_damage = poison_damage;
    poison_effect.owner = owner;
}