// Character class enum
enum CharacterClass {
	LEGACY,
	BASE,
    WARRIOR,
    HOLY_MAGE,
	PRIEST,
	VAMPIRE_HUNTER,
    VAMPIRE,
	BASEBALL_PLAYER,
	ALCHEMIST,
	ASSASSIN,
}

global.Player_Class = {
    Vampire_Hunter: {
        type: CharacterClass.VAMPIRE_HUNTER,
        name: "VAMPIRE HUNTER",
        desc: "Balanced fighter\nWeapon master",
        color: c_red,
        portrait: spr_vh_bg,
        sprites: {
            west:  spr_vh_walk_west,
            east:  spr_vh_walk_east,
            north: spr_vh_walk_north,
            south: spr_vh_walk_south
        }
    },
    
    Priest: {
        type: CharacterClass.PRIEST,
        name: "PRIEST",
        desc: "Holy magic\nArea control",
        color: c_aqua,
        portrait: spr_Baseball_Bg,
        sprites: {
            west:  spr_vh_walk_west,  // TODO: priest sprites
            east:  spr_vh_walk_east,
            north: spr_vh_walk_north,
            south: spr_vh_walk_south
        }
    },
    
    Alchemist: {
        type: CharacterClass.ALCHEMIST,
        name: "ALCHEMIST",
        desc: "Potions\nExplosives",
        color: c_green,
        portrait: spr_Baseball_Bg,
        sprites: {
            west:  spr_Alchemist_West,
            east:  spr_Alchemist_East,
            north: spr_Alchemist_North,
            south: spr_Alchemist_South
        }
    },
    
    Baseball_Player: {
        type: CharacterClass.BASEBALL_PLAYER,
        name: "BASEBALL PLAYER",
        desc: "Home runs\nKnockback king",
        color: c_lime,
        portrait: spr_Baseball_Bg,
        sprites: {
            west:  spr_BBallPlayer_West,
            east:  spr_BBallPlayer_East,
            north: spr_BBallPlayer_North,
            south: spr_BBallPlayer_South
        }
    },
    
    Assassin: {
        type: CharacterClass.ASSASSIN,
        name: "ASSASSIN",
        desc: "Critical hits\nHigh mobility",
        color: c_gray,
        portrait: spr_Baseball_Bg,
        sprites: {
            west:  spr_Assassin_West,
            east:  spr_Assassin_East,
            north: spr_Assassin_North,
            south: spr_Assassin_South
        }
    },
    
    Legacy: {
        type: CharacterClass.LEGACY,
        name: "LEGACY",
        desc: "The original\n???",
        color: c_white,
        portrait: spr_vh_bg,
        sprites: {
            west:  spr_vh_walk_west,
            east:  spr_vh_walk_east,
            north: spr_vh_walk_north,
            south: spr_vh_walk_south
        },
        locked: true  // Unlockable later
    }
}

/// @function GetPlayerClassData(_class_type)
/// @desc Get the Player_Class entry by CharacterClass enum
function GetPlayerClassData(_class_type) {
    var names = variable_struct_get_names(global.Player_Class);
    for (var i = 0; i < array_length(names); i++) {
        var entry = global.Player_Class[$ names[i]];
        if (entry.type == _class_type) return entry;
    }
    return global.Player_Class.Vampire_Hunter; // fallback
}

/// @function GetSelectedCharacterClass(_main_controller)
function GetSelectedCharacterClass(_main_controller) {
    return _main_controller.menu_system.selected_character_class;
}