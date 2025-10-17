// ==========================================
// WEAPON SYNERGY SYSTEM
// ==========================================

/// @desc Initialize synergy lookup table (call in game init)
function InitWeaponSynergySystem() {
    global.WeaponSynergies = {};
    
    // Define all synergies as [Character][Weapon] = SynergyData
    // Format: "CHARACTER_WEAPON" = synergy config
    
    // ===== MAGE SYNERGIES =====
    global.WeaponSynergies.MAGE_BAT = {
        type: SynergyType.SPELL_BASEBALL,
        damage_mult: 0.7,           // Mage isn't strong, 70% damage
        knockback_mult: 0.6,        // 60% knockback
        attack_speed_mult: 1.0,
        projectile: obj_magic_baseball,  // NEW OBJECT NEEDED
        projectile_behavior: SynergyProjectileBehavior.ON_SWING,
        projectile_count: 2,        // Spawns 2 magic baseballs per swing
        projectile_spread: 30       // Degrees apart
    };
    
    global.WeaponSynergies.MAGE_SWORD = {
        type: SynergyType.ARCANE_BLADE,
        damage_mult: 0.8,
        knockback_mult: 0.7,
        attack_speed_mult: 1.2,     // Faster swings
        projectile: obj_arcane_slash, // NEW OBJECT NEEDED
        projectile_behavior: SynergyProjectileBehavior.ON_SWING,
        projectile_count: 1
    };
    
    global.WeaponSynergies.MAGE_GRENADE = {
        type: SynergyType.HOLY_GRENADE,
        damage_mult: 1.5,           // Holy power boost
        explosion_radius_mult: 1.3,
        projectile: obj_holy_water, // Existing object
        throw_style: "holy_arc"
    };
    
    // ===== BASEBALL PLAYER SYNERGIES =====
    global.WeaponSynergies.BASEBALL_BAT = {
        type: SynergyType.HOMERUN_MASTER,
        damage_mult: 1.3,
        knockback_mult: 2.5,        // HUGE knockback
        attack_speed_mult: 0.9,     // Slightly slower windups
        homerun_chance: 0.35,       // 35% chance (adds to base)
        projectile_behavior: SynergyProjectileBehavior.NONE
    };
    
    global.WeaponSynergies.BASEBALL_GRENADE = {
        type: SynergyType.FASTBALL_THROW,
        damage_mult: 1.0,
        throw_speed_mult: 2.0,      // Throws 2x faster
        throw_style: "fastball",    // Straight line, no arc
        projectile: obj_grenade     // Use regular grenade but modified behavior
    };
    
    // ===== WARRIOR SYNERGIES =====
    global.WeaponSynergies.WARRIOR_BAT = {
        type: SynergyType.BRUTAL_SWING,
        damage_mult: 1.5,
        knockback_mult: 1.8,
        attack_speed_mult: 0.7,     // Much slower
        projectile_behavior: SynergyProjectileBehavior.NONE
    };
    
    global.WeaponSynergies.WARRIOR_SWORD = {
        type: SynergyType.RAGE_BLADE,
        damage_mult: 1.2,
        knockback_mult: 1.1,
        rage_gain_on_hit: 0.15,     // Builds rage faster
        projectile_behavior: SynergyProjectileBehavior.NONE
    };
    
    // ===== VAMPIRE SYNERGIES =====
    global.WeaponSynergies.VAMPIRE_BAT = {
        type: SynergyType.BLOOD_BAT,
        damage_mult: 1.0,
        knockback_mult: 1.0,
        lifesteal_bonus: 0.10,      // +10% lifesteal on bat hits
        projectile_behavior: SynergyProjectileBehavior.NONE
    };
    
    global.WeaponSynergies.VAMPIRE_SWORD = {
        type: SynergyType.CRIMSON_BLADE,
        damage_mult: 1.1,
        knockback_mult: 0.9,
        projectile: obj_blood_projectile, // NEW OBJECT NEEDED
        projectile_behavior: SynergyProjectileBehavior.ON_HIT,
        projectile_count: 3,
        lifesteal_bonus: 0.05
    };
}

