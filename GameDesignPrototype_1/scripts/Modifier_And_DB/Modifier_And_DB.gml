

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

function CreateBonusProjectiles(_entity, _event) {
    if (_event.attack_type != "ranged" && _event.attack_type != "cannon") return;
    
    var bonus_count = _event.projectile_count_bonus;
    if (bonus_count <= 0) return;
    
    with (_entity) {
        // Get projectile type
        var proj_type = obj_arrow;
        if (_event.projectile != noone && instance_exists(_event.projectile)) {
            proj_type = _event.projectile.object_index;
        }
        
        // Calculate spread
        var spread_angle = 15; // Degrees between projectiles
        var total_spread = spread_angle * bonus_count;
        
        // Create projectiles in a spread
        for (var i = 0; i < bonus_count; i++) {
            var angle_offset = -total_spread/2 + (i * spread_angle) + spread_angle/2;
            
            var proj = instance_create_depth(
                _event.attack_position_x,
                _event.attack_position_y,
                depth - 1,
                proj_type
            );
            
            proj.direction = _event.attack_direction + angle_offset;
            proj.speed = 8;
            proj.damage = (_event.damage ?? attack) * 0.8; // Slightly reduced
            proj.owner = id;
            proj.image_angle = proj.direction;
            proj.image_xscale = 0.9;
            proj.image_yscale = 0.9;
        }
    }
}



function TriggerModifiers(_entity, _trigger, _event_data) {
    if (!variable_instance_exists(_entity, "mod_list")) return;
    
    _event_data.trigger_type = _trigger;
    
    // Ensure we have a struct
    if (!is_struct(_event_data)) _event_data = {};
    
    // Normalize common fields with safe defaults
    if (!variable_struct_exists(_event_data, "attack_type"))       _event_data.attack_type = "unknown";
    if (!variable_struct_exists(_event_data, "attack_direction"))  _event_data.attack_direction = 0;
    if (!variable_struct_exists(_event_data, "attack_position_x")) _event_data.attack_position_x = (variable_instance_exists(_entity, "x") ? _entity.x : 0);
    if (!variable_struct_exists(_event_data, "attack_position_y")) _event_data.attack_position_y = (variable_instance_exists(_entity, "y") ? _entity.y : 0);
    if (!variable_struct_exists(_event_data, "damage"))            _event_data.damage = 0;
    if (!variable_struct_exists(_event_data, "projectile"))        _event_data.projectile = noone;
    if (!variable_struct_exists(_event_data, "weapon"))            _event_data.weapon = (variable_instance_exists(_entity, "weaponCurrent") ? _entity.weaponCurrent : noone);
    if (!variable_struct_exists(_event_data, "projectile_count_bonus")) _event_data.projectile_count_bonus = 0;
    
    // Run all modifiers
    for (var i = 0; i < array_length(_entity.mod_list); i++) {
        var mod_instance = _entity.mod_list[i];
        var mod_template = global.Modifiers[$ mod_instance.template_key];
        
        if (mod_template == undefined) {
            show_debug_message("Modifier template not found: " + mod_instance.template_key);
            continue;
        }
        
        if (array_contains(mod_template.triggers, _trigger)) {
            _event_data.mod_instance = mod_instance;
            mod_template.action(_entity, _event_data);
        }
    }
    
    // AFTER all modifiers run, create bonus projectiles
    if (_trigger == MOD_TRIGGER.ON_ATTACK && _event_data.projectile_count_bonus > 0) {
        CreateBonusProjectiles(_entity, _event_data);
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
    
    var mod_template = global.Modifiers[$ _modifier_key];
    var mod_instance = {
        template_key: _modifier_key,
        counter: 0,
        active: true
    };
    
    // Initialize any template-specific state
    if (variable_struct_exists(mod_template, "init_state")) {
        mod_template.init_state(mod_instance);
    }
    
    array_push(_entity.mod_list, mod_instance);
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


function CreateAttackEvent(_entity, _direction, _projectile = noone) {
    return {
        attack_type: "ranged",
        attack_direction: _direction,
        attack_position_x: _entity.x,
        attack_position_y: _entity.y,
        damage: _entity.attack,
        projectile: _projectile,
        weapon: _entity.weaponCurrent
    };
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



function EventData(_data = []) {
    var _event = _data;
    if (!variable_struct_exists(_event, "attack_type")) _event.attack_type = "unknown";
    if (!variable_struct_exists(_event, "projectile"))  _event.projectile  = noone;
    if (!variable_struct_exists(_event, "target"))      _event.target      = noone;
    if (!variable_struct_exists(_event, "damage"))      _event.damage      = 0;
    return _event;
}