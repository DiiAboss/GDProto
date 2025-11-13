

function get_mod_by_id(_id) {
    for (var i = 0; i < array_length(obj_game_manager.allMods); i++) {
        if (obj_game_manager.allMods[i].id == _id) {
            return obj_game_manager.allMods[i];
        }
    }
    return noone;
}


function mod_third_strike(player, _mod) {
    if (player.attack_counter mod 3 == 0) {
        player.attack *= 2;
    }
}

function mod_heal_on_kill(player, _mod, enemy) {
    player.hp = clamp(player.hp + 5, 0, player.maxHp);
}

/// @function CreateBonusProjectiles(_entity, _event_data)
function CreateBonusProjectiles(_entity, _event_data) {
    if (!instance_exists(_event_data.projectile)) return;
    
    var original_proj = _event_data.projectile;
    var bonus_count = _event_data.projectile_count_bonus;
    var spread_angle = 15;
    
    // FIX: Use attack_direction instead of direction
    var base_direction = _event_data.attack_direction ?? original_proj.direction ?? 0;
    
    for (var i = 0; i < bonus_count; i++) {
        var angle_offset = spread_angle * (i + 1);
        var new_dir = base_direction + choose(angle_offset, -angle_offset);
        
        // Create bonus projectile
        var bonus_proj = instance_create_depth(
            original_proj.x,
            original_proj.y,
            original_proj.depth,
            original_proj.object_index
        );
        
        // Copy properties from original
        bonus_proj.direction = new_dir;
        bonus_proj.image_angle = new_dir;
        bonus_proj.speed = original_proj.speed;
        bonus_proj.damage = original_proj.damage;
        bonus_proj.owner = original_proj.owner;
        
        // Copy lob properties for thrown weapons
        if (variable_instance_exists(original_proj, "xStart")) {
            bonus_proj.xStart = original_proj.xStart;
            bonus_proj.yStart = original_proj.yStart;
            bonus_proj.targetDistance = original_proj.targetDistance;
            bonus_proj.lob_direction = new_dir;
        }
        
        // Copy synergy data
        if (variable_instance_exists(original_proj, "synergy_tags")) {
            bonus_proj.synergy_tags = original_proj.synergy_tags;
        }
        if (variable_instance_exists(original_proj, "active_synergies")) {
            bonus_proj.active_synergies = original_proj.active_synergies;
        }
        if (variable_instance_exists(original_proj, "synergy_owner")) {
            bonus_proj.synergy_owner = original_proj.synergy_owner;
        }
        
        // Copy synergy-applied properties
        if (variable_instance_exists(original_proj, "element_type")) {
            bonus_proj.element_type = original_proj.element_type;
        }
        if (variable_instance_exists(original_proj, "has_lifesteal")) {
            bonus_proj.has_lifesteal = original_proj.has_lifesteal;
            bonus_proj.lifesteal_percent = original_proj.lifesteal_percent;
        }
        if (variable_instance_exists(original_proj, "explosion_damage")) {
            bonus_proj.explosion_damage = original_proj.explosion_damage;
        }
        if (variable_instance_exists(original_proj, "explosion_radius")) {
            bonus_proj.explosion_radius = original_proj.explosion_radius;
        }
        
        show_debug_message("Created bonus projectile with spread: " + string(angle_offset));
    }
}

function TriggerModifiers(_entity, _trigger, _event_data) {
    if (!variable_instance_exists(_entity, "mod_cache")) return;
    
    if (!variable_struct_exists(_event_data, "trigger")) {
        _event_data.trigger = _trigger;
    }
    
    // Get cached list of modifiers for this trigger
    var trigger_str = string(_trigger);
    var trigger_mods = _entity.mod_cache[$ trigger_str];
    
    if (trigger_mods == noone || array_length(trigger_mods) == 0) return;
    
    // Run all modifiers that respond to this trigger
    for (var i = 0; i < array_length(trigger_mods); i++) {
        var mod_instance = trigger_mods[i];
        
        if (!mod_instance.active) continue;
        
        var mod_template = global.Modifiers[$ mod_instance.template_key];
        
        if (mod_template == noone) continue;
        
        // Add stack level to event data
        _event_data.mod_instance = mod_instance;
        _event_data.stack_level = mod_instance.stack_level ?? 1;
        
        // Just run the action - let each modifier handle its own proc chance
        mod_template.action(_entity, _event_data);
    }
    
    // Handle bonus projectiles
    if (_trigger == MOD_TRIGGER.ON_ATTACK) {
        if (variable_struct_exists(_event_data, "projectile_count_bonus") && 
            _event_data.projectile_count_bonus > 0) {
            CreateBonusProjectiles(_entity, _event_data);
        }
    }
}

