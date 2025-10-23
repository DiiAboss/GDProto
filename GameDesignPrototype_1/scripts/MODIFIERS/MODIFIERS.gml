

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


// Fixed TripleRhythmFire modifier
global.Modifiers.TripleRhythmFire = {
    name: "Rhythmic Flames",
    triggers: [MOD_TRIGGER.ON_ATTACK],
    
    // Store configuration at top level
    trigger_on: 3,
    projectile: obj_fireball,
	
    // NEW: Tags this modifier adds
    synergy_tags: [SYNERGY_TAG.FIRE],
	
    action: function(_entity, _event) {
        var mod_instance = _event.mod_instance;
        var mod_template = global.Modifiers[$ mod_instance.template_key];
        
        // Initialize counter if it doesn't exist
        if (!variable_struct_exists(mod_instance, "counter")) {
            mod_instance.counter = 0;
        }
        
        // Increment and check
        mod_instance.counter++;
        
        // Use template's trigger_on value
        if (mod_instance.counter >= mod_template.trigger_on) {
            mod_instance.counter = 0;
            
            // Execute effect
            with (_entity) {
                // Check if the projectile object exists
                if (object_exists(mod_template.projectile)) {
                    var proj = instance_create_depth(
                        _event.attack_position_x, 
                        _event.attack_position_y, 
                        depth - 1, 
                        mod_template.projectile
                    );
                    proj.direction = _event.attack_direction;
                    proj.speed = 8;
                    
                    if (variable_instance_exists(proj, "damage")) {
                        proj.damage = (_event.damage ?? 10) * 0.5;
                    }
                    if (variable_instance_exists(proj, "owner")) {
                        proj.owner = id;
                    }
                }
            }
        }
    }
};

// Fixed DoubleLightning modifier
global.Modifiers.DoubleLightning = {
    name: "Lightning Strike",
    triggers: [MOD_TRIGGER.ON_ATTACK],
    
    trigger_on: 2,  // Every 2nd attack
    
	    // NEW: Tags this modifier adds
    synergy_tags: [SYNERGY_TAG.LIGHTNING],
	
    action: function(_entity, _event) {
        var mod_instance = _event.mod_instance;
        var mod_template = global.Modifiers[$ mod_instance.template_key];
        
        // Initialize counter if it doesn't exist
        if (!variable_struct_exists(mod_instance, "counter")) {
            mod_instance.counter = 0;
        }
        
        // Increment and check
        mod_instance.counter++;
        
        if (mod_instance.counter >= mod_template.trigger_on) {
            mod_instance.counter = 0;
            
            // Execute effect
            with (_entity) {
                // Different effect based on attack type
                if (_event.attack_type == AttackType.MELEE) {
                    // Create lightning strike at sword position
                    if (object_exists(obj_lightning_strike)) {
                        var lightning = instance_create_depth(
                            _event.attack_position_x,
                            _event.attack_position_y,
                            depth - 1,
                            obj_lightning_strike
                        );
                        lightning.damage = _event.damage;
                        lightning.owner = id;
                    }
                } else if (_event.attack_type == AttackType.CANNON || _event.attack_type == AttackType.RANGED) {
                    // Create chain lightning from player
                    if (object_exists(obj_chain_lightning)) {
                        var chain = instance_create_depth(
                            x, y, depth - 1,
                            obj_chain_lightning
                        );
                        chain.damage = (_event.damage ?? 10) * 0.75;
                        chain.owner = id;
                        chain.max_bounces = 3;
                    }
                }
            }
        }
    }
};

