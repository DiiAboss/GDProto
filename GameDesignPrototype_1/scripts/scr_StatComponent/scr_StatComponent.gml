

enum ELEMENT {
    PHYSICAL,
    FIRE,
    ICE,
    LIGHTNING,
    POISON
}


function StatsComponent(_base_attack, _base_hp, _base_speed, _base_knockback) constructor {
    // Base stats
    base_attack = _base_attack;
    base_hp = _base_hp;
    base_speed = _base_speed;
    base_knockback = _base_knockback;

    // Current stats
    attack = _base_attack;
    hp_max = _base_hp;
    speed = _base_speed;
    knockback = _base_knockback;

    // ==========================
    // CRIT
    // ==========================
    crit_chance = 0.05; // 5% baseline
    crit_mult   = 2.0;

    // ==========================
    // ELEMENTAL DAMAGE
    // ==========================
    // Raw multipliers or bonus flat values
    elem_fire     = 0;   // additive flat fire dmg
    elem_ice      = 0;
    elem_lightning= 0;
    elem_poison   = 0;
    
    // Damage multipliers (for scaling)
    elem_mult_fire      = 1.0;
    elem_mult_ice       = 1.0;
    elem_mult_lightning = 1.0;
    elem_mult_poison    = 1.0;
    
    // Resistance (0.2 = 20% reduced dmg)
    resist_fire      = 0.0;
    resist_ice       = 0.0;
    resist_lightning = 0.0;
    resist_poison    = 0.0;

    // ==========================
    // STATUS CHANCES
    // ==========================
    burn_chance = 0.0;
    burn_damage = 10;
    burn_rate = 60;
    burn_duration = burn_rate * 10;

    freeze_chance = 0.0;
    freeze_damage = 10;
    freeze_rate = 60;
    freeze_duration = freeze_rate * 10;

    shock_chance = 0.0;
    shock_damage = 5;
    shock_chain_count = 2;

    poison_chance = 0.0;
    poison_damage = 4;
    poison_duration = 300;

    // Temporary modifiers
    temp_attack_mult = 1.0;
    temp_speed_mult = 1.0;

    static Recalculate = function(_modifier_func = undefined) {
        attack = base_attack;
        hp_max = base_hp;
        speed = base_speed;
        knockback = base_knockback;

        if (_modifier_func != undefined) {
            var modified = _modifier_func(base_attack, hp_max, base_knockback, base_speed);
            attack = modified[0];
            hp_max = modified[1];
            knockback = modified[2];
            speed = modified[3];
        }

        attack *= temp_attack_mult;
        speed *= temp_speed_mult;
    }

    /// @func GetDamageForElement
    /// @desc Returns final damage based on type + crit + element
    static GetDamageForElement = function(_base, _element) {
        var dmg = _base;
        
        // Apply elemental scaling
        switch(_element) {
            case ELEMENT.FIRE:      dmg = (dmg + elem_fire) * elem_mult_fire; break;
            case ELEMENT.ICE:       dmg = (dmg + elem_ice) * elem_mult_ice; break;
            case ELEMENT.LIGHTNING: dmg = (dmg + elem_lightning) * elem_mult_lightning; break;
            case ELEMENT.POISON:    dmg = (dmg + elem_poison) * elem_mult_poison; break;
        }

        // Crit roll
        if (random(1) < crit_chance) dmg *= crit_mult;
        
        return dmg;
    }
}
