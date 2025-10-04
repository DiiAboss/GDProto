

function get_mod_by_id(_id) {
    for (var i = 0; i < array_length(obj_game_manager.allMods); i++) {
        if (obj_game_manager.allMods[i].id == _id) {
            return obj_game_manager.allMods[i];
        }
    }
    return undefined;
}


function mod_third_strike(player, _mod) {
    if (player.attack_counter mod 3 == 0) {
        player.attack *= 2;
    }
}

function mod_heal_on_kill(player, _mod, enemy) {
    player.hp = clamp(player.hp + 5, 0, player.maxHp);
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
                if (_event.attack_type == "melee") {
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
                } else if (_event.attack_type == "cannon" || _event.attack_type == "ranged") {
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
    
    spread_count: 5,
    spread_angle: 15,
    melee_arc_bonus: 30,
    
    action: function(_entity, _event) {
        var mod_template = global.Modifiers[$ _event.mod_instance.template_key];
        
        // Check attack type
        if (_event.attack_type == "melee") {
            // MELEE: Increase swing arc
            with (_entity) {
                if (instance_exists(sword)) {
                    sword.swing_arc = (sword.swing_arc ?? 90) + mod_template.melee_arc_bonus;
                }
            }
        } else if (_event.attack_type == "ranged" || _event.attack_type == "cannon") {
            // RANGED: Create spread of projectiles
            with (_entity) {
                var spread_count = mod_template.spread_count;
                var spread_angle = mod_template.spread_angle;
                var total_spread = spread_angle * (spread_count - 1);
                
                for (var i = 0; i < spread_count; i++) {
                    if (i != floor(spread_count/2)) { // Skip center (keep original)
                        var angle_offset = -total_spread/2 + (i * spread_angle);
                        
                        // Determine projectile type
                        var proj_type = obj_arrow; // Default
                        if (_event.projectile != noone && instance_exists(_event.projectile)) {
                            proj_type = _event.projectile.object_index;
                        }
                        
                        var proj = instance_create_depth(
                            _event.attack_position_x, 
                            _event.attack_position_y, 
                            depth - 1, 
                            proj_type
                        );
                        
                        proj.direction = _event.attack_direction + angle_offset;
                        proj.speed = 8;
                        
                        if (variable_instance_exists(proj, "damage")) {
                            proj.damage = (_event.damage ?? 10) * 0.5;
                        }
                        
                        if (variable_instance_exists(proj, "owner")) {
                            proj.owner = id;
                        }
                        
                        proj.image_angle = proj.direction;
                        proj.image_xscale = 0.8;
                        proj.image_yscale = 0.8;
                    }
                }
            }
        }
    }
};




enum WeaponType
{
	None,
	Melee,
	Range,
}

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

function TriggerModifiers(_entity, _trigger, _event_data) {
    if (!variable_instance_exists(_entity, "mod_list")) return;
    
    for (var i = 0; i < array_length(_entity.mod_list); i++) {
        var mod_instance = _entity.mod_list[i];
        
        // FIX: Use $ operator for dynamic struct access
        var mod_template = global.Modifiers[$ mod_instance.template_key];
        
        // Or alternative method:
        // var mod_template = variable_struct_get(global.Modifiers, mod_instance.template_key);
        
        if (mod_template == undefined) {
            show_debug_message("Modifier template not found: " + mod_instance.template_key);
            continue;
        }
        
        // Check if this modifier responds to this trigger
        if (array_contains(mod_template.triggers, _trigger)) {
            // Pass the mod instance so it can track its own state
            _event_data.mod_instance = mod_instance;
            
            // Execute the action
            mod_template.action(_entity, _event_data);
        }
    }
}


function AddModifier(_entity, _modifier_key) {
    if (!variable_instance_exists(_entity, "mod_list")) {
        _entity.mod_list = [];
    }
    
    // Check if modifier exists
    if (!variable_struct_exists(global.Modifiers, _modifier_key)) {
        show_debug_message("Modifier not found: " + _modifier_key);
        return noone;
    }
    
    // Create a simple instance that just references the template
    var mod_instance = {
        template_key: _modifier_key,
        counter: 0,  // Generic counter for any modifier that needs it
        active: true
    };
    
    array_push(_entity.mod_list, mod_instance);
    
    show_debug_message("Added modifier: " + _modifier_key);
    return mod_instance;
}


function ApplyStatModifiers(_self, _mods)
{
	var mod_hp_total = 0;
	var mod_attack_total = 0;
	var mod_knockback_total = 0;
	var mod_speed_total = 0;
	
	
	
	for (var i = 0; i < array_length(_mods) - 1; i++)
	{
		var _current_mod = _mods[i];
		
		if (variable_struct_exists(_current_mod, "hp_mod")) mod_hp_total += _current_mod.hp_mod;
		
		if (variable_struct_exists(_current_mod, "attack_mod")) mod_attack_total += _current_mod.attack_mod;
		
		if (variable_struct_exists(_current_mod, "knockback_mod")) mod_knockback_total += _current_mod.knockback_mod;
		
		if (variable_struct_exists(_current_mod, "speed_mod")) mod_speed_total += _current_mod.speed_mod;
	}
	
	
	
	var _ret = 
	{
		hp_mod:			0,
		attack_mod:   	0,
		knockback_mod: 	0,
		speed_mod:		0,
	}
}

function RunActiveModifiers(_self, _mods)
{
	for (var i = 0; i < array_length(_mods) - 1; i++)
	{
		var _current_mod = _mods[i];
		
		if (variable_struct_exists(_current_mod, "action")) _current_mod.action(_self);
	}
}



// Base pattern handler
function CreatePattern(_type, _config) {
    switch (_type) {
        case PATTERN_TYPE.EVERY_N:
            return {
                type: _type,
                counter: 0,
                trigger_on: _config.n ?? 3,
                
                should_trigger: function() {
                    counter++;
                    if (counter >= trigger_on) {
                        counter = 0;
                        return true;
                    }
                    return false;
                }
            };
            
        case PATTERN_TYPE.CHANCE:
            return {
                type: _type,
                chance: _config.chance ?? 0.25,
                
                should_trigger: function() {
                    return random(1) < chance;
                }
            };
            
        case PATTERN_TYPE.SEQUENCE:
            return {
                type: _type,
                pattern: _config.pattern ?? [false, false, true],
                index: 0,
                
                should_trigger: function() {
                    var result = pattern[index];
                    index = (index + 1) % array_length(pattern);
                    return result;
                }
            };
    }
}

// Base effect executor
function CreateEffect(_type, _config) {
    switch (_type) {
        case EFFECT_TYPE.SPAWN_PROJECTILE:
            return {
                type: _type,
                projectile: _config.projectile,
                count: _config.count ?? 1,
                spread: _config.spread ?? 0,
                
                execute: function(_entity, _event) {
                    with (_entity) {
                        for (var i = 0; i < other.count; i++) {
                            var proj = instance_create_depth(x, y, depth, other.projectile);
                            proj.direction = _event.attack_direction + (i - other.count/2) * other.spread;
                            proj.owner = id;
                        }
                    }
                }
            };
            
        case EFFECT_TYPE.MODIFY_PROJECTILE:
            return {
                type: _type,
                modifications: _config.mods,
                
                execute: function(_entity, _event) {
                    // Modify the projectile that was just created
                    if (_event.projectile != noone) {
                        with (_event.projectile) {
                            // Apply modifications
                            var mods = other.modifications;
                            if (variable_struct_exists(mods, "element")) {
                                element = mods.element;
                                
                                // Visual changes based on element
                                switch (element) {
                                    case "fire":
                                        sprite_index = spr_fire_projectile;
                                        image_blend = c_orange;
                                        break;
                                    case "ice":
                                        sprite_index = spr_ice_projectile;
                                        image_blend = c_aqua;
                                        break;
                                }
                            }
                            
                            if (variable_struct_exists(mods, "scale")) {
                                image_xscale *= mods.scale;
                                image_yscale *= mods.scale;
                                damage *= mods.scale;
                            }
                            
                            if (variable_struct_exists(mods, "piercing")) {
                                piercing = mods.piercing;
                            }
                        }
                    }
                }
            };
            
        case EFFECT_TYPE.RANDOM_EFFECT:
            return {
                type: _type,
                pool: _config.pool,
                
                execute: function(_entity, _event) {
                    // Pick random effect from pool
                    var random_effect = pool[irandom(array_length(pool) - 1)];
                    random_effect.execute(_entity, _event);
                }
            };
    }
}





/// @function scr_chain_lightning(source, start_target, max_jumps, range, base_damage, falloff)
/// @param source          // the caster or origin of lightning
/// @param start_target    // the first enemy hit
/// @param max_jumps       // how many total jumps (including first target)
/// @param range           // distance range for next jump
/// @param base_damage     // initial damage amount
/// @param falloff         // percent damage retained per jump (e.g. 0.75 = -25% each)

function scr_chain_lightning(source, start_target, max_jumps, range, base_damage, falloff) {
    var curr_target = start_target;
    var curr_damage = base_damage;
    var jumps = 0;
    var hit_list = [curr_target];

    with (curr_target) hp -= curr_damage;

    while (jumps < max_jumps - 1) {
        var next_target = noone;
        var nearest_dist = range;

        with (obj_enemy) {
            if (!array_contains(hit_list, id)) {
                var d = point_distance(curr_target.x, curr_target.y, x, y);
                if (d < nearest_dist) {
                    nearest_dist = d;
                    next_target = id;
                }
            }
        }

        if (next_target == noone) break;

        curr_damage *= falloff;
        with (next_target) hp -= curr_damage;

        array_push(hit_list, next_target);

        // 🔥 spawn a visual effect object
        var l = instance_create_layer(curr_target.x, curr_target.y, "Effects", obj_lightning);
        l.x2 = next_target.x;
        l.y2 = next_target.y;

        curr_target = next_target;
        jumps++;
    }
}




/// scr_lightning_effect(x1, y1, x2, y2)
/// Draws a jagged lightning bolt between two points

function scr_lightning_effect(x1, y1, x2, y2) {
    var segments = 5;
    var thickness = 2;
    var points = [];

    for (var i = 0; i <= segments; i++) {
        var t = i / segments;
        var _x = lerp(x1, x2, t);
        var _y = lerp(y1, y2, t);
        if (i > 0 && i < segments)
            _y += random_range(-6, 6); // small offset for jagged look
        array_push(points, [_x, _y]);
    }

    for (var i = 0; i < array_length(points) - 1; i++) {
        var p1 = points[i];
        var p2 = points[i + 1];
        draw_line_width_color(p1[0], p1[1], p2[0], p2[1], thickness, c_white, c_aqua);
    }
}