global.Modifiers.SpreadFire = {
    name: "Spread Fire",
    triggers: [MOD_TRIGGER.ON_ATTACK],
    
    extra_projectiles: 4,
    spread_angle: 15,
    melee_arc_bonus: 30,
    
	// NEW: Tags this modifier adds
    synergy_tags: [SYNERGY_TAG.SPLASH],
	
    action: function(_entity, _event) {
        var mod_template = global.Modifiers[$ _event.mod_instance.template_key];
        
        // FIX: Check if field exists before using it
        var attack_type = AttackType.UNKNOWN;
        if (variable_struct_exists(_event, "attack_type")) {
            attack_type = _event.attack_type;
        }
        
        // MELEE: Increase swing arc
        if (attack_type == AttackType.MELEE) {
            with (_entity) {
                if (instance_exists(melee_weapon)) {
                    if (!variable_instance_exists(melee_weapon, "swing_arc")) {
                        melee_weapon.swing_arc = 90;
                    }
                    melee_weapon.swing_arc += mod_template.melee_arc_bonus;
                }
            }
        } 
        // RANGED: Add extra projectiles
        else if (attack_type == AttackType.RANGED || attack_type == AttackType.CANNON) {
            _event.projectile_count_bonus += mod_template.extra_projectiles;
        }
    }
};

// Fixed Chain Lightning Modifier
global.Modifiers.ChainLightning = {
    name: "Chain Lightning",
    triggers: [MOD_TRIGGER.ON_ATTACK, MOD_TRIGGER.ON_HIT],
    
    // Configuration
    proc_chance: 0.25,      // 25% chance to trigger
    max_jumps: 4,           // Number of enemies it can jump to
    jump_range: 150,        // Range for finding next target
    damage_multiplier: 0.5, // Damage relative to attack damage
    damage_falloff: 0.75,   // 75% damage retained per jump
    // NEW: Tags this modifier adds
    synergy_tags: [SYNERGY_TAG.LIGHTNING],
    action: function(_entity, _event) {
        var mod_template = global.Modifiers[$ _event.mod_instance.template_key];
        
        // Roll for proc chance
        if (random(1) > mod_template.proc_chance) {
            return; // Didn't proc
        }
        
        // Find initial target
        var start_target = noone;
        
        // Check if we have a target from ON_HIT
        if (variable_struct_exists(_event, "target") && _event.target != noone) {
            // ON_HIT provides the target directly
            start_target = _event.target;
        } else {
            // ON_ATTACK needs to find nearest enemy
            with (_entity) {
                var nearest_dist = 200; // Max range to find initial target
                
                // ==========================================
                // FIXED: Safe field access with fallbacks
                // ==========================================
                var check_x = _entity.x; // Default to entity position
                var check_y = _entity.y;
                
                // Try multiple field name variations
                if (variable_struct_exists(_event, "attack_position_x")) {
                    check_x = _event.attack_position_x;
                    check_y = _event.attack_position_y;
                } else if (variable_struct_exists(_event, "hit_x")) {
                    check_x = _event.hit_x;
                    check_y = _event.hit_y;
                } else if (variable_struct_exists(_event, "x")) {
                    check_x = _event.x;
                    check_y = _event.y;
                }
                
                with (obj_enemy) {
                    if (variable_instance_exists(id, "marked_for_death") && marked_for_death) {
                        continue; // Skip dead enemies
                    }
                    
                    var dist = point_distance(x, y, check_x, check_y);
                    if (dist < nearest_dist) {
                        nearest_dist = dist;
                        start_target = id;
                    }
                }
            }
        }
        
        // If we found a target, trigger chain lightning
        if (start_target != noone && instance_exists(start_target)) {
            // Skip if target is already dead
            if (variable_instance_exists(start_target, "marked_for_death") && 
                start_target.marked_for_death) {
                return;
            }
            
            var lightning_damage = (_event.damage ?? _entity.attack) * mod_template.damage_multiplier;
            
            // Call your chain lightning script
            scr_chain_lightning(
                _entity,                        // source
                start_target,                   // first target
                mod_template.max_jumps,         // max jumps
                mod_template.jump_range,        // range
                lightning_damage,               // base damage
                mod_template.damage_falloff     // falloff
            );
        }
    }
};

