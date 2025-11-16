

enum MOD_TAG {
    FIRE = 1 << 0,
    ICE = 1 << 1,
    PROJECTILE = 1 << 2,
    MELEE = 1 << 3,
    DEFENSIVE = 1 << 4,
    OFFENSIVE = 1 << 5,
    MOVEMENT = 1 << 6,
    CRITICAL = 1 << 7,
    // ... up to 32 tags with bit flags
}

// Triggers as enums
enum MOD_TRIGGER {
    ON_ATTACK,
    ON_HIT,
    ON_KILL,
    ON_DAMAGED,
    ON_DODGE,
    ON_ROOM_CLEAR,
    ON_PICKUP,
    PASSIVE, // Always active
	ON_RETURN
    // ...
}

enum MOD_ID
{
	FLAME_SHOT,
	OIL_SLICK,
	WIND_BOOST,
	TRIPLE_RHYTHM_FIRE,
	TRIPLE_RHYTHM_CHAOS,
	LUCKY_SHOT
}

enum PATTERN_TYPE {
	ALWAYS,
    EVERY_N,        // Every Nth action
    CHANCE,         // Random chance
    CONDITIONAL,    // When condition met (low health, etc)
    SEQUENCE,       // Follow a pattern [true, false, true, false]
    CHARGE,         // Build up charge
    COMBO,          // Within time window 
}

enum EFFECT_TYPE {
    SPAWN_PROJECTILE,
    MODIFY_PROJECTILE,
    APPLY_BUFF,
    CREATE_EXPLOSION,
    RANDOM_EFFECT,
	MODIFY_ATTACK
}




// Updated modifier definition
global.Modifiers = {};


// ------------------------------------------
// ELEMENTAL MODIFIERS
// ------------------------------------------

global.Modifiers.FireEnchantment = {
    name: "Fire Enchantment",
    description: "Projectiles burn enemies",
    triggers: [MOD_TRIGGER.ON_ATTACK],
    activation_chance: 100, // Always applies
    synergy_tags: [SYNERGY_TAG.FIRE],
    
    burn_duration: 180,
    burn_damage_per_tick: 2,
    
    action: function(_entity, _event) {
        if (_event.projectile != noone && instance_exists(_event.projectile)) {
            var stack = _event.stack_level ?? 1;
            _event.projectile.element_type = ELEMENT.FIRE;
            _event.projectile.burn_duration = GetStackedValue(burn_duration, stack);
            _event.projectile.burn_damage = GetStackedValue(burn_damage_per_tick, stack);
        }
    }
};

global.Modifiers.IceEnchantment = {
    name: "Ice Enchantment",
    description: "Projectiles freeze enemies",
    triggers: [MOD_TRIGGER.ON_ATTACK],
    activation_chance: 100,
    synergy_tags: [SYNERGY_TAG.ICE],
    
    slow_duration: 120,
    slow_amount: 0.5,
    
    action: function(_entity, _event) {
        if (_event.projectile != noone && instance_exists(_event.projectile)) {
            var stack = _event.stack_level ?? 1;
            _event.projectile.element_type = ELEMENT.ICE;
            _event.projectile.freeze_duration = GetStackedValue(slow_duration, stack);
            _event.projectile.slow_multiplier = slow_amount;
        }
    }
};

global.Modifiers.Souls2x = {
    name: "Double Souls",
    description: "Earn 2x souls from kills",
    triggers: [MOD_TRIGGER.ON_KILL],
    synergy_tags: [],
    
    soul_multiplier: 2.0,
    
    action: function(_entity, _event) {
        // This would need to be applied where you grant souls
        // You'll need to check for this modifier when awarding souls
    }
};

global.Modifiers.LightningEnchantment = {
    name: "Lightning Enchantment",
    description: "Projectiles shock enemies",
    triggers: [MOD_TRIGGER.ON_ATTACK],
    activation_chance: 100,
    synergy_tags: [SYNERGY_TAG.LIGHTNING],
    
    shock_duration: 90,
    
    action: function(_entity, _event) {
        if (_event.projectile != noone && instance_exists(_event.projectile)) {
            var stack = _event.stack_level ?? 1;
            _event.projectile.element_type = ELEMENT.LIGHTNING;
            _event.projectile.shock_duration = GetStackedValue(shock_duration, stack);
        }
    }
};

