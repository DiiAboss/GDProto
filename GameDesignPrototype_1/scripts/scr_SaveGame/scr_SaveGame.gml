/// @description Save/Load System for Career Progress
/// Handles unlocks, stats, settings


// SAVE DATA STRUCT
global.SaveData = {
    // Meta info
    version:     "1.0.1",
    last_played: date_current_datetime(),
    
    // Settings
    settings: {
        master_volume: 1.0,
        music_volume:  0.8,
        sfx_volume:    1.0,
        voice_volume:  1.0,
        screen_shake:  true
    },
    
    // Unlocks
    unlocks: {
	    characters: [CharacterClass.WARRIOR],
	    levels:     ["arena_1"],
	    weapons:    [Weapon.Sword, Weapon.Bow], // ADD THIS
	    modifiers:  [] // ADD THIS
    },
    
    // Career Stats
    career: {
        total_runs:   0,
        total_kills:  0,
        total_deaths: 0,
        total_score:  0,
        total_playtime_seconds: 0,
        
		currency: {
		    souls: 1,        // Meta currency (persists)
		    lifetime_souls: 0, // Total ever earned (for achievements)
		    lifetime_gold: 0   // Total ever earned (for stats)
		},
		tutorial: {
    soul_sold: false,
    menu_unlocked: false,
    back_button_unlocked: false,
    back_node_revealed: false,  // ADD THIS
    first_run_complete: false,
},
		
        // Best run
        best_score: 0,
        best_time_seconds: 0,
        best_character: CharacterClass.BASEBALL_PLAYER,
        
        // Arcade medals (from your scoring system)
        medals: {
            Dominoes: 0,
            Dribble:  0,
            Fore:	  0,
            Pocket:	  0,
            Bump: 	  0,
            Bulltrue: 0,
            ToSender: 0,
            BatBack:  0,
            Closed:	  0,
            ClosedForSeason: 0,
            TotemActivated: 0,
            GoodLuck:	 0,
            DoubleKill:	 0,
            TripleKill:	 0,
            MultiKill:	 0,
            MegaKill:	 0,
            MonsterKill: 0,
            SpikeKill:	 0,
            WallSplat:	 0,
            PitFall:	 0
        },
        
        // Per-character stats
        character_stats: {
		 runs : 0,
		},
		
		skill_tree: {
		    unlocked_nodes: [], // Array of node IDs
		    node_stacks: {} // For stackable stat boosts: {hp_boost_1: 3}
		},
		character_loadouts: {},
		active_loadout: [noone, noone, noone, noone, noone],
		character_weapon_loadouts: {},
		pregame_loadouts: {},             // Pre-game mods (from skill tree)
		active_loadout: [noone, noone, noone, noone, noone]  // Active pre-game
	},
	discovered_doors: {
        forest: {},
        desert: {},
        hell: {},
        tutorial: {}
    },
	
};

// Initialize character stats for each class
var char_classes = [CharacterClass.WARRIOR, CharacterClass.HOLY_MAGE, CharacterClass.VAMPIRE];
for (var i = 0; i < array_length(char_classes); i++) {
    var char_class = char_classes[i];
    global.SaveData.career.character_stats[$ char_class] = {
        runs:	 0,
        kills:	 0,
        deaths:	 0,
        best_score:	 0,
        best_time:	 0,
        total_playtime: 0
    };
}


/// @function GetCharacterWeaponLoadout(_character_class)
function GetCharacterWeaponLoadout(_character_class) {
    
    // DON'T reset the entire loadouts structure!
    // Ensure it exists as a STRUCT, not an array
    if (!variable_struct_exists(global.SaveData.career, "character_weapon_loadouts") || 
        !is_struct(global.SaveData.career.character_weapon_loadouts)) {
        global.SaveData.career.character_weapon_loadouts = {}; // ← STRUCT, not array
    }
    
    var key = string(_character_class);
    
    // If this character doesn't have a loadout yet, create default
    if (!variable_struct_exists(global.SaveData.career.character_weapon_loadouts, key)) {
        var default_weapons = GetDefaultWeaponsForCharacter(_character_class);
        global.SaveData.career.character_weapon_loadouts[$ key] = default_weapons;
    }
    
    return global.SaveData.career.character_weapon_loadouts[$ key];
}

/// @function SaveCharacterWeaponLoadout(_character_class, _weapon_array)
function SaveCharacterWeaponLoadout(_character_class, _weapon_array) {
    // Ensure the structure exists
    if (!variable_struct_exists(global.SaveData.career, "character_weapon_loadouts") || 
        !is_struct(global.SaveData.career.character_weapon_loadouts)) {
        global.SaveData.career.character_weapon_loadouts = {};
    }
    
    var key = string(_character_class);
    global.SaveData.career.character_weapon_loadouts[$ key] = _weapon_array;
    SaveGame();
}



