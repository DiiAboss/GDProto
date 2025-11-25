/// @desc obj_game_manager Create Event - GAMEPLAY ONLY
show_debug_message("GameManager CREATED: " + string(id) + " | room: " + room_get_name(room));
depth = -999;

can_click = true;

level_up_slowdown_active = false;
level_up_slowdown_timer = 0;
level_up_slowdown_duration = 60; // 0.5 seconds at 60fps


// MANAGERS

pause_manager = new PauseManager();
score_manager = new ScoreManager();
time_manager  = new TimeManager();
ui            = new UIManager();
score_display = new ScoreDisplayManager();

time_manager.SetupDefaultMilestones();

time_manager.OnMilestoneReached = function(_milestone) {
    
    
    if (_milestone.time_seconds % 120 == 0 && _milestone.time_seconds > 0) {
        SpawnMiniBossWave();
    }
};

time_manager.OnSecondPassed = function() {
    // Per-second events
};


// GAME STATE

global.gameSpeed = 1;

player_level = 1;
player_experience = 0;

games_played_this_session = 0;
total_deaths = 0;


// SYSTEMS

enemy_controller = noone;
chests_opened = 0;

playerModsArray = [];
allMods = [];

chaos_totem_active = false;
chaos_spawn_timer = 0;
chaos_spawn_interval = 3000;

champion_totem_active = false;
champion_spawn_timer = 0;
champion_spawn_interval = 2700;

slowdown_active = false;
slowdown_timer = 0;
slowdown_duration = 30;
slowdown_target = 0.1;


// LOAD SYSTEMS

LoadModifiers();
CreateUIManager();


// FUNCTIONS


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
            array_push(allMods, mods_data[i]);
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
    if (instance_number(obj_miniboss_parent) > 0) return;
    
    var spawn_x = choose(obj_player.x + 400, obj_player.x - 400);
    var spawn_y = choose(obj_player.y + 300, obj_player.y - 300);
    var boss_type = choose(obj_miniboss_berserker, obj_miniboss_summoner, obj_miniboss_tank);
    
    instance_create_depth(spawn_x, spawn_y, 0, boss_type);
}


/// @function gm_trigger_event(trigger, player, extra)
function gm_trigger_event(trigger, player, extra) {
    for (var i = 0; i < array_length(playerModsArray); i++) {
        var m = playerModsArray[i];
        if (m.trigger == trigger && is_callable(m.effect)) {
            m.effect(player, m, extra);
        }
    }
}

/// @function gm_calculate_player_stats(_atk, _hp, _kb, _spd)
function gm_calculate_player_stats(_atk, _hp, _kb, _spd) {
    var atk_mult = 1.0;
    var hp_mult  = 1.0;
    var kb_mult  = 1.0;
    var spd_mult = 1.0;
	
	var weight_mult = 1.0;
    var luck_mult   = 1.0;
	
	var atk_rate_mult = 1.0;
	var iframe_mult   = 1.0;
	
	
	// Cycle through the playerModsArray
    for (var i = 0; i < array_length(playerModsArray); i++) {
        var _mod = playerModsArray[i];
        
        if (variable_struct_exists(_mod, "attack_mult")) atk_mult *= _mod.attack_mult;
        if (variable_struct_exists(_mod, "attack_add"))  atk_mult += _mod.attack_add / _atk;
			
		
        if (variable_struct_exists(_mod, "hp_mult")) hp_mult *= _mod.hp_mult;
        if (variable_struct_exists(_mod, "hp_add")) hp_mult += _mod.hp_add / _hp;
			
		
        if (variable_struct_exists(_mod, "speed_mult")) spd_mult *= _mod.speed_mult;
    }
    
	
	var _new_atk  = _atk * atk_mult;
	var _new_hp   = _hp  * hp_mult;
	var _new_kb   = _kb  * kb_mult;
	var _new_spd  = _spd  * kb_mult;
	
	var return_array = [
	_new_atk,
	_new_hp,
	_new_kb,
	_new_spd
	]
	
    return return_array;
}

/// @function OnChestOpening(_chest)
function OnChestOpening(_chest) {
    slowdown_active = true;
    slowdown_timer = 0;
    
    call_later(slowdown_duration, time_source_units_frames, function() {
        pause_manager.Pause(PAUSE_REASON.CHEST_OPENING, 0);
    });
}

