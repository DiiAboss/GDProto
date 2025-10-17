/// @description Weapon Management System for TARLHS
/// Add this to your ChestSystem.gml or create a new WeaponManager.gml script

// ==========================================
// WEAPON MANAGEMENT FUNCTIONS
// ==========================================

/// @function GiveWeapon(_player, _weapon_id)
/// @description Attempt to give player a weapon, handle full inventory
/// @param {Id.Instance} _player The player instance
/// @param {Enum.Weapon} _weapon_id The weapon to give
function GiveWeapon(_player, _weapon_id) {
    var weapon_struct = GetWeaponStructById(_weapon_id);
    
    if (weapon_struct == undefined) {
        show_debug_message("ERROR: Invalid weapon ID: " + string(_weapon_id));
        return false;
    }
    
    // Check for empty slot
    for (var i = 0; i < _player.weapon_slots; i++) {
        if (_player.weapons[i] == noone) {
            // Found empty slot - equip directly
            EquipWeaponToSlot(_player, weapon_struct, i);
            
            show_debug_message("Equipped " + weapon_struct.name + " to slot " + string(i));
            
            // Show notification
            CreateWeaponNotification(_player, weapon_struct, "EQUIPPED");
            
            return true;
        }
    }
    
    // No empty slots - trigger swap prompt
    show_debug_message("Inventory full - showing swap prompt");
    ShowWeaponSwapPrompt(_player, weapon_struct);
    
    return false; // Will be handled by swap prompt
}

/// @function EquipWeaponToSlot(_player, _weapon_struct, _slot_index)
/// @description Equip a weapon to a specific slot
function EquipWeaponToSlot(_player, _weapon_struct, _slot_index) {
    // Store weapon in slot
    _player.weapons[_slot_index] = _weapon_struct;
    
    // If equipping to current slot, update active weapon
    if (_slot_index == _player.current_weapon_index) {
        _player.weaponCurrent = _weapon_struct;
        
        // Create melee weapon instance if needed
        if (_weapon_struct.type == WeaponType.Melee) {
            if (instance_exists(_player.melee_weapon)) {
                instance_destroy(_player.melee_weapon);
            }
            
            if (variable_struct_exists(_weapon_struct, "melee_object_type")) {
                _player.melee_weapon = instance_create_depth(
                    _player.x, 
                    _player.y, 
                    _player.depth - 1, 
                    _weapon_struct.melee_object_type
                );
                _player.melee_weapon.owner = _player;
                _player.melee_weapon.weapon_id = _weapon_struct.id;
            }
        }
    }
}

/// @function GetWeaponStructById(_weapon_id)
/// @description Get weapon struct from global.WeaponStruct by ID
function GetWeaponStructById(_weapon_id) {
    switch (_weapon_id) {
        case Weapon.Sword: return global.WeaponStruct.Sword;
        case Weapon.Bow: return global.WeaponStruct.Bow;
        case Weapon.Dagger: return global.WeaponStruct.Dagger;
        case Weapon.Boomerang: return global.WeaponStruct.Boomerang;
        case Weapon.ChargeCannon: return global.WeaponStruct.ChargeCannon;
        case Weapon.BaseballBat: return global.WeaponStruct.BaseballBat;
        case Weapon.Holy_Water: return global.WeaponStruct.HolyWater;
        default: return undefined;
    }
}

/// @function GetWeaponName(_weapon_id)
/// @description Get display name for weapon
function GetWeaponName(_weapon_id) {
    var weapon_struct = GetWeaponStructById(_weapon_id);
    return weapon_struct != undefined ? weapon_struct.name : "Unknown Weapon";
}

// ==========================================
// WEAPON SWAP PROMPT SYSTEM
// ==========================================

/// @function ShowWeaponSwapPrompt(_player, _new_weapon_struct)
/// @description Create a popup asking player which weapon to replace
function ShowWeaponSwapPrompt(_player, _new_weapon_struct) {
    // Pause game
    global.gameSpeed = 0.1;
    
    // Create swap prompt
    global.weapon_swap_prompt = {
        player: _player,
        new_weapon: _new_weapon_struct,
        selected_slot: 0, // Which slot is highlighted
        active: true
    };
}

/// @function UpdateWeaponSwapPrompt()
/// @description Handle input for weapon swap prompt (call in obj_game_manager Step)
function UpdateWeaponSwapPrompt() {
    if (!variable_global_exists("weapon_swap_prompt")) return;
    if (global.weapon_swap_prompt == undefined || !global.weapon_swap_prompt.active) return;
    
    var prompt = global.weapon_swap_prompt;
    
    // Navigation
    if (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up)) {
        prompt.selected_slot = max(0, prompt.selected_slot - 1);
    }
    if (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down)) {
        prompt.selected_slot = min(prompt.player.weapon_slots - 1, prompt.selected_slot + 1);
    }
    
    // Confirm swap
    if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter)) {
        var old_weapon = prompt.player.weapons[prompt.selected_slot];
        
        // Replace weapon
        EquipWeaponToSlot(prompt.player, prompt.new_weapon, prompt.selected_slot);
        
        show_debug_message("Swapped " + (old_weapon != noone ? old_weapon.name : "empty") + 
                          " for " + prompt.new_weapon.name);
        
        // Show notification
        CreateWeaponNotification(prompt.player, prompt.new_weapon, "SWAPPED");
        
        // Close prompt
        CloseWeaponSwapPrompt();
    }
    
    // Cancel
    if (keyboard_check_pressed(vk_escape)) {
        show_debug_message("Weapon swap cancelled");
        CloseWeaponSwapPrompt();
    }
}

