

function GetCharacterStats(_class) {
    switch (_class) {
        case CharacterClass.VAMPIRE_HUNTER:
            return {
                name: "Vampire Hunter",
                hp_max: 120,
                move_speed: 2.5,
                attack_base: 12,
                magic_power: 1.0,
                weapon_slots: 2,
                strength: 6,
                weight: 6,
                dexterity: 6
            };
            
        case CharacterClass.PRIEST:
            return {
                name: "Priest",
                hp_max: 90,
                move_speed: 2,
                attack_base: 8,
                magic_power: 2.0,
                weapon_slots: 2,
                strength: 3,
                weight: 5,
                dexterity: 5,
                // Priest-specific
                mana_max: 100,
                mana_regen: 0.5,
                blessed_heal: 2
            };
            
        case CharacterClass.ALCHEMIST:
            return {
                name: "Alchemist",
                hp_max: 95,
                move_speed: 2.5,
                attack_base: 8,
                magic_power: 1.5,
                weapon_slots: 2,
                strength: 4,
                weight: 5,
                dexterity: 6,
                // Alchemist-specific
                flask_max: 3,
                flask_recharge: 600
            };
            
        case CharacterClass.BASEBALL_PLAYER:
            return {
                name: "Baseball Star",
                hp_max: 110,
                move_speed: 3,
                attack_base: 10,
                magic_power: 0.8,
                weapon_slots: 2,
                strength: 7,
                weight: 6,
                dexterity: 7,
                // Baseball-specific
                homerun_base_chance: 0.05
            };
            
        case CharacterClass.ASSASSIN:
            return {
                name: "Assassin",
                hp_max: 80,
                move_speed: 3.5,
                attack_base: 10,
                magic_power: 1.0,
                weapon_slots: 2,
                strength: 4,
                weight: 3,
                dexterity: 9,
                // Assassin-specific
                crit_chance: 0.15,
                crit_mult: 2.5,
                backstab_mult: 3.0
            };
            
        case CharacterClass.LEGACY:
            return {
                name: "Legacy",
                hp_max: 100,
                move_speed: 2.5,
                attack_base: 10,
                magic_power: 1.0,
                weapon_slots: 2,
                strength: 5,
                weight: 5,
                dexterity: 5
            };
            
        default:
            return GetCharacterStats(CharacterClass.VAMPIRE_HUNTER);
    }
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

function InitializeCharacterTags(_class_type) {
    var tags = new SynergyTags();
    
    switch (_class_type) {
        case CharacterClass.VAMPIRE_HUNTER:
            tags.AddTag(SYNERGY_TAG.MELEE, "class_innate");
            tags.AddTag(SYNERGY_TAG.RANGED, "class_innate");
            break;
            
        case CharacterClass.PRIEST:
            tags.AddTag(SYNERGY_TAG.HOLY, "class_innate");
            tags.AddTag(SYNERGY_TAG.MAGE, "class_innate");
            break;
            
        case CharacterClass.ALCHEMIST:
            tags.AddTag(SYNERGY_TAG.EXPLOSIVE, "class_innate");
            tags.AddTag(SYNERGY_TAG.ELEMENTAL, "class_innate");
            break;
            
        case CharacterClass.BASEBALL_PLAYER:
            tags.AddTag(SYNERGY_TAG.BLUNT, "class_innate");
            tags.AddTag(SYNERGY_TAG.ATHLETIC, "class_innate");
            break;
            
        case CharacterClass.ASSASSIN:
            tags.AddTag(SYNERGY_TAG.PIERCING, "class_innate");
            tags.AddTag(SYNERGY_TAG.SPEED, "class_innate");
            break;
            
        case CharacterClass.LEGACY:
            tags.AddTag(SYNERGY_TAG.MELEE, "class_innate");
            break;
    }
    
    return tags;
}

function GetCharacterName(_class) {
    switch (_class) {
        case CharacterClass.VAMPIRE_HUNTER: return "VAMPIRE HUNTER";
        case CharacterClass.PRIEST: return "PRIEST";
        case CharacterClass.ALCHEMIST: return "ALCHEMIST";
        case CharacterClass.BASEBALL_PLAYER: return "BASEBALL PLAYER";
        case CharacterClass.ASSASSIN: return "ASSASSIN";
        case CharacterClass.LEGACY: return "LEGACY";
        default: return "UNKNOWN";
    }
}


function GetDefaultWeaponsForCharacter(_class) {
    switch (_class) {
        case CharacterClass.VAMPIRE_HUNTER:
            return [Weapon.Sword, Weapon.Bow];
            
        case CharacterClass.PRIEST:
            return [Weapon.Staff, Weapon.Holy_Water];
            
        case CharacterClass.ALCHEMIST:
            return [Weapon.Dagger, Weapon.PotionBomb];
            
        case CharacterClass.BASEBALL_PLAYER:
            return [Weapon.BaseballBat, Weapon.BBallGun];
            
        case CharacterClass.ASSASSIN:
            return [Weapon.Dagger, Weapon.ThrowingKnife];
            
        case CharacterClass.LEGACY:
            return [Weapon.Sword, Weapon.Fists];
            
        default:
            return [Weapon.Fists, Weapon.None];
    }
}