/// @desc Get weapon category from weapon enum
function GetWeaponCategory(_weapon_id) {
    switch (_weapon_id) {
        case Weapon.Sword: return WeaponCategory.SWORD;
        case Weapon.BaseballBat: return WeaponCategory.BAT;
        case Weapon.Dagger: return WeaponCategory.DAGGER;
        case Weapon.Holy_Water: return WeaponCategory.GRENADE;
        case Weapon.Bow: return WeaponCategory.BOW;
        case Weapon.ChargeCannon: return WeaponCategory.CANNON;
        case Weapon.Boomerang: return WeaponCategory.BOOMERANG;
        default: return WeaponCategory.SWORD;
    }
}

/// @desc Get character archetype from character class
function GetCharacterArchetype(_character_class) {
    switch (_character_class) {
        case CharacterClass.WARRIOR: return CharacterArchetype.WARRIOR;
        case CharacterClass.HOLY_MAGE: return CharacterArchetype.MAGE;
        case CharacterClass.VAMPIRE: return CharacterArchetype.VAMPIRE;
        default: return CharacterArchetype.WARRIOR;
    }
}

/// @desc Main function: Get synergy data for character + weapon combo
function GetWeaponSynergy(_character_class, _weapon_id) {
    var archetype = GetCharacterArchetype(_character_class);
    var category = GetWeaponCategory(_weapon_id);
    
    // Build lookup key
    var archetype_name = GetArchetypeName(archetype);
    var category_name = GetCategoryName(category);
    var key = archetype_name + "_" + category_name;
    
    // Check if synergy exists
    if (variable_struct_exists(global.WeaponSynergies, key)) {
        return global.WeaponSynergies[$ key];
    }
    
    // No synergy - return default
    return {
        type: SynergyType.NONE,
        damage_mult: 1.0,
        knockback_mult: 1.0,
        attack_speed_mult: 1.0,
        projectile_behavior: SynergyProjectileBehavior.NONE
    };
}

/// @desc Helper to get archetype name as string
function GetArchetypeName(_archetype) {
    switch (_archetype) {
        case CharacterArchetype.WARRIOR: return "WARRIOR";
        case CharacterArchetype.MAGE: return "MAGE";
        case CharacterArchetype.BASEBALL_PLAYER: return "BASEBALL";
        case CharacterArchetype.VAMPIRE: return "VAMPIRE";
        case CharacterArchetype.ROGUE: return "ROGUE";
        default: return "WARRIOR";
    }
}

/// @desc Helper to get category name as string
function GetCategoryName(_category) {
    switch (_category) {
        case WeaponCategory.SWORD: return "SWORD";
        case WeaponCategory.BAT: return "BAT";
        case WeaponCategory.DAGGER: return "DAGGER";
        case WeaponCategory.GRENADE: return "GRENADE";
        case WeaponCategory.BOW: return "BOW";
        case WeaponCategory.CANNON: return "CANNON";
        case WeaponCategory.BOOMERANG: return "BOOMERANG";
        default: return "SWORD";
    }
}

/// @desc Apply synergy modifications to weapon struct
function ApplySynergyToWeapon(_weapon_struct, _synergy_data, _player) {
    // Store synergy data in weapon
    _weapon_struct.active_synergy = _synergy_data;
    
    // Modify combo attacks if weapon has them
    if (variable_struct_exists(_weapon_struct, "combo_attacks")) {
        for (var i = 0; i < array_length(_weapon_struct.combo_attacks); i++) {
            _weapon_struct.combo_attacks[i].damage_mult *= _synergy_data.damage_mult;
            _weapon_struct.combo_attacks[i].knockback_mult *= _synergy_data.knockback_mult;
            _weapon_struct.combo_attacks[i].duration /= _synergy_data.attack_speed_mult;
        }
    }
    
    // Store projectile spawning behavior
    if (_synergy_data.projectile_behavior != SynergyProjectileBehavior.NONE) {
        _weapon_struct.spawn_projectiles = true;
        _weapon_struct.projectile_type = _synergy_data.projectile;
        _weapon_struct.projectile_behavior = _synergy_data.projectile_behavior;
        _weapon_struct.projectile_count = _synergy_data.projectile_count ?? 1;
        _weapon_struct.projectile_spread = _synergy_data.projectile_spread ?? 0;
    }
}