/// @function GetUnlockedWeaponsForCharacter(_character_class)
function GetUnlockedWeaponsForCharacter(_character_class) {
    var unlocked_weapons = [];
    var node_keys = variable_struct_get_names(global.SkillTree);
    
    // Add default weapon(s)
    var defaults = GetDefaultWeaponsForCharacter(_character_class);
    for (var i = 0; i < array_length(defaults); i++) {
        if (defaults[i] != noone && !array_contains(unlocked_weapons, defaults[i])) {
            array_push(unlocked_weapons, defaults[i]);
        }
    }
    
    // Add unlocked weapons from skill tree
    for (var i = 0; i < array_length(node_keys); i++) {
        var key = node_keys[i];
        var node = global.SkillTree[$ key];
        
        // Only weapon_unlock type nodes
        if (node.type != "weapon_unlock") continue;
        if (!node.unlocked) continue;
        
        // Check character restriction (if any)
        if (variable_struct_exists(node, "required_character")) {
            if (node.required_character != _character_class) {
                continue;
            }
        }
        
        // Add weapon if not already in list
        if (variable_struct_exists(node, "weapon")) {
            var weapon = node.weapon;
            if (!array_contains(unlocked_weapons, weapon)) {
                array_push(unlocked_weapons, weapon);
            }
        }
    }
    
    return unlocked_weapons;
}


/// @function GetWeaponSprite(_weapon_enum)
function GetWeaponSprite(_weapon_enum) {
    switch (_weapon_enum) {
        case Weapon.Sword: return spr_sword;
        //case Weapon.Bow: return spr_bow;
        case Weapon.Dagger: return spr_dagger;
        case Weapon.Boomerang: return spr_boomerang;
        //case Weapon.ChargeCannon: return spr_charge_cannon; // Update sprite name
        case Weapon.BaseballBat: return spr_way_better_bat;
        case Weapon.Holy_Water: return spr_holy_water; // Update sprite name
        default: return spr_mod_default;
    }
}

/// @function IsWeaponEquipped(_weapon, _weapon_array)
function IsWeaponEquipped(_weapon, _weapon_array) {
    return array_contains(_weapon_array, _weapon);
}

/// @function SaveGame()
/// @description Save all persistent data to file
function SaveGame() {
    show_debug_message("=== SAVING GAME ===");
    
    // Update last played time
    global.SaveData.last_played = date_current_datetime();
    
    // === CRITICAL: SYNC SKILL TREE STATE ===
    InitializeSkillTreeSaveData(); // Ensure structure exists
    
    // Clear and rebuild unlocked nodes list
    global.SaveData.career.skill_tree.unlocked_nodes = [];
    global.SaveData.career.skill_tree.node_stacks = {};
    
    var node_keys = variable_struct_get_names(global.SkillTree);
    for (var i = 0; i < array_length(node_keys); i++) {
        var key = node_keys[i];
        var node = global.SkillTree[$ key];
        
        // Save unlocked status
        if (node.unlocked) {
            array_push(global.SaveData.career.skill_tree.unlocked_nodes, key);
        }
        
        // Save stack counts
        if (variable_struct_exists(node, "current_stacks") && node.current_stacks > 0) {
            global.SaveData.career.skill_tree.node_stacks[$ key] = node.current_stacks;
        }
    }
    
    // === SYNC SOULS ===
    global.SaveData.career.currency.souls = global.Souls;
    
    
    // === SYNC CHARACTER LOADOUTS ===
    if (variable_struct_exists(global.SaveData, "character_weapon_loadouts")) {
        // Already handled by SaveCharacterWeaponLoadout
    }
    
    // Convert struct to JSON string
    var json_string = json_stringify(global.SaveData);
    
    // Save to file
    var file = file_text_open_write("tarlhs_save.json");
    file_text_write_string(file, json_string);
    file_text_close(file);
    
    show_debug_message("Game saved successfully!");
    show_debug_message("  Souls: " + string(global.SaveData.career.currency.souls));
    show_debug_message("  Unlocked nodes: " + string(array_length(global.SaveData.career.skill_tree.unlocked_nodes)));
}

/// @function LoadGame()
/// @description Load persistent data from file
/// @returns {bool} Success
function LoadGame() {
    show_debug_message("=== LOADING GAME ===");
    
    // Check if save file exists
    if (!file_exists("tarlhs_save.json")) {
        show_debug_message("No save file found - using default data");
        return false;
    }
    
    try {
        // Read file
        var file = file_text_open_read("tarlhs_save.json");
        var json_string = file_text_read_string(file);
        file_text_close(file);
        
        // Parse JSON
        var loaded_data = json_parse(json_string);
        
        // Merge with global.SaveData (in case new fields added in updates)
        MergeSaveData(loaded_data);
        
        show_debug_message("Game loaded successfully!");
        return true;
        
    } catch(error) {
        show_debug_message("ERROR loading save file: " + string(error));
        return false;
    }
}