global.Modifiers.PoisonEnchantment = {
    name: "Poison Enchantment",
    description: "Projectiles poison enemies",
    triggers: [MOD_TRIGGER.ON_ATTACK],
    activation_chance: 100,
    synergy_tags: [SYNERGY_TAG.POISON],
    
    poison_duration: 240,
    poison_damage_per_tick: 1,
    
    action: function(_entity, _event) {
        if (_event.projectile != noone && instance_exists(_event.projectile)) {
            var stack = _event.stack_level ?? 1;
            _event.projectile.element_type = ELEMENT.POISON;
            _event.projectile.poison_duration = GetStackedValue(poison_duration, stack);
            _event.projectile.poison_damage = GetStackedValue(poison_damage_per_tick, stack);
        }
    }
};

// ------------------------------------------
// CHAIN/PROC MODIFIERS
// ------------------------------------------

global.Modifiers.ChainLightning = {
    name: "Chain Lightning",
    triggers: [MOD_TRIGGER.ON_HIT],
    
    // Configuration
    proc_chance: 0.25,      // 25% chance to trigger
    max_jumps: 4,           // Number of enemies it can jump to
    jump_range: 150,        // Range for finding next target
    damage_multiplier: 0.5, // Damage relative to attack damage
    damage_falloff: 0.75,   // 75% damage retained per jump
    synergy_tags: [SYNERGY_TAG.LIGHTNING, SYNERGY_TAG.CHAIN],
    
    action: function(_entity, _event) {
        var mod_template = global.Modifiers[$ _event.mod_instance.template_key];
        var stack = _event.stack_level ?? 1;
        
        // Roll for proc chance
        if (random(1) > mod_template.proc_chance) {
            return; // Didn't proc
        }
        
        // Find initial target
        var start_target = noone;
        
        // Check if we have a target from ON_HIT
        if (variable_struct_exists(_event, "target") && _event.target != noone) {
            start_target = _event.target;
        } else {
            // ON_ATTACK needs to find nearest enemy
            with (_entity) {
                var nearest_dist = 200;
                var check_x = _entity.x;
                var check_y = _entity.y;
                
                if (variable_struct_exists(_event, "attack_position_x")) {
                    check_x = _event.attack_position_x;
                    check_y = _event.attack_position_y;
                }
                
                with (obj_enemy) {
                    if (marked_for_death) continue;
                    var d = point_distance(x, y, check_x, check_y);
                    if (d < nearest_dist) {
                        nearest_dist = d;
                        start_target = id;
                    }
                }
            }
        }
        
        if (!instance_exists(start_target)) return;
        
        // Calculate stacked values
        var lightning_damage = (_event.damage ?? _entity.attack) * GetStackedValue(mod_template.damage_multiplier, stack);
        var jumps = floor(GetStackedValue(mod_template.max_jumps, stack));
        
        scr_chain_lightning(
            _entity,
            start_target,
            jumps,
            mod_template.jump_range,
            lightning_damage,
            mod_template.damage_falloff
        );
    }
};

global.Modifiers.Multishot = {
    name: "Multishot",
    description: "Fire 2 additional projectiles",
    triggers: [MOD_TRIGGER.ON_ATTACK],
    activation_chance: 100,
    synergy_tags: [SYNERGY_TAG.PIERCING_SHOT],
    
    bonus_projectiles: 2,
    
    action: function(_entity, _event) {
        var stack = _event.stack_level ?? 1;
        _event.projectile_count_bonus = floor(GetStackedValue(bonus_projectiles, stack));
    }
};

global.Modifiers.PiercingShot = {
    name: "Piercing Shot",
    description: "Projectiles pierce through enemies",
    triggers: [MOD_TRIGGER.ON_ATTACK],
    activation_chance: 100,
    synergy_tags: [SYNERGY_TAG.PIERCING_SHOT],
    
    pierce_count: 2,
    
    action: function(_entity, _event) {
        if (_event.projectile != noone && instance_exists(_event.projectile)) {
            var stack = _event.stack_level ?? 1;
            _event.projectile.piercing = true;
            _event.projectile.pierce_count = floor(GetStackedValue(pierce_count, stack));
        }
    }
};

// ------------------------------------------
// CORPSE EXPLOSION MODIFIERS
// ------------------------------------------

