// ==========================================
// STATUS EFFECT COMPONENT
// ==========================================
function StatusEffectComponent(_owner) constructor {
    owner = _owner;

    // Effect timers and strengths
    burn_timer = 0;
    burn_dps = 0;

    freeze_timer = 0;
    freeze_slow_mult = 1.0;

    poison_timer = 0;
    poison_dps = 0;

    shock_timer = 0;
    shock_stun = false;

    /// @func ApplyStatusEffect(_type, _data)
    static ApplyStatusEffect = function(_type, _data) {
        switch(_type) {
            case ELEMENT.FIRE:
                burn_timer = _data.duration;
                burn_dps   = _data.damage;
                show_debug_message("🔥 " + string(owner) + " is burning for " + string(burn_dps));
                break;

            case ELEMENT.ICE:
                freeze_timer = _data.duration;
                freeze_slow_mult = _data.slow_mult;
                show_debug_message("❄️ " + string(owner) + " frozen (speed x" + string(freeze_slow_mult) + ")");
                break;

            case ELEMENT.POISON:
                poison_timer = _data.duration;
                poison_dps   = _data.damage;
                show_debug_message("☠️ " + string(owner) + " poisoned for " + string(poison_dps));
                break;

            case ELEMENT.LIGHTNING:
                shock_timer = _data.duration;
                shock_stun = true;
                show_debug_message("⚡ " + string(owner) + " shocked!");
                break;
        }
    }

    /// @func Update()
    static Update = function() {
        // 🔥 Burn Damage
        if (burn_timer > 0) {
    if (burn_timer mod 5 == 0) 
		{
		scr_spawn_element_particles(
    owner,
    spr_fire_particle,
    [c_red, c_orange, c_yellow],
    3,
    [1.5, 3],
    [0.5, 1],
    [15, 30]
); // spawn visuals every few frames
		}
    if (burn_timer mod 60 == 0 && instance_exists(owner)) {
        if (variable_instance_exists(owner , "damage_sys"))
            owner.damage_sys.TakeDamage(burn_dps, noone, ELEMENT.FIRE);
    }

    burn_timer = max(burn_timer - 1, 0);
}

        // ❄️ Freeze effect
        if (freeze_timer > 0) {
            freeze_timer--;
            if (freeze_timer <= 0) freeze_slow_mult = 1.0;
        }

        // ☠️ Poison Damage
        if (poison_timer > 0) {
			if (poison_timer mod 5 == 0) 
		{
				scr_spawn_element_particles(
    owner,
    spr_poison_particle,
    [make_color_rgb(100,255,100), make_color_rgb(180,255,150)],
    3,
    [1, 2],
    [0.2, 0.6],
    [20, 40]
);
		}
            if (poison_timer mod 60 == 0 && instance_exists(owner)) {
                if (variable_instance_exists(owner, "damage_sys"))
                    owner.damage_sys.TakeDamage(poison_dps, noone, ELEMENT.POISON);
                show_debug_message("☠️ poison tick for " + string(poison_dps));
            }
            poison_timer = max(poison_timer - 1, 0);
        }

        // ⚡ Shock stun
        if (shock_timer > 0) {
            shock_timer--;
            if (shock_timer <= 0) shock_stun = false;
        }
    }

    /// @func DrawDebug()
    static DrawDebug = function() {
        draw_set_color(c_white);
        draw_text(owner.x + 20, owner.y - 40,
            "burn�" + string(burn_timer) +
            "freeze️" + string(freeze_timer) +
            "posion️" + string(poison_timer) +
            "lightning" + string(shock_timer)
        );
    }
}


/// @function CalculateCachedStats(_entity)
/// @description Recalculate all passive modifier bonuses and UPDATE player stats
function CalculateCachedStats(_entity) {
    if (!instance_exists(_entity)) return;
    if (!variable_instance_exists(_entity, "mod_list")) return;
    if (!variable_instance_exists(_entity, "stats")) return;
    
    // Initialize base stats if they don't exist (one-time)
    if (!variable_instance_exists(_entity.stats, "base_attack")) {
        _entity.stats.base_attack = _entity.stats.attack;
    }
    if (!variable_instance_exists(_entity.stats, "base_speed")) {
        _entity.stats.base_speed = _entity.stats.speed;
    }
    if (!variable_instance_exists(_entity.damage_sys, "base_max_hp")) {
        _entity.damage_sys.base_max_hp = _entity.damage_sys.max_hp;
    }
    
    // Start fresh from base stats
    var damage_bonus = 0;
    var damage_mult = 1.0;
    var speed_bonus = 0;
    var speed_mult = 1.0;
    var max_hp_bonus = 0;
    
    // Loop through all modifiers
    for (var i = 0; i < array_length(_entity.mod_list); i++) {
        var mod_instance = _entity.mod_list[i];
        if (!mod_instance.active) continue;
        
        var mod_template = global.Modifiers[$ mod_instance.template_key];
        if (mod_template == noone) continue;
        
        var stack = mod_instance.stack_level ?? 1;
        
        // Apply passive_stats if they exist
        if (variable_struct_exists(mod_template, "passive_stats")) {
            var stats = mod_template.passive_stats;
            
            if (variable_struct_exists(stats, "damage_bonus")) {
                damage_bonus += GetStackedValue(stats.damage_bonus, stack);
            }
            if (variable_struct_exists(stats, "damage_mult")) {
                damage_mult *= GetStackedValue(stats.damage_mult, stack);
            }
            if (variable_struct_exists(stats, "speed_bonus")) {
                speed_bonus += GetStackedValue(stats.speed_bonus, stack);
            }
            if (variable_struct_exists(stats, "speed_mult")) {
                speed_mult *= GetStackedValue(stats.speed_mult, stack);
            }
            if (variable_struct_exists(stats, "max_hp_bonus")) {
                max_hp_bonus += GetStackedValue(stats.max_hp_bonus, stack);
            }
        }
    }
    
    // APPLY calculated stats to component system
    _entity.stats.attack = (_entity.stats.base_attack + damage_bonus) * damage_mult;
    _entity.stats.speed = (_entity.stats.base_speed + speed_bonus) * speed_mult;
    _entity.damage_sys.max_hp = _entity.damage_sys.base_max_hp + max_hp_bonus;
    
    // Sync legacy variables
    _entity.attack = _entity.stats.attack;
    _entity.mySpeed = _entity.stats.speed;
    _entity.maxHp = _entity.damage_sys.max_hp;
    _entity.hp_max = _entity.damage_sys.max_hp;
    
    // Don't let HP exceed new max
    _entity.damage_sys.hp = min(_entity.damage_sys.hp, _entity.damage_sys.max_hp);
    _entity.hp = _entity.damage_sys.hp;
    
    show_debug_message("Stats Recalculated: ATK=" + string(floor(_entity.stats.attack)) + 
                       " SPD=" + string(_entity.stats.speed) + 
                       " HP=" + string(_entity.damage_sys.max_hp));
}