/// @function MergeSaveData(_loaded)
/// @description Merge loaded data with default structure (handles version updates)
function MergeSaveData(_loaded) {
    // Settings
    if (variable_struct_exists(_loaded, "settings")) {
        var settings_keys = variable_struct_get_names(_loaded.settings);
        for (var i = 0; i < array_length(settings_keys); i++) {
            var key = settings_keys[i];
            global.SaveData.settings[$ key] = _loaded.settings[$ key];
        }
    }
    
    // Unlocks
    if (variable_struct_exists(_loaded, "unlocks")) {
        global.SaveData.unlocks = _loaded.unlocks;
    }
	
	// After loading SaveData from JSON
	if (!variable_struct_exists(global.SaveData.career, "active_loadout")) {
	    global.SaveData.career.active_loadout = [noone, noone, noone, noone, noone];
	}
    
    // Career stats
    if (variable_struct_exists(_loaded, "career")) {
        // Copy all career fields
        var career_keys = variable_struct_get_names(_loaded.career);
        for (var i = 0; i < array_length(career_keys); i++) {
            var key = career_keys[i];
            global.SaveData.career[$ key] = _loaded.career[$ key];
        }
    }
    
    // === CRITICAL: RESTORE SKILL TREE STATE ===
    InitializeSkillTreeSaveData(); // Ensure structure exists
    
    if (variable_struct_exists(global.SaveData.career, "skill_tree")) {
        var unlocked = global.SaveData.career.skill_tree.unlocked_nodes;
        var stacks = global.SaveData.career.skill_tree.node_stacks;
        
        // Apply unlocked status to actual nodes
        for (var i = 0; i < array_length(unlocked); i++) {
            var node_id = unlocked[i];
            if (variable_struct_exists(global.SkillTree, node_id)) {
                global.SkillTree[$ node_id].unlocked = true;
                show_debug_message("  Restored node: " + node_id);
            } else {
                show_debug_message("  WARNING: Unknown node in save: " + node_id);
            }
        }
        
        // Apply stack counts
        var stack_keys = variable_struct_get_names(stacks);
        for (var i = 0; i < array_length(stack_keys); i++) {
            var node_id = stack_keys[i];
            if (variable_struct_exists(global.SkillTree, node_id)) {
                global.SkillTree[$ node_id].current_stacks = stacks[$ node_id];
            }
        }
        
        show_debug_message("Skill tree loaded: " + string(array_length(unlocked)) + " nodes unlocked");
    }
    
    // === RESTORE SOULS ===
        global.Souls = global.SaveData.career.currency.souls;
        show_debug_message("Souls loaded: " + string(global.Souls));
    
}


function GetGold() {

        return obj_game_manager.current_gold;
 
}


// STAT TRACKING FUNCTIONS


/// @function RecordRunStart(_character_class)
function RecordRunStart(_character_class) {
    // Ensure character_stats exists
    if (!variable_struct_exists(global.SaveData.career, "character_stats")) {
        global.SaveData.career.character_stats = {};
    }
    
    var key = string(_character_class);
    
    // Ensure this character has a stats entry
    if (!variable_struct_exists(global.SaveData.career.character_stats, key)) {
        global.SaveData.career.character_stats[$ key] = {
            runs: 0,
            kills: 0,
            deaths: 0,
            total_score: 0,
            best_score: 0,
            total_time_seconds: 0,
            best_time_seconds: 0
        };
    }
    
    // Increment run counter
    global.SaveData.career.character_stats[$ key].runs++;
    global.SaveData.career.total_runs++;
    
    show_debug_message("Run started for " + string(_character_class) + " (Run #" + string(global.SaveData.career.character_stats[$ key].runs) + ")");
}

/// @function RecordRunEnd(_character, _score, _time_seconds, _kills)
function RecordRunEnd(_character, _score, _time_seconds, _kills) {
    // Update totals
    global.SaveData.career.total_kills += _kills;
    global.SaveData.career.total_score += _score;
    
    // Update best run
    if (_score > global.SaveData.career.best_score) {
        global.SaveData.career.best_score = _score;
        global.SaveData.career.best_time_seconds = _time_seconds;
        global.SaveData.career.best_character = _character;
    }
    
    // Update character-specific stats
    var char_stats = global.SaveData.career.character_stats[$ _character];
    char_stats.kills += _kills;
    
    if (_score > char_stats.best_score) {
        char_stats.best_score = _score;
        char_stats.best_time = _time_seconds;
    }
    
    // Calculate playtime
    if (variable_global_exists("run_start_time")) {
        var playtime = (current_time - global.run_start_time) / 1000; // Convert to seconds
        global.SaveData.career.total_playtime_seconds += playtime;
        char_stats.total_playtime += playtime;
    }
    
    SaveGame();
}