global.Modifiers.CorpseExplosion = {
    name: "Corpse Explosion",
    description: "25% chance for enemies to explode on death, firing projectiles in all directions",
    triggers: [MOD_TRIGGER.ON_KILL],
    synergy_tags: [SYNERGY_TAG.EXPLOSIVE],
    
    proc_chance: 0.25,           // 100% chance (or make it 0.5 for 50%)
    projectile_count: 8,
    projectile_type: obj_arrow,
    projectile_speed: 6,
    damage_multiplier: 0.3,
    explosion_delay: 10,
    
    action: function(_entity, _event) {
        var mod_template = global.Modifiers[$ _event.mod_instance.template_key];
        var stack = _event.stack_level ?? 1;
        
        // Roll for proc chance
        if (random(1) > mod_template.proc_chance) {
            return; // Didn't proc
        }
        
        var death_x = _event.enemy_x;
        var death_y = _event.enemy_y;
        
        with (_entity) {
            var explosion = instance_create_depth(death_x, death_y, depth - 10, obj_delayed_explosion);
            explosion.delay = mod_template.explosion_delay;
            explosion.owner = id;
            explosion.projectile_count = floor(GetStackedValue(mod_template.projectile_count, stack));
            explosion.projectile_type = mod_template.projectile_type;
            explosion.projectile_speed = mod_template.projectile_speed;
            var damage_mult = GetStackedValue(mod_template.damage_multiplier, stack);
            explosion.damage = (_event.damage ?? attack) * damage_mult;
            explosion.source_entity = id;
            explosion.from_corpse_explosion = true;
        }
    }
};
// ------------------------------------------
// STAT MODIFIERS (PASSIVE)
// ------------------------------------------

global.Modifiers.StrengthBoost = {
    name: "Strength",
    description: "+5 damage per stack",
    triggers: [MOD_TRIGGER.PASSIVE],
    activation_chance: 100,
    synergy_tags: [SYNERGY_TAG.STRENGTH],
    
    passive_stats: {
        damage_bonus: 5,
		damage_mult: 1.5,
    },
    
    action: function(_entity, _event) {
        // Stats applied via CalculateCachedStats
    }
};

global.Modifiers.SpeedBoost = {
    name: "Speed",
    description: "+0.5 movement speed per stack",
    triggers: [MOD_TRIGGER.PASSIVE],
    activation_chance: 100,
    synergy_tags: [SYNERGY_TAG.SPEED],
    
    passive_stats: {
        speed_bonus: 0.5,
		speed_mult: 1.2  // This needs to exist
    },
    
    action: function(_entity, _event) {
        // Stats applied via CalculateCachedStats
    }
};

global.Modifiers.GlassCannon = {
    name: "Glass Cannon",
    description: "+50% damage, -50% defense",
    triggers: [MOD_TRIGGER.PASSIVE],
    activation_chance: 100,
    synergy_tags: [SYNERGY_TAG.GLASS_CANNON, SYNERGY_TAG.STRENGTH],
    
    passive_stats: {
        damage_mult: 1.5,
        defense_mult: 0.5
    },
    
    action: function(_entity, _event) {
        // Stats applied via CalculateCachedStats
    }
};

global.Modifiers.Tank = {
    name: "Tank",
    description: "+50 max HP, -20% speed",
    triggers: [MOD_TRIGGER.PASSIVE],
    activation_chance: 100,
    synergy_tags: [SYNERGY_TAG.TANKY, SYNERGY_TAG.WEIGHT],
    
    passive_stats: {
        max_hp_bonus: 50,
        speed_mult: 0.8
    },
    
    action: function(_entity, _event) {
        // Stats applied via CalculateCachedStats
    }
};

global.Modifiers.CriticalStrike = {
    name: "Critical Strike",
    description: "15% chance for 2x damage",
    triggers: [MOD_TRIGGER.ON_HIT],
    proc_chance: 0.15, // 15% chance
    synergy_tags: [SYNERGY_TAG.CRITICAL],
    
    crit_multiplier: 2.0,
    
    action: function(_entity, _event) {
        var mod_template = global.Modifiers[$ _event.mod_instance.template_key];
        var stack = _event.stack_level ?? 1;
        
        // Roll for crit
        if (random(1) > mod_template.proc_chance) return;
        
        var crit_mult = GetStackedValue(mod_template.crit_multiplier, stack);
        
        // Modify the damage in the event (this will be applied retroactively)
        _event.damage *= crit_mult;
        
        // Visual feedback at hit location
        if (variable_struct_exists(_event, "target") && instance_exists(_event.target)) {
            var crit_text = instance_create_depth(
                _event.target.x, _event.target.y - 20,
                -9999, obj_floating_text
            );
            crit_text.text = "CRIT!";
            crit_text.color = c_yellow;
            crit_text.scale = 1.5;
        }
    }
};