function AddModifier(_entity, _modifier_key) {
    if (!variable_instance_exists(_entity, "mod_list")) {
        _entity.mod_list = [];
        _entity.mod_cache = {}; // Cache modifiers by trigger
    }
    
    // Check if modifier exists
    if (!variable_struct_exists(global.Modifiers, _modifier_key)) {
        show_debug_message("Modifier not found: " + _modifier_key);
        return noone;
    }
    
    var mod_template = global.Modifiers[$ _modifier_key];
    
    // NEW: Check if entity already has this modifier (for stacking)
    var existing_index = -1;
    for (var i = 0; i < array_length(_entity.mod_list); i++) {
        if (_entity.mod_list[i].template_key == _modifier_key) {
            existing_index = i;
            break;
        }
    }
    
    // NEW: If modifier exists, STACK IT
    if (existing_index != -1) {
        if (!variable_struct_exists(_entity.mod_list[existing_index], "stack_level")) {
            _entity.mod_list[existing_index].stack_level = 1;
        }
        _entity.mod_list[existing_index].stack_level++;
        
        show_debug_message("STACKED " + _modifier_key + " to level " + string(_entity.mod_list[existing_index].stack_level));
        
        // Recalculate passive stats
        if (instance_exists(_entity) && object_is_ancestor(_entity.object_index, obj_player)) {
            CalculateCachedStats(_entity);
        }
        
        return _entity.mod_list[existing_index];
    }
    
    // Create instance
    var mod_instance = {
        template_key: _modifier_key,
        counter: 0,
        active: true,
        stack_level: 1  // NEW: Add stack level
    };
    
    array_push(_entity.mod_list, mod_instance);
    
    // Cache by trigger type for fast lookup
    for (var i = 0; i < array_length(mod_template.triggers); i++) {
        var trigger = mod_template.triggers[i];
        var trigger_str = string(trigger); // Convert enum to string for struct key
        
        if (!variable_struct_exists(_entity.mod_cache, trigger_str)) {
            _entity.mod_cache[$ trigger_str] = [];
        }
        
        array_push(_entity.mod_cache[$ trigger_str], mod_instance);
    }
    
    // NEW: Add synergy tags
    if (variable_struct_exists(mod_template, "synergy_tags")) {
        for (var i = 0; i < array_length(mod_template.synergy_tags); i++) {
            AddModifierTag(_entity, mod_template.synergy_tags[i]);
        }
    }
    
    // NEW: Recalculate passive stats
    if (instance_exists(_entity) && object_is_ancestor(_entity.object_index, obj_player)) {
        CalculateCachedStats(_entity);
    }
    
    show_debug_message("Added modifier: " + _modifier_key);
    return mod_instance;
}



function ApplyStatModifiers(_self, _mods)
{
	var mod_hp_total = 0;
	var mod_attack_total = 0;
	var mod_knockback_total = 0;
	var mod_speed_total = 0;
	
	
	
	for (var i = 0; i < array_length(_mods); i++)
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
	
	return _ret;
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
    
    // FIXED: Use component system instead of direct hp modification
    with (curr_target) {
        if (!marked_for_death) {
            if (variable_instance_exists(id, "damage_sys")) {
                damage_sys.TakeDamage(curr_damage, source);
                hp = damage_sys.hp; // Sync
            } else {
                hp -= curr_damage; // Fallback
            }
            hitFlashTimer = 10;
            image_blend = c_yellow;
        }
    }
    
    while (jumps < max_jumps - 1) {
        var next_target = noone;
        var nearest_dist = range;
        
        with (obj_enemy) {
            // FIXED: Skip dead enemies
            if (!array_contains(hit_list, id) && !marked_for_death) {
                var d = point_distance(curr_target.x, curr_target.y, x, y);
                if (d < nearest_dist) {
                    nearest_dist = d;
                    next_target = id;
                }
            }
        }
        
        if (next_target == noone) break;
        
        curr_damage *= falloff;
        
        // FIXED: Use component system
        with (next_target) {
            if (!marked_for_death) {
                if (variable_instance_exists(id, "damage_sys")) {
                    damage_sys.TakeDamage(curr_damage, source);
                    hp = damage_sys.hp; // Sync
                } else {
                    hp -= curr_damage; // Fallback
                }
                hitFlashTimer = 10;
                image_blend = c_yellow;
            }
        }
        
        array_push(hit_list, next_target);
        
        //  spawn a visual effect object
        var l = instance_create_layer(curr_target.x, curr_target.y, "Effects", obj_lightning);
        if (instance_exists(l)) {
            l.x2 = next_target.x;
            l.y2 = next_target.y;
        }
        
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



function EventData(_data = {}) {
    var _event = _data;
    if (!variable_struct_exists(_event, "attack_type")) _event.attack_type = AttackType.UNKNOWN;
    if (!variable_struct_exists(_event, "projectile"))  _event.projectile  = noone;
    if (!variable_struct_exists(_event, "target"))      _event.target      = noone;
    if (!variable_struct_exists(_event, "damage"))      _event.damage      = 0;
    return _event;
}

/// @function CreateModifierInstance(_template_key, _stack_level)
function CreateModifierInstance(_template_key, _stack_level = 1) {
    var template = global.Modifiers[$ _template_key];
    
    return {
        template_key: _template_key,
        stack_level: _stack_level,
        name: template.name,
        triggers: template.triggers,
        
        // NEW: Activation chance (100 = always, 10 = 10% chance)
        activation_chance: template.activation_chance ?? 100,
        
        // NEW: Synergy tags this modifier provides
        synergy_tags: template.synergy_tags ?? [],
        
        // Track activation statistics
        activation_attempts: 0,
        successful_activations: 0
    };
}

/// @function GetStackedValue(_base_value, _stack_level)
/// @description Calculate value with diminishing returns per stack
/// Stack 1: base_value (100%)
/// Stack 2: base_value * 1.5 (150%)
/// Stack 3: base_value * 1.75 (175%)
/// Stack 4: base_value * 1.875 (187.5%)
/// Each stack adds 50% of the previous bonus
function GetStackedValue(_base_value, _stack_level) {
    if (_stack_level <= 1) return _base_value;
    
    var total = _base_value;
    var bonus = _base_value * 0.5; // 50% bonus for second stack
    
    for (var i = 2; i <= _stack_level; i++) {
        total += bonus;
        bonus *= 0.5; // Diminishing returns
    }
    
    return total;
}

/// @function ShouldModifierActivate(_activation_chance)
/// @description Check if modifier should activate based on chance
/// @param {real} _activation_chance - Percentage chance (0-100)
function ShouldModifierActivate(_activation_chance) {
    if (_activation_chance >= 100) return true;
    return (random(100) < _activation_chance);
}