/// @function OnChestClosing(_chest)
function OnChestClosing(_chest) {
    pause_manager.Resume(PAUSE_REASON.CHEST_OPENING);
}


// ROOM MANAGEMENT (Keep for Other_4 compatibility)



function HandleGameplayStart() {
    score_manager.Reset();
    time_manager.Reset();
    time_manager.Start();
    
    chests_opened = 0;
    playerModsArray = [];
    game_speed = 1.0;
    //global.gameSpeed = 1;
    
    CreateEnemyController();
    CreateUIManager();
    
    games_played_this_session++;

}

function HandleGameOverStart() {
    time_manager.Stop();
    
    var final_score = score_manager.GetScore();
    var final_time = time_manager.GetFormattedTime();
    var style_stats = score_manager.GetStyleStats();
}

function HandleHighscoreStart() {
    // Future highscore loading
}


/// @function ShowLevelUpPopup()
function ShowLevelUpPopup(_can_click) {
    if (global.selection_popup != noone || _can_click == false) {
        return;
    }
    
    var options = [];
    var available_mods = GetAvailableModifiers();
    
    if (array_length(available_mods) == 0) {
        pause_manager.Resume(PAUSE_REASON.LEVEL_UP);
        return;
    }
    
    // Separate new mods from upgrades
    var new_mods = [];
    var upgrade_mods = [];
    
    for (var i = 0; i < array_length(available_mods); i++) {
        if (available_mods[i].is_upgrade) {
            array_push(upgrade_mods, available_mods[i]);
        } else {
            array_push(new_mods, available_mods[i]);
        }
    }
    
    // Pick 3 random mods (guarantee 1 upgrade if player has mods)
    var chosen_mods = [];
    var guaranteed_upgrade = array_length(upgrade_mods) > 0 && array_length(obj_player.mod_list) > 0;
    
    for (var i = 0; i < 3; i++) {
        if (i == 0 && guaranteed_upgrade && array_length(upgrade_mods) > 0) {
            var random_index = irandom(array_length(upgrade_mods) - 1);
            array_push(chosen_mods, upgrade_mods[random_index]);
            array_delete(upgrade_mods, random_index, 1);
            continue;
        }
        
        // Pick from combined pool
        var combined = [];
        for (var j = 0; j < array_length(new_mods); j++) array_push(combined, new_mods[j]);
        for (var j = 0; j < array_length(upgrade_mods); j++) array_push(combined, upgrade_mods[j]);
        
        if (array_length(combined) == 0) break;
        
        var random_index = irandom(array_length(combined) - 1);
        var picked = combined[random_index];
        array_push(chosen_mods, picked);
        
        // Remove from source array
        if (picked.is_upgrade) {
            for (var j = 0; j < array_length(upgrade_mods); j++) {
                if (upgrade_mods[j].key == picked.key) {
                    array_delete(upgrade_mods, j, 1);
                    break;
                }
            }
        } else {
            for (var j = 0; j < array_length(new_mods); j++) {
                if (new_mods[j].key == picked.key) {
                    array_delete(new_mods, j, 1);
                    break;
                }
            }
        }
    }
    
    // Shuffle so upgrade isn't always first
    for (var i = array_length(chosen_mods) - 1; i > 0; i--) {
        var j = irandom(i);
        var temp = chosen_mods[i];
        chosen_mods[i] = chosen_mods[j];
        chosen_mods[j] = temp;
    }
    
    // Build option structs
    for (var i = 0; i < array_length(chosen_mods); i++) {
        var mod_info = chosen_mods[i];
        var mod_key = mod_info.key;
        var mod_data = global.Modifiers[$ mod_key];
        
        var mod_sprite = GetModifierSprite(mod_key);
        
        // Build description
        var desc = "A powerful modifier";
        if (variable_struct_exists(mod_data, "description")) {
            desc = mod_data.description;
        }
        
        if (mod_info.is_upgrade) {
            desc = "Lv" + string(mod_info.current_level) + " → Lv" + string(mod_info.current_level + 1) + "\n" + desc;
        }
        
        var mod_name = mod_key;
        if (variable_struct_exists(mod_data, "name")) {
            mod_name = mod_data.name;
        }
        
        array_push(options, {
            name: mod_name,
            desc: desc,
            sprite: mod_sprite,
            mod_key: mod_key,
            current_level: mod_info.current_level,
            max_level: mod_info.max_level,
            is_upgrade: mod_info.is_upgrade
        });
    }
    
    // Callback
    function on_modifier_select(index, option) {
        if (option.is_upgrade) {
            for (var j = 0; j < array_length(obj_player.mod_list); j++) {
                if (obj_player.mod_list[j].template_key == option.mod_key) {
                    obj_player.mod_list[j].stack_level++;
                    break;
                }
            }
            CalculateCachedStats(obj_player);
        } else {
            AddModifier(obj_player, option.mod_key);
        }
        
        obj_game_manager.pause_manager.Resume(PAUSE_REASON.LEVEL_UP);
    }
    
    pause_manager.Pause(PAUSE_REASON.LEVEL_UP, 0);
    
    global.selection_popup = new SelectionPopup(
        display_get_gui_width() / 2,
        display_get_gui_height() / 2,
        options,
        on_modifier_select
    );
}
/// @function GetModifierRarityColor(_mod_key)
/// @description Returns a color based on modifier's synergy tags
function GetModifierRarityColor(_mod_key) {
    var template = global.Modifiers[$ _mod_key];
    if (template == undefined) return c_white;
    
    var tags = template.synergy_tags ?? [];
    
    for (var i = 0; i < array_length(tags); i++) {
        switch (tags[i]) {
            case SYNERGY_TAG.FIRE: return make_color_rgb(255, 100, 50);
            case SYNERGY_TAG.ICE: return make_color_rgb(100, 200, 255);
            case SYNERGY_TAG.LIGHTNING: return make_color_rgb(180, 100, 255);
            case SYNERGY_TAG.POISON: return make_color_rgb(100, 255, 100);
            case SYNERGY_TAG.LIFESTEAL: return make_color_rgb(255, 50, 80);
            case SYNERGY_TAG.EXPLOSIVE: return make_color_rgb(255, 150, 50);
        }
    }
    
    return c_white;
}

