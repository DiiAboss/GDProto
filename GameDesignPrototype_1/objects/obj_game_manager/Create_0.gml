/// @description obj_game_manager - Updated with Constructors
/// This replaces your current obj_game_manager code

// ==========================================
// ROOM ENUMS
// ==========================================

enum GAME_ROOM {
    MENU,
    CHARACTER_SELECT,
    GAMEPLAY,
    GAME_OVER,
    HIGHSCORE
}

// ==========================================
// CREATE EVENT
// ==========================================

// Make persistent
persistent = true;
depth = -999;

// Current room tracking
current_room_type = GAME_ROOM.MENU;

// ==========================================
// MANAGERS (Using Constructors!)
// ==========================================
pause_manager = new PauseManager();
score_manager = new ScoreManager();
time_manager = new TimeManager();
ui = new UIManager();
depth = -9999; // Draw on top of everything
// Setup time milestones
time_manager.SetupDefaultMilestones();

// Override milestone callback
time_manager.OnMilestoneReached = function(_milestone) {
    show_debug_message("MILESTONE: " + _milestone.name);
    
    // Trigger TARLHS commentary
    if (instance_exists(obj_tarlhs_narrator)) {
        var dialogue = "";
        
        switch (_milestone.time_seconds) {
            case 30:
                dialogue = "30 seconds... you're still alive. Barely.";
                break;
            case 60:
                dialogue = "One minute down. How long can you last?";
                break;
            case 120:
                dialogue = "Two minutes... you're starting to bore me.";
                break;
            case 180:
                dialogue = "Three minutes. Perhaps you're not completely helpless.";
                break;
            case 300:
                dialogue = "Five minutes! Now THIS is entertaining!";
                break;
            case 600:
                dialogue = "TEN MINUTES?! CARHL, increase the difficulty!";
                break;
        }
        
        if (dialogue != "") {
            obj_tarlhs_narrator.QueueDialogue(dialogue, "TARLHS", c_red, 150);
        }
    }
    
    // Spawn mini-boss every 2 minutes
    if (_milestone.time_seconds % 120 == 0 && _milestone.time_seconds > 0) {
        SpawnMiniBossWave();
    }
}

// Override second callback for per-second events
time_manager.OnSecondPassed = function() {
    // Example: increase difficulty over time
    // You can hook into your enemy spawner here
}

// ==========================================
// GAME STATE
// ==========================================

global.gameSpeed = 1;

// Player progression
player_level = 1;
player_experience = 0;

// Session tracking
games_played_this_session = 0;
total_deaths = 0;

// ==========================================
// SYSTEMS
// ==========================================

// Enemy controller
enemy_controller = noone;

// Chest system
chests_opened = 0;

// Modifier system
playerModsArray = [];  // Keep original name for compatibility
allMods = [];          // Keep original name for compatibility

// Totem system
chaos_totem_active = false;
chaos_spawn_timer = 0;
chaos_spawn_interval = 180;

champion_totem_active = false;
champion_spawn_timer = 0;
champion_spawn_interval = 2700;

// Weapon synergy
global.WeaponSynergies = {};
InitWeaponSynergySystem();

// Popup references
global.selection_popup = undefined;
global.chest_popup = undefined;
global.weapon_swap_prompt = undefined;

// ==========================================
// LOAD SYSTEMS
// ==========================================

LoadModifiers();
CreateUIManager();

// ==========================================
// HELPER FUNCTIONS
// ==========================================

/// @function LoadModifiers()
function LoadModifiers() {
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
            array_push(allMods, mods_data[i]);  // Use allMods (original name)
        }
        
        show_debug_message("Loaded " + string(array_length(allMods)) + " modifiers");
    } else {
        show_debug_message("WARNING: modifiers.json not found");
    }
}

/// @function CreateUIManager()
function CreateUIManager() {
    if (!instance_exists(obj_ui_manager)) {
        instance_create_depth(0, 0, -9999, obj_ui_manager);
    }
}

/// @function CreateEnemyController()
function CreateEnemyController() {
    if (!instance_exists(obj_enemy_controller)) {
        enemy_controller = instance_create_depth(x, y, depth, obj_enemy_controller);
    }
}

/// @function SpawnMiniBossWave()
function SpawnMiniBossWave() {
    if (!instance_exists(obj_player)) return;
    
    // Don't spawn if one already exists
    if (instance_number(obj_miniboss_parent) > 0) return;
    
    // Spawn at random edge
    var spawn_x = choose(
        obj_player.x + 400,
        obj_player.x - 400
    );
    var spawn_y = choose(
        obj_player.y + 300,
        obj_player.y - 300
    );
    
    var boss_type = choose(
        obj_miniboss_berserker,
        obj_miniboss_summoner,
        obj_miniboss_tank
    );
    
    instance_create_depth(spawn_x, spawn_y, 0, boss_type);
    
    show_debug_message("Mini-boss spawned!");
}

// ==========================================
// ROOM MANAGEMENT
// ==========================================