global.Modifiers.Lifesteal = {
    name: "Lifesteal",
    description: "Heal 10% of damage dealt",
    triggers: [MOD_TRIGGER.ON_HIT],
    synergy_tags: [SYNERGY_TAG.LIFESTEAL],
    
    lifesteal_percent: 0.10,
    
    action: function(_entity, _event) {
        var stack = _event.stack_level ?? 1;
        var heal_amount = _event.damage * GetStackedValue(lifesteal_percent, stack);
        
        if (instance_exists(_entity)) {
            // Use the component system
                _entity.damage_sys.Heal(heal_amount);
                
                // Visual feedback
                spawn_damage_number(_entity.x, _entity.y - 32, floor(heal_amount), c_lime, false);
        }
    }
};

// ------------------------------------------
// REGENERATION
// ------------------------------------------

global.Modifiers.Regeneration = {
    name: "Regeneration",
    description: "Heal 1 HP every 3 seconds",
    triggers: [MOD_TRIGGER.PASSIVE],
    activation_chance: 100,
    synergy_tags: [SYNERGY_TAG.REGENERATION],
    
    heal_per_tick: 1,
    tick_rate: 180, // 3 seconds at 60 FPS
    regen_timer: 0,
	
    instance_data: {
        regen_timer: 0
    },
    
    action: function(_entity, _event) {
    }
};


// SYNERGY TAG REFERENCE

/*
SYNERGY_TAG.VAMPIRE      - Vampire class tag
SYNERGY_TAG.HOLY         - Holy Mage class tag
SYNERGY_TAG.BRUTAL       - Warrior class tag
SYNERGY_TAG.ATHLETIC     - Baseball Player class tag
SYNERGY_TAG.ROGUE        - Rogue class tag
SYNERGY_TAG.MAGE         - Mage class tag

SYNERGY_TAG.MELEE        - Melee weapon type
SYNERGY_TAG.RANGED       - Ranged weapon type
SYNERGY_TAG.EXPLOSIVE    - Explosive weapons (grenades, bombs)
SYNERGY_TAG.THROWABLE    - Throwable items
SYNERGY_TAG.PIERCING     - Piercing weapons
SYNERGY_TAG.BLUNT        - Blunt weapons

SYNERGY_TAG.FIRE         - Fire element
SYNERGY_TAG.ICE          - Ice element
SYNERGY_TAG.LIGHTNING    - Lightning element
SYNERGY_TAG.POISON       - Poison element

SYNERGY_TAG.LIFESTEAL    - Lifesteal behavior
SYNERGY_TAG.CHAIN        - Chain attacks
SYNERGY_TAG.SPLASH       - Area damage
SYNERGY_TAG.BOUNCING     - Bouncing projectiles
SYNERGY_TAG.HOMING       - Homing projectiles
SYNERGY_TAG.PIERCING_SHOT - Piercing projectiles

SYNERGY_TAG.STRENGTH     - Damage boost
SYNERGY_TAG.SPEED        - Speed boost
SYNERGY_TAG.WEIGHT       - Weight/knockback
SYNERGY_TAG.CRITICAL     - Critical hits
SYNERGY_TAG.REGENERATION - Health regen
SYNERGY_TAG.GLASS_CANNON - High risk/reward
SYNERGY_TAG.TANKY        - High defense
*/
function GetModifierKeyFromNodeId(_node_id) {
    var mapping = {
        "pregame_souls_2x": "Souls2x",
        "pregame_stat_hp": "StatHP",
        "pregame_stat_damage": "StatDamage",
        "pregame_stat_speed": "StatSpeed",
        "pregame_bouncy": "Bouncy",
        "pregame_meteor": "MeteorStrike",
        "pregame_fire": "FireEnchantment",
        "pregame_ice": "IceEnchantment",
        "pregame_lightning": "LightningEnchantment",
        "pregame_poison": "PoisonEnchantment",
        "pregame_chain_lightning": "ChainLightning",
        "pregame_multishot": "Multishot",
        "pregame_piercing": "PiercingShot",
        "pregame_corpse_explosion": "CorpseExplosion",
        "pregame_strength": "StrengthBoost",
        "pregame_speed": "SpeedBoost",
        "pregame_glass_cannon": "GlassCannon",
        "pregame_tank": "Tank",
        "pregame_crit": "CriticalStrike",
        "pregame_lifesteal": "Lifesteal",
        "pregame_regen": "Regeneration",
    };
    
    if (variable_struct_exists(mapping, _node_id)) {
        return mapping[$ _node_id];
    }
    
    return undefined;
}