/// @function GetAvailableModifiers()
/// @returns {array} Array of {key, current_level, is_upgrade, max_level} structs
function GetAvailableModifiers() {
    var available = [];
    var mod_keys = struct_get_names(global.Modifiers);
    
    for (var i = 0; i < array_length(mod_keys); i++) {
        var key = mod_keys[i];
        var template = global.Modifiers[$ key];
        
        // Get max level - use variable_struct_exists to avoid the error
        var max_level = 5; // default
        if (variable_struct_exists(template, "max_level")) {
            max_level = template.max_level;
        }
        
        // Skip innate modifiers (class abilities)
        if (variable_struct_exists(template, "is_innate") && template.is_innate) {
            continue;
        }
        
        // Check if player already has this modifier
        var current_level = 0;
        var existing_mod = noone;
        
        for (var j = 0; j < array_length(obj_player.mod_list); j++) {
            if (obj_player.mod_list[j].template_key == key) {
                existing_mod = obj_player.mod_list[j];
                current_level = 1;
                if (variable_struct_exists(existing_mod, "stack_level")) {
                    current_level = existing_mod.stack_level;
                }
                break;
            }
        }
        
        // Include if: doesn't have it OR has it but can upgrade
        if (existing_mod == noone) {
            array_push(available, {
                key: key,
                current_level: 0,
                is_upgrade: false,
                max_level: max_level
            });
        } else if (current_level < max_level) {
            array_push(available, {
                key: key,
                current_level: current_level,
                is_upgrade: true,
                max_level: max_level
            });
        }
    }
    
    return available;
}

/// @function GetModifierSprite(_mod_key)
/// @param {string} _mod_key Modifier key
/// @returns {Asset.GMSprite} Sprite for this modifier
function GetModifierSprite(_mod_key) {
    // Direct sprite mapping - asset_get_index doesn't work reliably
    switch (_mod_key) {
        case "TripleRhythmFire":
            return spr_mod_TripleRhythmFire;
        case "SpreadFire":
            return spr_mod_SpreadFire;
        case "DoubleLightning":
            return spr_mod_DoubleLightning;
        case "ChainLightning":
            return spr_mod_ChainLightning;
        case "StaticCharge":
            return spr_mod_StaticCharge;
        case "ThunderStrike":
            return spr_mod_ThunderStrike;
        case "DeathFireworks":
            return spr_mod_DeathFireworks;
        case "PoisonCorpse":
            return spr_mod_PoisonCorpse;
        case "ChainReaction":
            return spr_mod_ChainReaction;
        case "MultiShot":
            return spr_mod_MultiShot;
        case "BurstFire":
            return spr_mod_BurstFire;
        default:
            // Fallback
            if (sprite_exists(spr_mod_default)) {
                return spr_mod_default;
            }
            return -1; // No sprite available
    }
}

