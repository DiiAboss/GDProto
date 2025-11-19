// Character class enum
enum CharacterClass {
	BASE,
    WARRIOR,
    HOLY_MAGE,
    VAMPIRE,
	BASEBALL_PLAYER,
	ALCHEMIST,
	ASSASSIN,
}

/// @function GetCharacterStats(_class)
/// @function GetCharacterStats(_class)
function GetCharacterStats(_class) {
    var stats = {};
    
    switch (_class) {
        case CharacterClass.WARRIOR:
            stats = {
                name: "Barbarian",
                hp_max: 150,
                move_speed: 2,
                attack_base: 15,
                magic_power: 0.5,
                weapon_slots: 2,
                strength: 8,      // High damage, slow with heavy weapons
                weight: 7,        // Hard to knock back
                dexterity: 3      // Slow with light weapons
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
                strength: 3,      // Weak physically
                weight: 5,        // Average
                dexterity: 6      // Decent speed
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
                strength: 5,      // Moderate
                weight: 4,        // Light, easy to knock back
                dexterity: 8      // Very fast
            };
            break;
            
        case CharacterClass.BASEBALL_PLAYER:
            stats = {
                name: "Baseball Star",
                hp_max: 120,
                move_speed: 3,
                attack_base: 12,
                magic_power: 0.8,
                weapon_slots: 2,
                strength: 7,      // Good power
                weight: 6,        // Athletic build
                dexterity: 7      // Fast swings
            };
            break;
            
        case CharacterClass.ASSASSIN:
            stats = {
                name: "Shadow Blade",
                hp_max: 85,
                move_speed: 3.5,
                attack_base: 10,
                magic_power: 1.0,
                weapon_slots: 2,
                strength: 4,      // Low strength
                weight: 3,        // Very light
                dexterity: 9      // Extremely fast
            };
            break;
            
        case CharacterClass.ALCHEMIST:
            stats = {
                name: "Mad Chemist",
                hp_max: 90,
                move_speed: 2.5,
                attack_base: 8,
                magic_power: 1.5,
                weapon_slots: 2,
                strength: 4,      // Weak
                weight: 5,        // Average
                dexterity: 6      // Moderate
            };
            break;
    }
    
    return stats;
}


/// @function GetClassInnateModifiers(_class)
/// @description Returns array of permanent class modifier keys
function GetClassInnateModifiers(_class) {
    var mods = [];
    
    switch (_class) {
        case CharacterClass.WARRIOR:
            mods = ["warrior_rage", "armor_plating"];
            break;
            
        case CharacterClass.HOLY_MAGE:
            mods = ["mana_system", "blessed_ground"];
            break;
            
        case CharacterClass.VAMPIRE:
            mods = ["lifesteal_passive", "blood_frenzy"];
            break;
            
        case CharacterClass.BASEBALL_PLAYER:
            mods = ["homerun_chance", "baseball_rewards"];
            break;
            
        case CharacterClass.ASSASSIN:
            mods = ["critical_strikes", "shadow_step"];
            break;
            
        case CharacterClass.ALCHEMIST:
            mods = ["flask_master", "poison_mastery"];
            break;
    }
    
    return mods;
}

/// @function InitializeCharacterTags(_class_type)
function InitializeCharacterTags(_class_type) {
    var tags = new SynergyTags();
    
    switch (_class_type) {
        case CharacterClass.WARRIOR:
            tags.AddTag(SYNERGY_TAG.BRUTAL, "class_innate");
            tags.AddTag(SYNERGY_TAG.MELEE, "class_innate");
            tags.AddTag(SYNERGY_TAG.TANKY, "class_innate");
            break;
            
        case CharacterClass.HOLY_MAGE:
            tags.AddTag(SYNERGY_TAG.HOLY, "class_innate");
            tags.AddTag(SYNERGY_TAG.RANGED, "class_innate");
            tags.AddTag(SYNERGY_TAG.MAGE, "class_innate");
            break;
            
        case CharacterClass.VAMPIRE:
            tags.AddTag(SYNERGY_TAG.VAMPIRE, "class_innate");
            tags.AddTag(SYNERGY_TAG.LIFESTEAL, "class_innate");
            tags.AddTag(SYNERGY_TAG.SPEED, "class_innate");
            break;
    }
    
    return tags;
}

/// @function GetCharacterName(_class)
function GetCharacterName(_class) {
    switch (_class) {
        case CharacterClass.WARRIOR: return "WARRIOR";
        case CharacterClass.HOLY_MAGE: return "HOLY MAGE";
        case CharacterClass.VAMPIRE: return "VAMPIRE";
        case CharacterClass.BASEBALL_PLAYER: return "BASEBALL PLAYER";
        case CharacterClass.ASSASSIN: return "ASSASSIN";
        case CharacterClass.ALCHEMIST: return "ALCHEMIST";
        default: return "UNKNOWN";
    }
}


/// @function GetDefaultWeaponsForCharacter(_class)
function GetDefaultWeaponsForCharacter(_class) {
    switch (_class) {
        case CharacterClass.WARRIOR:
            return [Weapon.Sword, Weapon.Fists];
            
        case CharacterClass.HOLY_MAGE:
            return [Weapon.Staff, Weapon.Holy_Water];
            
        case CharacterClass.VAMPIRE:
            return [Weapon.Dagger, Weapon.Fists];
            
        default:
            return [Weapon.Fists, noone];
    }
}