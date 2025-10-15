// Character class enum
enum CharacterClass {
    WARRIOR,
    HOLY_MAGE,
    VAMPIRE
}

// scr_character_classes - Updated to avoid 'speed' conflict
function GetCharacterStats(_class) {
    var stats = {};
    
    switch (_class) {
        case CharacterClass.WARRIOR:
            stats = {
                name: "Barbarian",
                hp_max: 150,
                move_speed: 2,  // Changed from speed_base
                attack_base: 15,
                magic_power: 0.5,
                weapon_slots: 2,
                armor: 2,
                rage_buildup: 0.1,
                rage_max: 2.0
            };
            break;
            
        case CharacterClass.HOLY_MAGE:
            stats = {
                name: "Holy Mage", 
                hp_max: 80,
                move_speed: 2,
                attack_base: 8,
                magic_power: 2.0,
                weapon_slots: 2,
                mana_max: 100,
                mana_regen: 0.5,
                blessed_heal: 1
            };
            break;
            
        case CharacterClass.VAMPIRE:
            stats = {
                name: "Western Vampire",
                hp_max: 100,
                move_speed: 3,
                attack_base: 12,
                magic_power: 1.2,
                weapon_slots: 2,
                lifesteal: 0.15,
                blood_frenzy_duration: 180,
                blood_frenzy_bonus: 1.5
            };
            break;
    }
    
    return stats;
}