/// @file scr_SkillTreeHelpers (add these functions)

function GetCharacterLoadout(_character_class) {
    // Ensure structure exists
    if (!variable_struct_exists(global.SaveData.career, "character_loadouts")) {
        global.SaveData.career.character_loadouts = {};
    }
    
    var key = string(_character_class);
    
    // Return existing loadout or create default
    if (variable_struct_exists(global.SaveData.career.character_loadouts, key)) {
        return global.SaveData.career.character_loadouts[$ key];
    } else {
        // Create default loadout
        var default_loadout = [noone, noone, noone, noone, noone];
        global.SaveData.career.character_loadouts[$ key] = default_loadout;
        return default_loadout;
    }
}

	/// @function SaveCharacterLoadout(_character_class, _loadout_array)
	function SaveCharacterLoadout(_character_class, _loadout_array) {

    
	    var key = string(_character_class);
	    global.SaveData.career.character_loadouts[$ key] = _loadout_array;
	    SaveGame();
	}

	/// @function LoadCharacterLoadout(_character_class)
	function LoadCharacterLoadout(_character_class) {
	    //global.SaveData.career.active_loadout = ["", "", "", "", ""];
    
	    global.SaveData.career.active_loadout = GetCharacterLoadout(_character_class);
	}

	/// @function CountEquippedMods(_loadout_array)
	function CountEquippedMods(_loadout_array) {
	    var count = 0;
	    for (var i = 0; i < array_length(_loadout_array); i++) {
	        if (_loadout_array[i] != noone) count++;
	    }
	    return count;
	}

	/// @function GetAvailableModsForCharacter(_character_class)
	function GetAvailableModsForCharacter(_character_class) {
	    var available_mods = [];
	    var node_keys = variable_struct_get_names(global.SkillTree);
    
	    for (var i = 0; i < array_length(node_keys); i++) {
	        var key = node_keys[i];
	        var node = global.SkillTree[$ key];
        
	        // Only include unlocked mod_unlock type nodes
	        if (node.type != "pregame_mod_unlock") continue;
	        if (!node.unlocked) continue;
        
	        // Check character restriction
	        if (variable_struct_exists(node, "required_character")) {
	            if (node.required_character != _character_class) {
	                continue; // Character-locked, skip
	            }
	        }
        
	        array_push(available_mods, key);
	    }
    
	    return available_mods;
	}

	///// @function IsModEquipped(_mod_id, _loadout_array)
	//function IsModEquipped(_mod_id, _loadout_array) {
	//    return array_contains(_loadout_array, _mod_id);
	//}
	/// @function IsModEquipped(_mod_id, _loadout_array)
function IsModEquipped(_mod_id, _loadout_array) {
    // Safety check
    if (!is_array(_loadout_array)) {
        show_debug_message("WARNING: IsModEquipped received non-array: " + string(_loadout_array));
		show_debug_message("WARNING: IsModEquipped received non-array: " + string(typeof(_loadout_array)));
        return false;
    }
    
    return array_contains(_loadout_array, _mod_id);
}



function ApplyLoadoutToPlayer(_player) {
    var loadout = global.SaveData.career.active_loadout;
    var applied_count = 0;
    
    for (var i = 0; i < array_length(loadout); i++) {
        var node_id = loadout[i];
        if (node_id == "" || node_id == noone) continue;
        
        var node = global.SkillTree[$ node_id];
        if (node == noone) continue;
        
        var modifier_key = GetModifierKeyFromNodeId(node_id);
        
        if (modifier_key == undefined) {
            show_debug_message("WARNING: No modifier mapping for node: " + node_id);
            continue;
        }
        
        var mod_instance = AddModifier(_player, modifier_key);
        CalculateCachedStats(_player);
        if (mod_instance != noone) {
            applied_count++;
            show_debug_message("Applied: " + node.name + " -> " + modifier_key);
        }
    }
    
    
    
    show_debug_message("=== Loadout Applied: " + string(applied_count) + " mods ===");
}

	/// @function ClearPlayerLoadoutMods(_player)
	/// @description Remove all mods that came from the loadout (useful for testing/resetting)
	function ClearPlayerLoadoutMods(_player) {
	    if (!variable_instance_exists(_player, "mod_list")) return;
    
	    // Get current loadout
	    var loadout = global.SaveData.career.active_loadout;
	    var mods_to_remove = [];
    
	    // Build list of mod keys to remove
	    for (var i = 0; i < array_length(loadout); i++) {
	        var node_id = loadout[i];
	        if (node_id == noone) continue;
        
	        var node = global.SkillTree[$ node_id];
	        if (node != noone && variable_struct_exists(node, "mod_key")) {
	            array_push(mods_to_remove, node.mod_key);
	        }
	    }
    
	    // Remove matching mods from player
	    for (var i = array_length(_player.mod_list) - 1; i >= 0; i--) {
	        var _mod = _player.mod_list[i];
	        if (array_contains(mods_to_remove, _mod.template_key)) {
	            array_delete(_player.mod_list, i, 1);
	            show_debug_message("Removed loadout mod: " + _mod.template_key);
	        }
	    }
    
	    // Rebuild mod cache
	    _player.mod_cache = {};
	    for (var i = 0; i < array_length(_player.mod_list); i++) {
	        var _mod = _player.mod_list[i];
	        var template = global.Modifiers[$ _mod.template_key];
        
	        if (template != noone) {
	            for (var j = 0; j < array_length(template.triggers); j++) {
	                var trigger_str = string(template.triggers[j]);
	                if (!variable_struct_exists(_player.mod_cache, trigger_str)) {
	                    _player.mod_cache[$ trigger_str] = [];
	                }
	                array_push(_player.mod_cache[$ trigger_str], _mod);
	            }
	        }
	    }
    
	    // Recalculate stats
	    if (object_is_ancestor(_player.object_index, obj_player)) {
	        CalculateCachedStats(_player);
	    }
    
	    show_debug_message("Cleared loadout mods from player");
	}	/// @function ApplyWeaponsToPlayer(_player, _character_class)
	function ApplyWeaponsToPlayer(_player, _character_class) {
	    var weapon_loadout = GetCharacterWeaponLoadout(_character_class);
    
	    show_debug_message("=== Applying Weapon Loadout ===");
    
	    for (var i = 0; i < array_length(weapon_loadout); i++) {
	        var weapon_enum = weapon_loadout[i];
        
	        if (weapon_enum == noone) {
	            show_debug_message("Weapon slot " + string(i) + ": Empty");
	            _player.weapons[i] = noone;
	            continue;
	        }
        
	        // Use your existing function to get weapon struct
	        var weapon_struct = GetWeaponStructById(weapon_enum);
        
	        if (weapon_struct == noone) {
	            show_debug_message("ERROR: Invalid weapon ID: " + string(weapon_enum));
	            _player.weapons[i] = noone;
	            continue;
	        }
        
	        // Equip weapon to slot using your existing function
	        EquipWeaponToSlot(_player, weapon_struct, i);
        
	        show_debug_message("Equipped weapon to slot " + string(i) + ": " + weapon_struct.name);
	    }
    
	    // Make sure current weapon is set
	    if (_player.current_weapon_index == 0 && _player.weapons[0] != noone) {
	        _player.weaponCurrent = _player.weapons[0];
	        show_debug_message("Set current weapon to: " + _player.weapons[0].name);
	    }
	}