// Alternative: Lightning that builds up charges then releases
global.Modifiers.StaticCharge = {
    name: "Static Charge",
    triggers: [MOD_TRIGGER.ON_ATTACK],
        // NEW: Tags this modifier adds
    synergy_tags: [SYNERGY_TAG.LIGHTNING],
    // Configuration
    charges_needed: 5,      // Attacks to build up
    proc_on_full: true,     // Auto-proc when charged
    
    action: function(_entity, _event) {
        var mod_instance = _event.mod_instance;
        var mod_template = global.Modifiers[$ mod_instance.template_key];
        
        // Initialize charge counter
        if (!variable_struct_exists(mod_instance, "charges")) {
            mod_instance.charges = 0;
        }
        
        // Build charge
        mod_instance.charges++;
        
        // Visual indicator of charge level
        with (_entity) {
            // Create sparks or change sprite blend based on charge
            var charge_ratio = mod_instance.charges / mod_template.charges_needed;
            if (charge_ratio > 0.5) {
                // Start showing electric effects
                if (random(1) < charge_ratio) {
                    //var spark = instance_create_depth(
                        //x + random_range(-16, 16),
                        //y + random_range(-16, 16),
                        //depth - 1,
                        //obj_spark_effect
                    //);
                }
            }
        }
        
        // Check if fully charged
        if (mod_instance.charges >= mod_template.charges_needed) {
            mod_instance.charges = 0;
            
            // Find all enemies in range and chain lightning them
            var targets = [];
            with (obj_enemy) {
                if (point_distance(x, y, _entity.x, _entity.y) < 200) {
                    array_push(targets, id);
                }
            }
            
            // Lightning strike on multiple targets
            if (array_length(targets) > 0) {
                // Pick random target as start
                var start_idx = irandom(array_length(targets) - 1);
                var start_target = targets[start_idx];
                
                scr_chain_lightning(
                    _entity,
                    start_target,
                    6,              // More jumps when fully charged
                    200,            // Longer range
                    _event.damage * 2,  // Double damage
                    0.8             // Less falloff
                );
                
                //// Big visual effect
                //with (_entity) {
                    //// Create lightning nova effect
                    //var nova = instance_create_depth(x, y, depth - 1, obj_lightning_nova);
                    //nova.owner = id;
                //}
            }
        }
    }
};

// Melee-specific lightning modifier
global.Modifiers.ThunderStrike = {
    name: "Thunder Strike",
    triggers: [MOD_TRIGGER.ON_ATTACK],
        // NEW: Tags this modifier adds
    synergy_tags: [SYNERGY_TAG.LIGHTNING],
    proc_chance: 0.3,
    
    action: function(_entity, _event) {
        var mod_template = global.Modifiers[$ _event.mod_instance.template_key];
        
        // Only works on melee attacks
        if (_event.attack_type != AttackType.MELEE) return;
        
        // Roll for proc
        if (random(1) > mod_template.proc_chance) return;
        
        // Create lightning at sword impact point
        with (_entity) {
            if (instance_exists(melee_weapon)) {
                // Find enemies hit by sword
                var hit_list = ds_list_create();
                var hit_count = instance_place_list(
                    melee_weapon.x, 
                    melee_weapon.y, 
                    obj_enemy, 
                    hit_list,
					true
                );
                
                if (hit_count > 0) {
                    // Start chain from first enemy hit
                    var first_target = hit_list[| 0];
                    
                    scr_chain_lightning(
                        id,
                        first_target,
                        3,
                        120,
                        melee_weapon.attack * 0.75,
                        0.6
                    );
                }
                
                ds_list_destroy(hit_list);
            }
        }
    }
};

