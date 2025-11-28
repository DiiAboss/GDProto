/// @file scr_StatComponent.gml

enum ELEMENT {
    PHYSICAL,
    FIRE,
    ICE,
    LIGHTNING,
    POISON
}

function StatsComponent(_base_attack, _base_hp, _base_speed, _base_knockback, _strength = 5, _weight = 5, _dexterity = 5) constructor {
    
    // ===========================================
    // BASE STATS
    // ===========================================
    base_attack = _base_attack;
    base_hp = _base_hp;
    base_speed = _base_speed;
    base_knockback = _base_knockback;
    compounding_bonus = 0;
    // ===========================================
    // PHYSICAL ATTRIBUTES (for weapon mechanics)
    // ===========================================
    strength = _strength;     // Affects damage & knockback dealt
    weight = _weight;         // Affects knockback received
    dexterity = _dexterity;   // Affects attack speed with light weapons
    luck = 0.0;  // Additive bonus to all proc chances (0.1 = +10%)
	
    // ===========================================
    // CURRENT STATS (modified by items/buffs)
    // ===========================================
    attack = _base_attack;
    hp_max = _base_hp;
    speed = _base_speed;
    knockback = _base_knockback;
    
    // ===========================================
    // CRITICAL HITS
    // ===========================================
    crit_chance = 0.05;  // 5% baseline
    crit_mult = 2.0;     // 2x damage on crit
    
    // ===========================================
    // ELEMENTAL DAMAGE
    // ===========================================
    // Flat elemental damage bonuses
    elem_fire = 0;
    elem_ice = 0;
    elem_lightning = 0;
    elem_poison = 0;
    
    // Elemental damage multipliers
    elem_mult_fire = 1.0;
    elem_mult_ice = 1.0;
    elem_mult_lightning = 1.0;
    elem_mult_poison = 1.0;
    
    // Elemental resistances (0.2 = 20% reduced damage)
    resist_fire = 0.0;
    resist_ice = 0.0;
    resist_lightning = 0.0;
    resist_poison = 0.0;
    
    // ===========================================
    // STATUS EFFECT APPLICATION CHANCES
    // ===========================================
    burn_chance = 0.0;
    burn_damage = 10;
    burn_rate = 60;          // Frames between ticks
    burn_duration = 600;     // Total duration
    
    freeze_chance = 0.0;
    freeze_damage = 10;
    freeze_rate = 60;
    freeze_duration = 600;
    
    shock_chance = 0.0;
    shock_damage = 5;
    shock_chain_count = 2;   // How many enemies to chain to
    
    poison_chance = 0.0;
    poison_damage = 4;
    poison_duration = 300;
    
    // ===========================================
    // CLASS-SPECIFIC RESOURCES (added by modifiers)
    // ===========================================
    // Mage
    mana = 0;
    mana_max = 0;
    mana_regen = 0;
    
    // Warrior
    rage = 0;
    rage_max = 0;
    armor = 0;
    
    // Vampire
    lifesteal = 0;
    blood_frenzy_active = false;
    blood_frenzy_timer = 0;
    
    // Assassin
    stealth_timer = 0;
    backstab_mult = 1.0;
    
    // Alchemist
    flask_charges = 0;
    flask_cooldown = 0;
    
    // Baseball Player
    homerun_chance = 0;
    reward_multiplier = 1.0;
    
    // ===========================================
    // TEMPORARY MODIFIERS (reset each frame)
    // ===========================================
    temp_attack_mult    = 1.0;
    temp_speed_mult	    = 1.0;
    temp_knockback_mult = 1.0;
    temp_defense_mult   = 1.0;
    
    // ===========================================
    // LIFESTEAL & HEALING
    // ===========================================
    lifesteal_percent = 0.0;  // % of damage healed
    regen_per_second  = 0.0;
    
    // ===========================================
    // MOVEMENT & MOBILITY
    // ===========================================
    dash_charges	 = 1;
    dash_cooldown	 = 0;
    movement_penalty = 1.0;   // Multiplier for slow effects
    
    // ===========================================
    // UTILITY
    // ===========================================
    pickup_radius   = 1.0;      // Item/XP pickup range multiplier
    experience_mult = 1.0;    // XP gain multiplier
    gold_mult	    = 1.0;          // Gold gain multiplier
    soul_mult      = 1.0;
    // ===========================================
    // METHODS
    // ===========================================
    
    /// @function GetFinalAttack()
    static GetFinalAttack = function() {
        return attack * temp_attack_mult;
    }
    
    /// @function GetFinalSpeed()
    static GetFinalSpeed = function() {
        return speed * temp_speed_mult * movement_penalty;
    }
    
    /// @function GetFinalKnockback()
    static GetFinalKnockback = function() {
        return knockback * temp_knockback_mult * (strength / 5);
    }
    
    /// @function ResetTemporaryMods()
    /// @description Call at start of each frame
    static ResetTemporaryMods = function() {
        temp_attack_mult = 1.0;
        temp_speed_mult = 1.0;
        temp_knockback_mult = 1.0;
        temp_defense_mult = 1.0;
    }
    
    /// @function RollCritical()
    /// @returns {bool} True if critical hit
    static RollCritical = function() {
        return random(1) < crit_chance;
    }
    
    /// @function GetCriticalDamage(_base_damage)
    static GetCriticalDamage = function(_base_damage) {
        return _base_damage * crit_mult;
    }
    
    /// @function ApplyElementalDamage(_base_damage, _element)
    /// @returns {real} Final damage with elemental modifiers
    static ApplyElementalDamage = function(_base_damage, _element) {
        var bonus_damage = 0;
        var mult = 1.0;
        
        switch (_element) {
            case ELEMENT.FIRE:
                bonus_damage = elem_fire;
                mult = elem_mult_fire;
                break;
            case ELEMENT.ICE:
                bonus_damage = elem_ice;
                mult = elem_mult_ice;
                break;
            case ELEMENT.LIGHTNING:
                bonus_damage = elem_lightning;
                mult = elem_mult_lightning;
                break;
            case ELEMENT.POISON:
                bonus_damage = elem_poison;
                mult = elem_mult_poison;
                break;
        }
        
        return (_base_damage + bonus_damage) * mult;
    }
    
    /// @function GetResistance(_element)
    /// @returns {real} Resistance value 0-1
    static GetResistance = function(_element) {
        switch (_element) {
            case ELEMENT.FIRE: return resist_fire;
            case ELEMENT.ICE: return resist_ice;
            case ELEMENT.LIGHTNING: return resist_lightning;
            case ELEMENT.POISON: return resist_poison;
            default: return 0;
        }
    }
}