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