// Death Fireworks Modifier - FIXED VERSION
global.Modifiers.DeathFireworks = {
    name: "Corpse Explosion",
    triggers: [MOD_TRIGGER.ON_KILL],
        // NEW: Tags this modifier adds
    synergy_tags: [SYNERGY_TAG.EXPLOSIVE],
    // Configuration
    projectile_count: 8,
    projectile_type: obj_arrow,
    projectile_speed: 6,
    damage_multiplier: 0.3,
    explosion_delay: 1,
    
    // CRITICAL: Prevent chain reactions
    can_trigger_on_modifier_kills: false, // Don't trigger on explosion kills
    max_explosions_per_frame: 10,         // Frame-based limiter
    
    action: function(_entity, _event) {
        var mod_template = global.Modifiers[$ _event.mod_instance.template_key];
        
        // ==========================================
        // FAILSAFE 1: Check if kill was from this modifier
        // ==========================================
        if (_event.kill_source == "corpse_explosion" || 
            _event.kill_source == "explosion") {
            // Don't create explosions from explosion kills (AOE or projectiles)
            return;
        }
        
        // ==========================================
        // FAILSAFE 2: Check enemy hasn't already exploded
        // ==========================================
        // Get the actual enemy instance if it still exists
        var enemy_inst = noone;
        with (obj_enemy) {
            if (x == _event.enemy_x && y == _event.enemy_y && marked_for_death) {
                enemy_inst = id;
                break;
            }
        }
        
        // If we found the enemy, check if already processed
        if (instance_exists(enemy_inst)) {
            if (variable_instance_exists(enemy_inst, "has_exploded")) {
                if (enemy_inst.has_exploded) {
                    return; // Already exploded, don't do it again
                }
            }
            enemy_inst.has_exploded = true; // Mark as exploded
        }
        
        // ==========================================
        // FAILSAFE 3: Global frame limiter
        // ==========================================
        if (!variable_global_exists("explosion_count_this_frame")) {
            global.explosion_count_this_frame = 0;
            global.explosion_frame_reset = current_time;
        }
        
        // Reset counter if new frame
        if (current_time != global.explosion_frame_reset) {
            global.explosion_count_this_frame = 0;
            global.explosion_frame_reset = current_time;
        }
        
        // Check if we've hit the limit
        if (global.explosion_count_this_frame >= mod_template.max_explosions_per_frame) {
            return; // Too many explosions this frame, skip
        }
        
        global.explosion_count_this_frame++;
        
        // ==========================================
        // FAILSAFE 4: Total instance check
        // ==========================================
        var total_explosions = instance_number(obj_delayed_explosion);
        var total_projectiles = instance_number(obj_projectile);
        
        if (total_explosions > 20 || total_projectiles > 100) {
            return; // System overloaded, abort
        }
        
        // ==========================================
        // CREATE EXPLOSION
        // ==========================================
        var death_x = _event.enemy_x;
        var death_y = _event.enemy_y;
        
        with (_entity) {
            var explosion = instance_create_depth(death_x, death_y, depth - 10, obj_delayed_explosion);
            explosion.delay = mod_template.explosion_delay;
            explosion.owner = id;
            explosion.projectile_count = mod_template.projectile_count;
            explosion.projectile_type = mod_template.projectile_type;
            explosion.projectile_speed = mod_template.projectile_speed;
            explosion.damage = (_event.damage ?? attack) * mod_template.damage_multiplier;
            explosion.source_entity = id;
            
            // CRITICAL: Mark explosion projectiles
            explosion.from_corpse_explosion = true;
        }
    }
};
// Poison Death - Different projectile type
global.Modifiers.PoisonCorpse = {
    name: "Toxic Explosion",
    triggers: [MOD_TRIGGER.ON_KILL],
        // NEW: Tags this modifier adds
    synergy_tags: [SYNERGY_TAG.EXPLOSIVE, SYNERGY_TAG.POISON],
    projectile_count: 6,
    projectile_type: obj_poison_cloud,  // Different projectile
    projectile_speed: 3,
    damage_multiplier: 0.2,
    explosion_delay: 10,
    
    action: function(_entity, _event) {
        var mod_template = global.Modifiers[$ _event.mod_instance.template_key];
        
        var death_x = _event.enemy_x;
        var death_y = _event.enemy_y;
        
        with (_entity) {
            var explosion = instance_create_depth(death_x, death_y, depth - 10, obj_delayed_explosion);
            explosion.delay = mod_template.explosion_delay;
            explosion.owner = id;
            explosion.projectile_count = mod_template.projectile_count;
            explosion.projectile_type = mod_template.projectile_type;
            explosion.projectile_speed = mod_template.projectile_speed;
            explosion.damage = (_event.damage ?? attack) * mod_template.damage_multiplier;
            explosion.source_entity = id;
            
            // Poison-specific: create lingering cloud
            explosion.create_cloud = true;
        }
    }
};