/// @function DetermineRoomType(_room_id)
/// @param {Asset.GMRoom} _room_id The room asset
/// @returns {enum.GAME_ROOM} Room type
function DetermineRoomType(_room_id) {
    // You'll need to replace these with your actual room names
    switch (_room_id) {

        case rm_main_menu:
            return GAME_ROOM.MENU;

            

        case rm_demo_room:
            return GAME_ROOM.GAMEPLAY;
            
        //case rm_game_over:
            //return GAME_ROOM.GAME_OVER;
            //
        //case rm_highscores:
            //return GAME_ROOM.HIGHSCORE;
            
        default:
            return GAME_ROOM.MENU;
    }
}

/// @function OnRoomStart(_room_type)
/// @param {enum.GAME_ROOM} _room_type Type of room entered
function OnRoomStart(_room_type) {
    current_room_type = _room_type;
    
    switch (_room_type) {
        case GAME_ROOM.MENU:
            HandleMenuStart();
            break;
            
        case GAME_ROOM.CHARACTER_SELECT:
            HandleCharacterSelectStart();
            break;
            
        case GAME_ROOM.GAMEPLAY:
            HandleGameplayStart();
            break;
            
        case GAME_ROOM.GAME_OVER:
            HandleGameOverStart();
            break;
            
        case GAME_ROOM.HIGHSCORE:
            HandleHighscoreStart();
            break;
    }
}

/// @function HandleMenuStart()
function HandleMenuStart() {
    // Reset game speed
    game_speed = 1.0;
    global.gameSpeed = game_speed;
    
    // Ensure UI manager exists
    CreateUIManager();
}

/// @function HandleCharacterSelectStart()
function HandleCharacterSelectStart() {
    // Reset for new game
    game_speed = 1.0;
    global.gameSpeed = game_speed;
}

/// @function HandleGameplayStart()
function HandleGameplayStart() {
    // Reset managers for new game
    score_manager.Reset();
    time_manager.Reset();
    
    // Start timer
    time_manager.Start();
    
    // Reset game state (keep original variable names)
    chests_opened = 0;
    playerModsArray = [];
    game_speed = 1.0;
    global.gameSpeed = game_speed;
    
    // Create systems
    CreateEnemyController();
    CreateUIManager();
    
    // Track session
    games_played_this_session++;
    
    show_debug_message("=== GAME START ===");
    show_debug_message("Score Manager Ready");
    show_debug_message("Time Manager Started");
}

/// @function HandleGameOverStart()
function HandleGameOverStart() {
    // Stop timer
    time_manager.Stop();
    
    // Get final stats
    var final_score = score_manager.GetScore();
    var final_time = time_manager.GetFormattedTime();
    var style_stats = score_manager.GetStyleStats();
    
    show_debug_message("=== GAME OVER ===");
    show_debug_message("Final Score: " + string(final_score));
    show_debug_message("Time Survived: " + final_time);
    show_debug_message("Perfect Kills: " + string(style_stats.perfect_timing_kills));
    
    // Save highscore (you'll implement this later)
    // SaveHighscore("Player", final_score, time_manager.GetTimeInSeconds(), player_level);
}

/// @function HandleHighscoreStart()
function HandleHighscoreStart() {
    // Load highscores
    // LoadHighscores();
}

// ==========================================
// GAME FLOW FUNCTIONS
// ==========================================

/// @function StartNewGame()
function StartNewGame() {
    room_goto(rm_demo_room); // Replace with your gameplay room
}

/// @function ReturnToMenu()
function ReturnToMenu() {
    room_goto(rm_main_menu); // Replace with your menu room
}

/// @function RestartGame()
function RestartGame() {
    room_restart();
}

// ==========================================
// STAT CALCULATION (your existing function)
// ==========================================

/// @function gm_calculate_player_stats(_atk, _hp, _kb, _spd)
function gm_calculate_player_stats(_atk, _hp, _kb, _spd) {
    // Apply modifier bonuses
    var atk_mult = 1.0;
    var hp_mult = 1.0;
    var kb_mult = 1.0;
    var spd_mult = 1.0;
    
    // Loop through active modifiers (using original array name)
    for (var i = 0; i < array_length(playerModsArray); i++) {
        var _mod = playerModsArray[i];
        
        // Apply stat multipliers from mods
        if (variable_struct_exists(_mod, "attack_mult")) {
            atk_mult *= _mod.attack_mult;
        }
        if (variable_struct_exists(_mod, "hp_mult")) {
            hp_mult *= _mod.hp_mult;
        }
        if (variable_struct_exists(_mod, "speed_mult")) {
            spd_mult *= _mod.speed_mult;
        }
    }
    
    return [
        _atk * atk_mult,
        _hp * hp_mult,
        _kb * kb_mult,
        _spd * spd_mult
    ];
}

// Slowdown effect settings
slowdown_active = false;
slowdown_timer = 0;
slowdown_duration = 30; // Frames for slowdown effect
slowdown_target = 0.1;  // Target speed during slowdown