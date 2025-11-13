/// @description Save/Load System for Career Progress
/// Handles unlocks, stats, settings


// SAVE DATA STRUCT
global.SaveData = {
    // Meta info
    version:     "0.0.1",
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
        characters: [CharacterClass.WARRIOR], // Start with warrior unlocked
        levels:     ["arena_1"] // Start with one level
    },
    
    // Career Stats
    career: {
        total_runs:   0,
        total_kills:  0,
        total_deaths: 0,
        total_score:  0,
        total_playtime_seconds: 0,
        
		currency: {
		    souls: 0,        // Meta currency (persists)
		    lifetime_souls: 0, // Total ever earned (for achievements)
		    lifetime_gold: 0   // Total ever earned (for stats)
		},
		
        // Best run
        best_score: 0,
        best_time_seconds: 0,
        best_character: CharacterClass.WARRIOR,
        
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
        character_stats: {},
		
		skill_tree: {
		    unlocked_nodes: ["root"], // Array of node IDs
		    node_stacks: {} // For stackable stat boosts: {hp_boost_1: 3}
		}
    }
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


// SAVE FUNCTIONS


/// @function SaveGame()
/// @description Save all persistent data to file
function SaveGame() {
    show_debug_message("=== SAVING GAME ===");
    
    // Update last played time
    global.SaveData.last_played = date_current_datetime();
    
    // Convert struct to JSON string
    var json_string = json_stringify(global.SaveData);
    
    // Save to file
    var file = file_text_open_write("tarlhs_save.json");
    file_text_write_string(file, json_string);
    file_text_close(file);
    
    show_debug_message("Game saved successfully!");
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
    
    // Career stats
    if (variable_struct_exists(_loaded, "career")) {
        // Copy all career fields
        var career_keys = variable_struct_get_names(_loaded.career);
        for (var i = 0; i < array_length(career_keys); i++) {
            var key = career_keys[i];
            global.SaveData.career[$ key] = _loaded.career[$ key];
        }
    }
}

/// @function ResetSaveData()
/// @description Delete save file and reset to defaults
function ResetSaveData() {
    if (file_exists("tarlhs_save.json")) {
        file_delete("tarlhs_save.json");
    }
    
    // Reinitialize default data
    // (Copy the initialization code from top of this script)
    show_debug_message("Save data reset!");
}


// UNLOCK FUNCTIONS


/// @function IsCharacterUnlocked(_class)
function IsCharacterUnlocked(_class) {
    return array_contains(global.SaveData.unlocks.characters, _class);
}

/// @function UnlockCharacter(_class)
function UnlockCharacter(_class) {
    if (!IsCharacterUnlocked(_class)) {
        array_push(global.SaveData.unlocks.characters, _class);
        SaveGame();
        show_debug_message("Unlocked character: " + string(_class));
        return true;
    }
    return false;
}

/// @function IsLevelUnlocked(_level_id)
function IsLevelUnlocked(_level_id) {
    return array_contains(global.SaveData.unlocks.levels, _level_id);
}

/// @function UnlockLevel(_level_id)
function UnlockLevel(_level_id) {
    if (!IsLevelUnlocked(_level_id)) {
        array_push(global.SaveData.unlocks.levels, _level_id);
        SaveGame();
        show_debug_message("Unlocked level: " + _level_id);
        return true;
    }
    return false;
}


// ==========================================
// CURRENCY FUNCTIONS
// ==========================================

/// @function AddSouls(_amount)
/// @description Add souls (meta currency) to player's account
function AddSouls(_amount) {
    global.SaveData.career.currency.souls += _amount;
    global.SaveData.career.currency.lifetime_souls += _amount;
    SaveGame();
    
    show_debug_message("Gained " + string(_amount) + " souls! Total: " + string(global.SaveData.career.currency.souls));
}

/// @function AddGold(_amount)
/// @description Add gold (in-run currency) - NOT saved between runs
function AddGold(_amount) {
    // Gold is tracked in run, not saved directly
    if (instance_exists(obj_game_manager)) {
        obj_game_manager.current_gold += _amount;
    }
    
    // Track lifetime total
    global.SaveData.career.currency.lifetime_gold += _amount;
}

/// @function SpendSouls(_amount)
/// @returns {bool} Success
function SpendSouls(_amount) {
    if (global.SaveData.career.currency.souls >= _amount) {
        global.SaveData.career.currency.souls -= _amount;
        SaveGame();
        show_debug_message("Spent " + string(_amount) + " souls! Remaining: " + string(global.SaveData.career.currency.souls));
        return true;
    }
    show_debug_message("Not enough souls! Need " + string(_amount) + ", have " + string(global.SaveData.career.currency.souls));
    return false;
}

/// @function GetSouls()
/// @returns {real} Current soul count
function GetSouls() {
    return global.SaveData.career.currency.souls;
}

/// @function GetGold()
/// @returns {real} Current run gold
function GetGold() {

        return obj_game_manager.current_gold;
 
}


// STAT TRACKING FUNCTIONS


/// @function RecordRunStart(_character)
function RecordRunStart(_character) {
    global.SaveData.career.total_runs++;
    global.SaveData.career.character_stats[$ _character].runs++;
    
    // Track start time for playtime calculation
    global.run_start_time = current_time;
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