// Chain Reaction - Kills from explosions can trigger more explosions!
global.Modifiers.ChainReaction = {
    name: "Chain Reaction",
    triggers: [MOD_TRIGGER.ON_KILL],
        // NEW: Tags this modifier adds
    synergy_tags: [SYNERGY_TAG.EXPLOSIVE, SYNERGY_TAG.CHAIN],
    proc_chance: 0.5,  // 50% chance for chain reaction
    
    action: function(_entity, _event) {
        var mod_template = global.Modifiers[$ _event.mod_instance.template_key];
        
        // Only chain if this kill was from an explosion
        if (variable_struct_exists(_event, "kill_source") && _event.kill_source == "explosion") {
            if (random(1) < mod_template.proc_chance) {
                // Trigger another explosion
                var death_x = _event.enemy_x;
                var death_y = _event.enemy_y;
                
                //with (_entity) {
                    //var explosion = instance_create_depth(death_x, death_y, depth - 10, obj_instant_explosion);
                    //explosion.damage = _event.damage * 0.75;  // Slightly less damage
                    //explosion.radius = 100;
                    //explosion.owner = id;
                    //explosion.source_entity = id;
                    //
                    //// Visual effect
                    //repeat(20) {
                        //var spark = instance_create_depth(
                            //death_x + random_range(-20, 20),
                            //death_y + random_range(-20, 20),
                            //depth - 15,
                            //obj_spark
                        //);
                        //spark.direction = random(360);
                        //spark.speed = random_range(2, 8);
                    //}
                //}
            }
        }
    }
};

// MultiShot adds to projectile count stat
global.Modifiers.MultiShot = {
    name: "Multi Shot",
    triggers: [MOD_TRIGGER.ON_ATTACK],
    extra_projectiles: 1,
        // NEW: Tags this modifier adds
    synergy_tags: [SYNERGY_TAG.CHAIN],
    action: function(_entity, _event) {
        if (_event.attack_type != AttackType.RANGED && _event.attack_type != AttackType.CANNON) return;
        
        // Only add to bonus count, don't create projectiles
        _event.projectile_count_bonus += 1;
    }
};



global.Modifiers.BurstFire = {
    name: "Burst Fire",
    triggers: [MOD_TRIGGER.ON_ATTACK],
            // NEW: Tags this modifier adds
    synergy_tags: [SYNERGY_TAG.CHAIN],
    burst_count: 3,     // Shots in burst
    burst_delay: 5,     // Frames between shots
    
    action: function(_entity, _event) {
        var mod_instance = _event.mod_instance;
        var mod_template = global.Modifiers[$ mod_instance.template_key];
        
        // Only works on ranged
        if (_event.attack_type != AttackType.RANGED && _event.attack_type != AttackType.CANNON) return;
        
        // Initialize burst state
        if (!variable_struct_exists(mod_instance, "burst_shots_remaining")) {
            mod_instance.burst_shots_remaining = 0;
            mod_instance.burst_timer = 0;
        }
        
        // Start a new burst
        if (mod_instance.burst_shots_remaining == 0) {
            mod_instance.burst_shots_remaining = mod_template.burst_count - 1; // -1 because original shot already fired
            mod_instance.burst_timer = mod_template.burst_delay;
        }
    }
};

// Flat attack boost
global.Modifiers.AttackUp = {
    name: "Attack Up",
    triggers: [MOD_TRIGGER.PASSIVE],
    attack_mult: 1.2, // +20%
            // NEW: Tags this modifier adds
    synergy_tags: [SYNERGY_TAG.BLUNT],
    action: function(_entity, _event) { }
};

// Flat HP boost
global.Modifiers.HPUp = {
    name: "Tough Skin",
    triggers: [MOD_TRIGGER.PASSIVE],
    hp_mult: 1.25, // +25% HP
                // NEW: Tags this modifier adds
    synergy_tags: [SYNERGY_TAG.ATHLETIC],
    action: function(_entity, _event) { }
};

// Speed boost
global.Modifiers.SpeedUp = {
    name: "Swift Steps",
    triggers: [MOD_TRIGGER.PASSIVE],
    speed_mult: 1.15, // +15%
                // NEW: Tags this modifier adds
    synergy_tags: [SYNERGY_TAG.ATHLETIC],
    action: function(_entity, _event) { }
};

// Knockback resistance
global.Modifiers.KnockbackResist = {
    name: "Heavy Frame",
    triggers: [MOD_TRIGGER.PASSIVE],
    kb_mult: 0.8, // -20% knockback taken
    synergy_tags: [SYNERGY_TAG.ATHLETIC],
    action: function(_entity, _event) { }
};

