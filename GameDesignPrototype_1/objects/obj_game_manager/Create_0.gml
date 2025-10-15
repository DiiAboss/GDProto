/// @desc Game Manager Initialization

global.gameSpeed = 1;

// Player progression
playerLevel = 1;
playerExperience = 0;
player_level = 1; // Keep for compatibility

// Chest system
chests_opened = 0;

// Modifier system
playerModsArray = [];
allMods = [];

// Totem system
chaos_totem_active = false;
chaos_spawn_timer = 0;
chaos_spawn_interval = 180; // 3 seconds

champion_totem_active = false;
champion_spawn_timer = 0;
champion_spawn_interval = 2700; // 45 seconds

// Score tracking
current_score = 0;

// Popup references (initialized as undefined)
global.selection_popup = undefined; // For level-ups
global.chest_popup = undefined;     // For chests

depth = -999;

// Create UI manager
instance_create_depth(0, 0, -9999, obj_ui_manager);

// ==========================================
// LOAD MODIFIERS FROM JSON
// ==========================================
var file = "modifiers.json";
if (file_exists(file)) {
    var f = file_text_open_read(file);
    var json_str = "";
    
    while (!file_text_eof(f)) {
        json_str += file_text_readln(f);
    }
    file_text_close(f);
    
    var mods_data = json_parse(json_str);
    
    for (var i = 0; i < array_length(mods_data); i++) {
        array_push(allMods, mods_data[i]);
    }
    
    show_debug_message("Loaded " + string(array_length(allMods)) + " modifiers");
} else {
    show_error("Could not find modifiers.json", true);
}

// Test mod
var _mod = get_mod_by_id("attack_up");
if (_mod != undefined) {
    array_push(playerModsArray, _mod);
}