/// @function GetModifierDescription(_mod_key)
/// @param {string} _mod_key Modifier key
/// @returns {string} Description text
function GetModifierDescription(_mod_key) {
    var _mod = global.Modifiers[$ _mod_key];
    
    var desc = "";
    
    switch (_mod_key) {
        // ===============================
        // ORIGINAL MODIFIERS
        // ===============================
        case "TripleRhythmFire":
            desc = "Every 3rd attack shoots a fireball";
            break;
            
        case "SpreadFire":
            desc = "+4 projectiles in a spread\n+30° melee arc";
            break;
            
        case "DoubleLightning":
            desc = "Every 2nd attack strikes with lightning";
            break;
            
        case "ChainLightning":
            desc = "25% chance to chain lightning\nto nearby enemies";
            break;
            
        case "StaticCharge":
            desc = "Build up 5 charges, then unleash\nmassive lightning storm";
            break;
            
        case "ThunderStrike":
            desc = "30% chance for melee attacks\nto chain lightning";
            break;
            
        case "DeathFireworks":
            desc = "Killed enemies explode into\n8 projectiles";
            break;
            
        case "PoisonCorpse":
            desc = "Killed enemies release\ntoxic clouds";
            break;
            
        case "ChainReaction":
            desc = "50% chance for explosion kills\nto trigger more explosions";
            break;
            
        case "MultiShot":
            desc = "+1 projectile per shot";
            break;
            
        case "BurstFire":
            desc = "Each shot fires 3 times\nin quick succession";
            break;
            
        // ===============================
        // NEW COMMON / STAT MODIFIERS
        // ===============================
        case "AttackUp":
            desc = "x1.15 Attack Power";
            break;
            
        case "DefenseUp":
            desc = "x1.20 Damage Resistance";
            break;
            
        case "SpeedUp":
            desc = "x1.10 Movement Speed";
            break;
            
        case "HealthUp":
            desc = "x1.25 Max Health";
            break;
            
        case "CriticalChance":
            desc = "x1.10 Critical Hit Chance";
            break;
            
        case "CriticalDamage":
            desc = "x1.50 Critical Damage Multiplier";
            break;
            
        case "KnockbackBoost":
            desc = "x1.25 Knockback Force";
            break;
            
        case "LifeSteal":
            desc = "Gain 5% of damage dealt as HP";
            break;
            
        case "Haste":
            desc = "Attacks and abilities recharge\n20% faster";
            break;
            
        case "Adrenaline":
            desc = "Gain x1.25 speed below 0.30 MAX_HP";
            break;
            
        case "Regeneration":
            desc = "Regenerate x1.01 of max HP per second";
            break;
            
        case "Barrier":
            desc = "Gain a shield that blocks one hit\nevery 10 seconds";
            break;
            
        case "Overdrive":
            desc = "Increase attack speed by x1.30\nfor 3s after taking damage";
            break;
            
        case "Evasion":
            desc = "x1.10 chance to dodge attacks";
            break;
            
        case "Momentum":
            desc = "x1.02 damage for each enemy killed\n(stackable up to 10x)";
            break;
            
        case "GoldRush":
            desc = "Enemies drop x1.30 more coins";
            break;
            
        case "Precision":
            desc = "First hit on full HP enemy\nalways crits";
            break;
            
        case "Fortified":
            desc = "Gain x1.10 defense when stationary";
            break;
            
        case "QuickStep":
            desc = "Dodging increases speed by x1.50\nfor 1.5s";
            break;
            
        case "Revenge":
            desc = "After taking damage, next attack\ndeals x1.50 damage";
            break;
            
        default:
            desc = "Dev Forgot Description... (again)";
            break;
    }
    
    return desc;
}