// Glass Cannon
global.Modifiers.GlassCannon = {
    name: "Glass Cannon",
    triggers: [MOD_TRIGGER.PASSIVE],
    attack_mult: 1.4, // +40% damage
    hp_mult: 0.6,     // -40% HP
    synergy_tags: [SYNERGY_TAG.ATHLETIC],
    action: function(_entity, _event) { }
};

// Berserker (bonus damage at low HP)
global.Modifiers.Berserker = {
    name: "Berserker",
    triggers: [MOD_TRIGGER.ON_ATTACK],
    min_bonus: 1.0,
    max_bonus: 1.5,
    synergy_tags: [SYNERGY_TAG.ATHLETIC],
    action: function(_entity, _event) {
        var mod_template = global.Modifiers[$ _event.mod_instance.template_key];
        var hp_ratio = _entity.hp / _entity.hp_max;
        var dmg_mult = lerp(mod_template.max_bonus, mod_template.min_bonus, hp_ratio);
        _event.damage *= dmg_mult;
    }
};

// Adrenaline Rush (move faster below half HP)
global.Modifiers.AdrenalineRush = {
    name: "Adrenaline Rush",
    triggers: [MOD_TRIGGER.PASSIVE],
    hp_threshold: 0.5,
    speed_mult_low_hp: 1.3,
    synergy_tags: [SYNERGY_TAG.ATHLETIC],
    action: function(_entity, _event) {
        if (_entity.hp / _entity.hp_max < 0.5) {
            _entity.stats.speed *= 1.3;
        }
    }
};

// Lucky Strike (small crit chance)
global.Modifiers.LuckyStrike = {
    name: "Lucky Strike",
    triggers: [MOD_TRIGGER.ON_ATTACK],
    crit_chance: 0.1,
    crit_mult: 2.0,
    synergy_tags: [SYNERGY_TAG.ATHLETIC],
    action: function(_entity, _event) {
        var mod_template = global.Modifiers[$ _event.mod_instance.template_key];
        if (random(1) < mod_template.crit_chance) {
            _event.damage *= mod_template.crit_mult;
            // Optionally spawn crit popup
        }
    }
};

// Second Wind (heal a bit after room clear)
global.Modifiers.SecondWind = {
    name: "Second Wind",
    triggers: [MOD_TRIGGER.ON_ROOM_CLEAR],
    heal_ratio: 0.1,
    synergy_tags: [SYNERGY_TAG.ATHLETIC],
    action: function(_entity, _event) {
        var mod_template = global.Modifiers[$ _event.mod_instance.template_key];
        var heal_amount = _entity.hp_max * mod_template.heal_ratio;
        _entity.hp = clamp(_entity.hp + heal_amount, 0, _entity.hp_max);
    }
};

// Critical Focus (stacking crit chance on misses)
global.Modifiers.CriticalFocus = {
    name: "Critical Focus",
    triggers: [MOD_TRIGGER.ON_ATTACK, MOD_TRIGGER.ON_HIT],
    base_chance: 0.05,
    stack_gain: 0.02,
    max_bonus: 0.25,
    synergy_tags: [SYNERGY_TAG.ATHLETIC],
    action: function(_entity, _event) {
        var mod_instance = _event.mod_instance;
        var mod_template = global.Modifiers[$ mod_instance.template_key];
        
        if (!variable_struct_exists(mod_instance, "bonus_chance")) {
            mod_instance.bonus_chance = 0;
        }
        
        // On attack, apply crit
        if (_event.trigger == MOD_TRIGGER.ON_ATTACK) {
            var total_chance = mod_template.base_chance + mod_instance.bonus_chance;
            if (random(1) < total_chance) {
                _event.damage *= 2;
                mod_instance.bonus_chance = 0;
            }
        }
        
        // On hit miss, stack chance
        if (_event.trigger == MOD_TRIGGER.ON_HIT && !_event.hit_success) {
            mod_instance.bonus_chance = min(mod_instance.bonus_chance + mod_template.stack_gain, mod_template.max_bonus);
        }
    }
};