/// @function CloseWeaponSwapPrompt()
function CloseWeaponSwapPrompt() {
    global.weapon_swap_prompt = undefined;
    global.gameSpeed = 1.0;
}

/// @function DrawWeaponSwapPrompt()
/// @description Draw the swap prompt GUI (call in obj_game_manager Draw GUI)
function DrawWeaponSwapPrompt() {
    if (!variable_global_exists("weapon_swap_prompt")) return;
    if (global.weapon_swap_prompt == undefined || !global.weapon_swap_prompt.active) return;
    
    var prompt = global.weapon_swap_prompt;
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    
    // Background overlay
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gui_w, gui_h, false);
    draw_set_alpha(1);
    
    // Panel
    var panel_w = 400;
    var panel_h = 300;
    var panel_x = gui_w / 2 - panel_w / 2;
    var panel_y = gui_h / 2 - panel_h / 2;
    
    draw_set_color(c_dkgray);
    draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);
    draw_set_color(c_white);
    draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, true);
    
    // Title
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_font(fnt_large);
    draw_set_color(c_yellow);
    draw_text(gui_w / 2, panel_y + 20, "INVENTORY FULL!");
    
    // New weapon info
    draw_set_font(fnt_default);
    draw_set_color(c_lime);
    draw_text(gui_w / 2, panel_y + 60, "New Weapon: " + prompt.new_weapon.name);
    
    // Instructions
    draw_set_color(c_white);
    draw_text(gui_w / 2, panel_y + 90, "Replace which weapon?");
    
    // Current weapons list
    var slot_y = panel_y + 130;
    var slot_height = 50;
    
    for (var i = 0; i < prompt.player.weapon_slots; i++) {
        var current_y = slot_y + (i * slot_height);
        var weapon = prompt.player.weapons[i];
        var weapon_name = weapon != noone ? weapon.name : "Empty Slot";
        
        // Highlight selected
        if (i == prompt.selected_slot) {
            draw_set_alpha(0.3);
            draw_set_color(c_yellow);
            draw_rectangle(panel_x + 20, current_y - 5, 
                          panel_x + panel_w - 20, current_y + 30, false);
            draw_set_alpha(1);
        }
        
        // Slot number
        draw_set_halign(fa_left);
        draw_set_color(c_white);
        draw_text(panel_x + 30, current_y, "Slot " + string(i + 1) + ":");
        
        // Weapon name
        draw_set_halign(fa_right);
        var weapon_color = weapon != noone ? c_white : c_gray;
        draw_set_color(weapon_color);
        draw_text(panel_x + panel_w - 30, current_y, weapon_name);
    }
    
    // Bottom instructions
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_ltgray);
    draw_text(gui_w / 2, panel_y + panel_h - 20, 
             "W/S: Select  |  SPACE/ENTER: Swap  |  ESC: Cancel");
}

// ==========================================
// NOTIFICATION SYSTEM
// ==========================================

/// @function CreateWeaponNotification(_player, _weapon_struct, _action)
/// @description Show a brief notification when weapon is equipped/swapped
function CreateWeaponNotification(_player, _weapon_struct, _action) {
    // You can expand this to use your badge system from UI_MANAGER
    // For now, simple debug message
    var message = _action + ": " + _weapon_struct.name;
    show_debug_message(message);
    
    // If you have a badge system, use it:
    // if (instance_exists(obj_ui_manager)) {
    //     obj_ui_manager.ui.AddBadge(message, 120, c_yellow);
    // }
}



/// @function SwitchToWeaponSlot(_slot_index)
/// @description Switch active weapon to specified slot
function SwitchToWeaponSlot(_slot_index) {
    if (_slot_index < 0 || _slot_index >= weapon_slots) return;
    if (weapons[_slot_index] == noone) return;
    
    current_weapon_index = _slot_index;
    weaponCurrent = weapons[_slot_index];
    
    // Handle melee weapon switching
    if (weaponCurrent.type == WeaponType.Melee) {
        if (instance_exists(melee_weapon)) {
            instance_destroy(melee_weapon);
        }
        
        if (variable_struct_exists(weaponCurrent, "melee_object_type")) {
            melee_weapon = instance_create_depth(x, y, depth - 1, weaponCurrent.melee_object_type);
            melee_weapon.owner = self;
            melee_weapon.weapon_id = weaponCurrent.id;
        }
    } else {
        // Switched to ranged - destroy melee weapon
        if (instance_exists(melee_weapon)) {
            instance_destroy(melee_weapon);
            melee_weapon = noone;
        }
    }
    
    show_debug_message("Switched to " + weaponCurrent.name);
}