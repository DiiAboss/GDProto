/// @file scr_SkillTreeHelpers
/// @description Helper functions for skill tree system

/// @function InitializeSkillTreeSaveData()
function InitializeSkillTreeSaveData() {
    // Ensure skill_tree exists in career
    if (!variable_struct_exists(global.SaveData.career, "skill_tree")) {
        global.SaveData.career.skill_tree = {
            unlocked_nodes: [],
            node_stacks: {}
        };
    }
    
    // Sync save data with skill tree
    var unlocked = global.SaveData.career.skill_tree.unlocked_nodes;
    var node_keys = variable_struct_get_names(global.SkillTree);
    
    for (var i = 0; i < array_length(node_keys); i++) {
        var key = node_keys[i];
        var node = global.SkillTree[$ key];
        
        // Set unlocked status from save
        node.unlocked = array_contains(unlocked, key);
        
        // Restore stack counts
        if (node.type == "stat_boost" && variable_struct_exists(node, "max_stacks")) {
            if (variable_struct_exists(global.SaveData.career.skill_tree.node_stacks, key)) {
                node.current_stacks = global.SaveData.career.skill_tree.node_stacks[$ key];
            } else {
                node.current_stacks = 0;
            }
        }
    }
}

/// @function UnlockCharacter(_character_class)
function UnlockCharacter(_character_class) {
    if (!array_contains(global.SaveData.unlocks.characters, _character_class)) {
        array_push(global.SaveData.unlocks.characters, _character_class);
        show_debug_message("Unlocked character: " + string(_character_class));
        SaveGame();
    }
}

/// @function IsCharacterUnlocked(_character_class)
function IsCharacterUnlocked(_character_class) {
    // Warrior always unlocked
    if (_character_class == CharacterClass.WARRIOR) return true;
    
    return array_contains(global.SaveData.unlocks.characters, _character_class);
}

/// @function UnlockLevel(_level_id)
function UnlockLevel(_level_id) {
    if (!array_contains(global.SaveData.unlocks.levels, _level_id)) {
        array_push(global.SaveData.unlocks.levels, _level_id);
        show_debug_message("Unlocked level: " + _level_id);
        SaveGame();
    }
}

/// @function IsLevelUnlocked(_level_id)
function IsLevelUnlocked(_level_id) {
    // First level always unlocked
    if (_level_id == "arena_1") return true;
    
    return array_contains(global.SaveData.unlocks.levels, _level_id);
}

/// @function UnlockWeapon(_weapon_id)
function UnlockWeapon(_weapon_id) {
    if (!variable_struct_exists(global.SaveData, "unlocked_weapons")) {
        global.SaveData.unlocked_weapons = [];
    }
    
    if (!array_contains(global.SaveData.unlocked_weapons, _weapon_id)) {
        array_push(global.SaveData.unlocked_weapons, _weapon_id);
        show_debug_message("Unlocked weapon: " + string(_weapon_id));
    }
}

/// @function IsWeaponUnlocked(_weapon_id)
function IsWeaponUnlocked(_weapon_id) {
    // Starting weapons always unlocked
    if (_weapon_id == Weapon.Sword || _weapon_id == Weapon.Bow) return true;
    
    if (!variable_struct_exists(global.SaveData, "unlocked_weapons")) {
        return false;
    }
    
    return array_contains(global.SaveData.unlocked_weapons, _weapon_id);
}

/// @function UnlockModifier(_mod_key)
function UnlockModifier(_mod_key) {
    if (!variable_struct_exists(global.SaveData, "unlocked_modifiers")) {
        global.SaveData.unlocked_modifiers = [];
    }
    
    if (!array_contains(global.SaveData.unlocked_modifiers, _mod_key)) {
        array_push(global.SaveData.unlocked_modifiers, _mod_key);
        show_debug_message("Unlocked modifier: " + _mod_key);
    }
}


function GetSouls() {
    return global.SaveData.career.currency.souls;
}

/// @function AddSouls(_amount)
function AddSouls(_amount) {

    GiveSouls(_amount);
	SaveGame();
}

/// @function SpendSouls(_amount)
function SpendSouls(_amount) {
    if (!variable_struct_exists(global.SaveData, "career")) return false;
    if (!variable_struct_exists(global.SaveData.career, "currency")) return false;
    
    if (global.SaveData.career.currency.souls >= _amount) {
        global.SaveData.career.currency.souls -= _amount;
        SaveGame();
        return true;
    }
    
    return false;
}

/// @function AwardSoulsForRun(_score, _kills, _time_survived)
function AwardSoulsForRun(_score, _kills, _time_survived) {
    // Calculate souls based on performance
    var base_souls = floor(_score / 100);
    var kill_bonus = floor(_kills / 10);
    var time_bonus = floor(_time_survived / 30); // 1 soul per 30 seconds
    
    var total_souls = base_souls + kill_bonus + time_bonus;
    
    AddSouls(total_souls);
    
    show_debug_message("Awarded " + string(total_souls) + " souls for run");
    return total_souls;
}