/// @function RecordDeath(_character)
function RecordDeath(_character) {
    global.SaveData.career.total_deaths++;
    global.SaveData.career.character_stats[$ _character].deaths++;
    SaveGame();
}

/// @function RecordMedalEarned(_medal_key)
function RecordMedalEarned(_medal_key) {
    if (variable_struct_exists(global.SaveData.career.medals, _medal_key)) {
        global.SaveData.career.medals[$ _medal_key]++;
    }
}

/// @function GetCareerStats()
/// @returns {struct} Copy of career stats for display
function GetCareerStats() {
    return global.SaveData.career;
}


// SETTINGS FUNCTIONS


/// @function SaveSettings(_settings_struct)
function SaveSettings(_settings_struct) {
    global.SaveData.settings = _settings_struct;
    SaveGame();
}

/// @function GetSettings()
/// @returns {struct} Current settings
function GetSettings() {
    return global.SaveData.settings;
}


// INITIALIZATION


/// @function InitializeSaveSystem()
/// @description Call this in obj_main_controller Create
function InitializeSaveSystem() {
    show_debug_message("=== INITIALIZING SAVE SYSTEM ===");
    
    // Try to load existing save
    var loaded = LoadGame();
    
    if (!loaded) {
        show_debug_message("Using default save data");
        // Save default data to create initial save file
        SaveGame();
    }
    
    show_debug_message("=== SAVE SYSTEM READY ===");
}

    
/// @function ResetSaveData()
function ResetSaveData() {
    // Delete the save file
    if (file_exists("save.json")) {
        file_delete("save.json");
    }
    
    // Reinitialize global save data with YOUR ACTUAL STRUCTURE
    global.SaveData = {
        // Meta info
        version: "1.0.1",
        last_played: date_current_datetime(),
        
        // Settings
        settings: {
            master_volume: 1.0,
            music_volume: 0.8,
            sfx_volume: 1.0,
            voice_volume: 1.0,
            screen_shake: true
        },
        
        // Unlocks
        unlocks: {
            characters: [CharacterClass.WARRIOR],
            levels: ["arena_1"],
            weapons: [Weapon.Sword, Weapon.Bow],
            modifiers: []
        },
        
        // Career Stats
        career: {
            total_runs: 0,
            total_kills: 0,
            total_deaths: 0,
            total_score: 0,
            total_playtime_seconds: 0,
            
            currency: {
                souls: 1,
                lifetime_souls: 0,
                lifetime_gold: 0
            },
            tutorial: {
    soul_sold: false,
    menu_unlocked: false,
    back_button_unlocked: false,
    back_node_revealed: false,  // ADD THIS
    first_run_complete: false,
},
            best_score: 0,
            best_time_seconds: 0,
            best_character: CharacterClass.WARRIOR,
            
            medals: {
                Dominoes: 0,
                Dribble: 0,
                Fore: 0,
                Pocket: 0,
                Bump: 0,
                Bulltrue: 0,
                ToSender: 0,
                BatBack: 0,
                Closed: 0,
                ClosedForSeason: 0,
                TotemActivated: 0,
                GoodLuck: 0,
                DoubleKill: 0,
                TripleKill: 0,
                MultiKill: 0,
                MegaKill: 0,
                MonsterKill: 0,
                SpikeKill: 0,
                WallSplat: 0,
                PitFall: 0
            },
            
            character_stats: {},
            
            skill_tree: {
                unlocked_nodes: [],
                node_stacks: {}
            },
            
            character_loadouts: {},
            active_loadout: [noone, noone, noone, noone, noone],
            character_weapon_loadouts: {},
            pregame_loadouts: {},
            //active_loadout: [noone, noone, noone, noone, noone]
        }
    };
    
    // Reset global souls
    global.Souls = 1;
    
    // Reset skill tree
    var node_keys = variable_struct_get_names(global.SkillTree);
    for (var i = 0; i < array_length(node_keys); i++) {
        var key = node_keys[i];
        var node = global.SkillTree[$ key];
        node.unlocked = (key == "root");
        if (variable_struct_exists(node, "current_stacks")) {
            node.current_stacks = 0;
        }
    }
    
    SaveGame();
    
    show_debug_message("Save data reset!");
}