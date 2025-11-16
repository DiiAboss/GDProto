

// MENU STATES
enum MENU_STATE {
    MAIN,
    SETTINGS,
    CHARACTER_SELECT,
	 LEVEL_SELECT,
    UNLOCKS,
    STATS,
    PAUSE_MENU,
    GAME_OVER,
	LOADOUT_SELECT,
}

function MenuSystem() constructor {
    
	
	show_pause_settings = false; // NEW
show_missions = false;        // NEW
	loadout_weapon_slot = 0; // Which weapon slot is selected (0 or 1)
active_loadout_weapons = [noone, noone]; // Current weapon selection
	
	selected_weapon_slot = 0;
	selected_column = 0;
	weapon_select_open = false;
	selected_mod_index = 0;
	
	loadout_selected_slot = 0;
	loadout_scroll_offset = 0;
	loadout_hovered_mod = noone;
	show_mod_tooltip = false;
	
    // ==========================================
    // STATE
    // ==========================================
    state = MENU_STATE.MAIN;
    selected_option = 0;
    selected_class = 0;
    selected_level = 0;
    selected_character_class = CharacterClass.WARRIOR;
    stats_selected_mod = 0;
	
    // Sub-menu states
    pause_selected = 0;
    show_controls = false;
    show_stats = false;
    stats_scroll_offset = 0;
    stats_selected_character = CharacterClass.WARRIOR;
    
    // Visual animation
    logo_scale = 0;
    logo_bounce = 0;
    menu_alpha = 0;
    
	audio_sys = noone;
	game_manager = noone;
	pause_manager = noone;
	
	carousel_angle = 0;
	
    // ==========================================
    // MENU DATA
    // ==========================================
    main_menu_options = ["START", "UNLOCKS", "STATS", "SETTINGS", "EXIT"];
    pause_options	  = ["RESUME", "STATS", "MISSIONS", "SETTINGS", "CONTROLS", "QUIT TO MENU"];
    settings_options  = array_length(main_menu_options); // Master, Music, SFX, Voice, Back
    
    class_options = [
        global.Player_Class.Warrior,
        global.Player_Class.Holy_Mage,
        global.Player_Class.Vampire
    ];
    
    level_options = [
        {
            id: "arena_1",
            name: "FOREST",
            description: "Where legends are born.",
            difficulty: "Normal",
            sprite: spr_mod_default,
            unlocked: true,
            room: rm_demo_room
        },
        {
            id: "arena_2",
            name: "CATACOMB",
            description: "Ancient tombs filled with restless dead.",
            difficulty: "Hard",
            sprite: spr_mod_default,
            unlocked: false,
            unlock_requirement: "Score 5000+",
            room: rm_demo_room
        },
        {
            id: "arena_3",
            name: "FORTRESS",
            description: "The gates of hell itself.",
            difficulty: "Nightmare",
            sprite: spr_mod_default,
            unlocked: false,
            unlock_requirement: "Score 10000+",
            room: rm_demo_room
        }
    ];
    
    recent_unlocks = [];
    
	static Init = function(_game_manager, _pause_manager, _audio_manager)
	{
		if audio_sys	 == noone audio_sys		 = _audio_manager;
		if game_manager  == noone game_manager	 = _game_manager; 
		if pause_manager == noone pause_manager	 = _pause_manager;
	}
	
	/// Inside MenuSystem constructor, add this method:
	static SaveAudioSettings = function(_audio) {
	    global.SaveData.settings.master_volume = _audio.settings.master_volume;
	    global.SaveData.settings.music_volume = _audio.music_master_volume;
	    global.SaveData.settings.sfx_volume = _audio.sfx_master_volume;
	    global.SaveData.settings.voice_volume = _audio.voice_volume;
	    SaveGame();
	}
	
    // ==========================================
    // UPDATE
    // ==========================================
    static Update = function(_input, _audio, _mx, _my) {
		// Animate logo
        logo_scale = lerp(logo_scale, 1, 0.1);
        logo_bounce = sin(current_time * 0.003) * 5;
        menu_alpha = min(menu_alpha + 0.02, 1);
		
        
        // Handle input based on state
        switch(state) {
            case MENU_STATE.MAIN:
                HandleMainMenu(_input, _audio, _mx, _my);
                break;
            case MENU_STATE.CHARACTER_SELECT:
                HandleCharacterSelect(_input, _audio, _mx, _my);
                break;
            case MENU_STATE.LEVEL_SELECT:
                HandleLevelSelect(_input, _audio, _mx, _my);
                break;
            case MENU_STATE.UNLOCKS:
                HandleUnlocks(_input, _audio);
                break;
            case MENU_STATE.STATS:
                HandleStats(_input, _audio);
                break;
            case MENU_STATE.SETTINGS:
                HandleSettings(_input, _audio, _mx, _my);
                break;
            case MENU_STATE.PAUSE_MENU:
                HandlePauseMenu(_input, _audio, _mx, _my);
                break;
			case MENU_STATE.LOADOUT_SELECT:
				HandleLoadoutSelect(_input, _audio, _mx, _my);
    break;
        }
    }
    
    // ==========================================
    // DRAW
    // ==========================================
    static Draw = function(_w, _h, _cx, _cy) {
        switch(state) {
            case MENU_STATE.MAIN:
                DrawMainMenu(_w, _h, _cx, _cy);
                break;
            case MENU_STATE.CHARACTER_SELECT:
                DrawCharacterSelect(_w, _h, _cx, _cy);
                break;
            case MENU_STATE.LEVEL_SELECT:
                DrawLevelSelect(_w, _h, _cx, _cy);
                break;
            case MENU_STATE.UNLOCKS:
                DrawUnlocks(_w, _h, _cx, _cy);
                break;
            case MENU_STATE.STATS:
                DrawStats(_w, _h, _cx, _cy);
                break;
            case MENU_STATE.SETTINGS:
                DrawSettings(_w, _h, _cx, _cy, audio_sys);
                break;
            case MENU_STATE.PAUSE_MENU:
				var mx = device_mouse_x_to_gui(0);
				var my = device_mouse_y_to_gui(0);
                DrawPauseMenu(_w, _h, _cx, _cy, mx, my);
                break;
				case MENU_STATE.LOADOUT_SELECT:
				DrawLoadoutSelect(_w, _h, _cx, _cy);
    break;
        }
    }
    
    // ==========================================
    // PAUSE/RESUME HELPERS
    // ==========================================
    static PauseGame = function(_audio, _pause_manager) {
		if !(pause_manager) pause_manager = obj_game_manager.pause_manager;
            pause_manager.Pause(PAUSE_REASON.PAUSE_MENU, 0);
            state = MENU_STATE.PAUSE_MENU;
            _audio.FadeMusic(_audio.GetMusicVolume() * 0.5, 15, FADE_TYPE.LINEAR);
    }
    
    static ResumeGame = function(_audio, _pause_manager) {
		if !(pause_manager) pause_manager = obj_game_manager.pause_manager;
            pause_manager.Resume(PAUSE_REASON.PAUSE_MENU);
            state = MENU_STATE.MAIN;
            _audio.FadeMusic(_audio.music_master_volume, 15, FADE_TYPE.LINEAR);
    }
    
    static QuitToMenu = function(_audio, _pause_manager) {
  		if !(pause_manager) pause_manager = obj_game_manager.pause_manager;
		pause_manager.ResumeAll();
     
        state = MENU_STATE.MAIN;
        selected_option = 0;
        show_controls = false;
        show_stats = false;
        
        _audio.CrossfadeMusic(Sound1, true, 30);
        room_goto(rm_main_menu);
    }
    
	
	/// @function LoadAvailableMods()
	static LoadAvailableMods = function() {
	    // Get all unlocked pre-game mods from skill tree
	    available_mods = [];
    
	    var node_keys = variable_struct_get_names(global.SkillTree);
	    for (var i = 0; i < array_length(node_keys); i++) {
	        var key = node_keys[i];
	        var node = global.SkillTree[$ key];
        
	        // If it's an unlocked pre-game mod, add it to available list
	        if (node.type == "pregame_mod_unlock" && node.unlocked) {
	            array_push(available_mods, node.mod_id); // This is the PreGameMod enum
	        }
	    }
    
	    show_debug_message("Loaded " + string(array_length(available_mods)) + " unlocked pre-game mods");
	}
	
    // ==========================================
    // MAIN MENU
    // ==========================================
    
    /// @function DrawMainMenu(_w, _h, _cx, _cy)
    static DrawMainMenu = function(_w, _h, _cx, _cy) {
        // Background
        draw_set_color(c_black);
        draw_set_alpha(0.8);
        draw_rectangle(0, 0, _w, _h, false);
        draw_set_alpha(1);
        
        // Logo
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(fnt_large);
        
        var logo_y = _cy - 200 + logo_bounce;
        draw_text_transformed_color(_cx, logo_y, "TARLHS GAME", 
            logo_scale * 2, logo_scale * 2, 0,
            c_red, c_orange, c_yellow, c_red, menu_alpha);
        
        draw_set_font(fnt_default);
        draw_text_color(_cx, logo_y + 50, "DEMO v0.1", 
            c_gray, c_gray, c_white, c_white, menu_alpha * 0.7);
        
        draw_set_alpha(menu_alpha);
        
        // Menu options
        for (var i = 0; i < array_length(main_menu_options); i++) {
            var yy = _cy + (i * 60) - 30;
            var is_selected = (i == selected_option);
            
            if (is_selected) {
                draw_set_alpha(menu_alpha * 0.3);
                draw_rectangle_color(_cx - 120, yy - 25, _cx + 120, yy + 25,
                    c_yellow, c_orange, c_orange, c_yellow, false);
                draw_set_alpha(menu_alpha);
            }
            
            draw_set_font(is_selected ? fnt_large : fnt_default);
            var col = is_selected ? c_yellow : c_white;
            draw_text_color(_cx, yy, main_menu_options[i], col, col, col, col, menu_alpha);
        }
        
        // Input prompt
        draw_set_font(fnt_default);
        draw_set_halign(fa_center);
        draw_set_color(c_gray);
        draw_text(_cx, _h - 40, "[WASD/ARROWS] Navigate  [ENTER] Select");
        
        draw_set_alpha(1);
    }
    
    /// @function HandleMainMenu(_input, _audio, _mx, _my)
    static HandleMainMenu = function(_input, _audio, _mx, _my) {
        var cy = display_get_gui_height() / 2;
        var cx = display_get_gui_width() / 2;
        
        var prev_selection = selected_option;
        
        // Keyboard/gamepad navigation
        if (_input.UpPress) {
            selected_option = (selected_option - 1 + array_length(main_menu_options)) mod array_length(main_menu_options);
        }
        if (_input.DownPress) {
            selected_option = (selected_option + 1) mod array_length(main_menu_options);
        }
        
        // Play sound on selection change
        if (prev_selection != selected_option) {
            _audio.PlayUISound(snd_menu_hover);
        }
        
        // Mouse hover
        for (var i = 0; i < array_length(main_menu_options); i++) {
            var yy = cy + (i * 60) - 30;
            if (point_in_rectangle(_mx, _my, cx - 120, yy - 25, cx + 120, yy + 25)) {
                if (selected_option != i) {
                    selected_option = i;
                    _audio.PlayUISound(snd_menu_hover);
                }
                
                if (_input.FirePress) {
                    _audio.PlayUISound(snd_menu_select);
                    SelectMainMenuOption();
                }
            }
        }
        
        // Confirm selection
        if (_input.Action) {
            _audio.PlayUISound(snd_menu_select);
            SelectMainMenuOption();
        }
    }
    
    /// @function SelectMainMenuOption()
    static SelectMainMenuOption = function() {
        switch(selected_option) {
            case 0: // START
                state = MENU_STATE.CHARACTER_SELECT;
                selected_class = 0;
                break;
            case 1: // UNLOCKS
                state = MENU_STATE.UNLOCKS;
                break;
            case 2: // STATS
                state = MENU_STATE.STATS;
                stats_scroll_offset = 0;
                stats_selected_character = CharacterClass.WARRIOR;
                break;
            case 3: // SETTINGS
                state = MENU_STATE.SETTINGS;
                selected_option = 0;
                break;
            case 4: // EXIT
                game_end();
                break;
        }
    }
    
    // ==========================================
    // CHARACTER SELECT
    // ==========================================

	 /// @function ToggleModInLoadout(_mod_id, _audio)
	static ToggleModInLoadout = function(_mod_id, _audio) {
	    var loadout = global.SaveData.career.active_loadout;
	    //var character_key = string(selected_character_class);
    

	    // Check if already equipped
	    var equipped_index = -1;
	    for (var i = 0; i < array_length(loadout); i++) {
	        if (loadout[i] == _mod_id) {
	            equipped_index = i;
	            break;
	        }
	    }
    
	    if (equipped_index != -1) {
	        // Remove from loadout
	        loadout[equipped_index] = noone;
	        _audio.PlayUISound(snd_menu_select);
	        show_debug_message("Removed mod from slot " + string(equipped_index));
	    } else {
	        // Add to first empty slot
	        for (var i = 0; i < array_length(loadout); i++) {
	            if (loadout[i] == noone) {
	                loadout[i] = _mod_id;
	                loadout_selected_slot = i;
	                _audio.PlayUISound(snd_menu_select);
	                show_debug_message("Equipped mod to slot " + string(i));
	                return;
	            }
	        }
        
	        // No empty slots
	        show_debug_message("No empty slots! Remove a mod first.");
			show_debug_message("Slots: " + json_stringify(loadout));
	    }
	}


	/// ==========================================
	/// LOADOUT SCREEN - 3 COLUMN LAYOUT
	/// ==========================================

	/// @function DrawLoadoutSelect(_w, _h, _cx, _cy)
	static DrawLoadoutSelect = function(_w, _h, _cx, _cy) {
	    // Background
	    draw_set_color(c_black);
	    draw_set_alpha(0.9);
	    draw_rectangle(0, 0, _w, _h, false);
	    draw_set_alpha(1);
    
	    // Title
	    draw_set_halign(fa_center);
	    draw_set_valign(fa_top);
	    draw_set_font(fnt_large);
	    draw_set_color(c_yellow);
    
	    var char_name = GetCharacterName(selected_character_class);
	    draw_text(_cx, 20, "LOADOUT: " + char_name);
    
	    // Souls display
	    draw_set_font(fnt_default);
	    draw_set_halign(fa_right);
	    draw_set_color(c_white);
	    draw_text(_w - 40, 30, "Souls: " + string(GetSouls()));
    
	    // Column dividers
	    var left_border = 60;
	    var stats_width = _w * 0.15;
	    var weapons_width = _w * 0.35;
	    var mods_width = _w * 0.50;
    
	    var stats_x = left_border;
	    var weapons_x = stats_x + stats_width;
	    var mods_x = weapons_x + weapons_width;
    
	    var top_y = 80;
	    var bottom_y = _h - 80;
    
	    // Draw vertical dividers
	    draw_set_color(c_dkgray);
	    draw_line_width(weapons_x, top_y, weapons_x, bottom_y, 2);
	    draw_line_width(mods_x, top_y, mods_x, bottom_y, 2);
    
	    // Draw horizontal divider under title
	    draw_rectangle(left_border, top_y - 5, _w - 60, top_y, false);
    
	    // Draw each column
	    DrawStatsColumn(stats_x, top_y, stats_width, bottom_y - top_y);
	    DrawWeaponsColumn(weapons_x, top_y, weapons_width, bottom_y - top_y);
	    DrawModsColumn(mods_x, top_y, mods_width, bottom_y - top_y, _w, _h);
    
	    // Draw weapon popup if open
	    if (weapon_select_open) {
	        DrawWeaponSelectPopup(_cx, _cy);
	    }
    
	    // Instructions at bottom
	    draw_set_font(fnt_default);
	    draw_set_halign(fa_center);
	    draw_set_color(c_white);
	    draw_text(_cx, _h - 50, "[ARROWS/WASD] Navigate  [ENTER/CLICK] Select  [X] Remove");
	    draw_text(_cx, _h - 30, "[ESC] Back to Character    [ENTER] Continue to Level");
	}

	/// ==========================================
	/// LEFT COLUMN: PLAYER STATS
	/// ==========================================

	/// @function DrawStatsColumn(_x, _y, _width, _height)
	static DrawStatsColumn = function(_x, _y, _width, _height) {
	    var padding = 10;
	    var content_x = _x + padding;
	    var current_y = _y + padding;
    
	    // Get character stats
	    var char_stats = GetCharacterStats(selected_character_class);
	    var loadout = global.SaveData.career.active_loadout;
    
	    // === BASE STATS ===
	    draw_set_halign(fa_left);
	    draw_set_valign(fa_top);
	    draw_set_font(fnt_default);
	    draw_set_color(c_yellow);
	    draw_text(content_x, current_y, "BASE STATS:");
	    current_y += 25;
    
	    draw_set_color(c_white);
	    draw_text(content_x, current_y, "HP:  " + string(char_stats.hp_max));
	    current_y += 20;
	    draw_text(content_x, current_y, "ATK: " + string(char_stats.attack_base));
	    current_y += 20;
	    draw_text(content_x, current_y, "SPD: " + string(char_stats.move_speed));
	    current_y += 30;
    
	    // === EQUIPPED MODS ===
	    draw_set_color(c_aqua);
	    draw_text(content_x, current_y, "EQUIPPED MODS:");
	    current_y += 25;
    
	    var equipped_count = 0;
	    for (var i = 0; i < array_length(loadout); i++) {
	        if (loadout[i] != noone) {
	            var node = global.SkillTree[$ loadout[i]];
	            if (node != noone) {
	                draw_set_color(c_white);
	                var mod_name = node.name;
	                if (string_length(mod_name) > 12) {
	                    mod_name = string_copy(mod_name, 1, 10) + "..";
	                }
	                draw_text(content_x, current_y, "• " + mod_name);
	                current_y += 18;
	                equipped_count++;
	            }
	        }
	    }
    
	    // Show empty slots
	    for (var i = equipped_count; i < 5; i++) {
	        draw_set_color(c_dkgray);
	        draw_text(content_x, current_y, "• -----");
	        current_y += 18;
	    }
    
	    current_y += 20;
    
	    // === MODIFIED STATS ===
	    draw_set_color(c_lime);
	    draw_text(content_x, current_y, "MODIFIED STATS:");
	    current_y += 25;
    
	    // Calculate stat modifiers from equipped mods
	    var stat_mods = CalculateStatModsFromLoadout(loadout);
    
	    var final_hp = char_stats.hp_max + stat_mods.hp;
	    var final_atk = char_stats.attack_base + stat_mods.attack;
	    var final_spd = char_stats.move_speed + stat_mods.speed;
    
	    // HP
	    draw_set_color(c_white);
	    draw_text(content_x, current_y, "HP:  " + string(final_hp));
	    if (stat_mods.hp != 0) {
	        draw_set_color(stat_mods.hp > 0 ? c_lime : c_red);
	        draw_text(content_x + 60, current_y, "(" + (stat_mods.hp > 0 ? "+" : "") + string(stat_mods.hp) + ")");
	    }
	    current_y += 20;
    
	    // ATK
	    draw_set_color(c_white);
	    draw_text(content_x, current_y, "ATK: " + string(final_atk));
	    if (stat_mods.attack != 0) {
	        draw_set_color(stat_mods.attack > 0 ? c_lime : c_red);
	        draw_text(content_x + 60, current_y, "(" + (stat_mods.attack > 0 ? "+" : "") + string(stat_mods.attack) + ")");
	    }
	    current_y += 20;
    
	    // SPD
	    draw_set_color(c_white);
	    draw_text(content_x, current_y, "SPD: " + string_format(final_spd, 1, 1));
	    if (stat_mods.speed != 0) {
	        draw_set_color(stat_mods.speed > 0 ? c_lime : c_red);
	        draw_text(content_x + 60, current_y, "(" + (stat_mods.speed > 0 ? "+" : "") + string_format(stat_mods.speed, 1, 1) + ")");
	    }
	}

/// @function CalculateStatModsFromLoadout(_loadout)
static CalculateStatModsFromLoadout = function(_loadout) {
    var mods = { hp: 0, attack: 0, speed: 0 };
    
    for (var i = 0; i < array_length(_loadout); i++) {
        if (_loadout[i] == "" || _loadout[i] == noone) continue;
        
        var node = global.SkillTree[$ _loadout[i]];
        if (node == noone) continue;
        if (!variable_struct_exists(node, "mod_id")) continue;
        
        var mod_id = node.mod_id;
        
        // Check against PreGameMod enum values
        if (mod_id == PreGameMod.STAT_HP) mods.hp += 10; // +10% as per your definition
        if (mod_id == PreGameMod.STAT_DAMAGE) mods.attack += 10; // +10%
        if (mod_id == PreGameMod.STAT_SPEED) mods.speed += 10; // +10%
        
        // Add other stat mods if you have them
    }
    
    return mods;
}

	/// ==========================================
	/// CENTER COLUMN: WEAPONS
	/// ==========================================

	/// @function DrawWeaponsColumn(_x, _y, _width, _height)
	static DrawWeaponsColumn = function(_x, _y, _width, _height) {
	    var padding = 20;
	    var content_x = _x + padding;
	    var content_width = _width - (padding * 2);
	    var current_y = _y + padding;
    
	    // Title
	    draw_set_halign(fa_left);
	    draw_set_valign(fa_top);
	    draw_set_font(fnt_default);
	    draw_set_color(c_orange);
	    draw_text(content_x, current_y, "WEAPONS:");
	    current_y += 30;
    
	    // Draw weapon slots
	    var slot_size = 80;
	    var slot_spacing = 100;
	    var slots_x = content_x + (content_width / 2) - slot_size - 10;
    
	    for (var i = 0; i < 2; i++) {
	        var slot_x = slots_x + (i * slot_spacing);
	        var slot_y = current_y + 40;
        
	        var weapon = active_loadout_weapons[i];
	        var is_selected = (selected_weapon_slot == i && selected_column == 1);
        
	        // Slot background
	        draw_set_alpha(0.6);
	        draw_set_color(is_selected ? c_orange : c_dkgray);
	        draw_rectangle(slot_x - slot_size/2, slot_y - slot_size/2,
	                      slot_x + slot_size/2, slot_y + slot_size/2, false);
	        draw_set_alpha(1);
        
	        // Slot border
	        draw_set_color(is_selected ? c_yellow : c_white);
	        for (var b = 0; b < (is_selected ? 3 : 1); b++) {
	            draw_rectangle(slot_x - slot_size/2 - b, slot_y - slot_size/2 - b,
	                          slot_x + slot_size/2 + b, slot_y + slot_size/2 + b, true);
	        }
        
	        if (weapon != noone) {
	            // Draw weapon
	            var weapon_sprite = GetWeaponSprite(weapon);
	            if (sprite_exists(weapon_sprite)) {
	                draw_sprite_ext(weapon_sprite, 0, slot_x, slot_y,
	                               1, 1, 0, c_white, 1);
	            }
            
	            // Weapon name
	            draw_set_halign(fa_center);
	            draw_set_color(c_white);
	            var weapon_name = GetWeaponName(weapon);
	            if (string_length(weapon_name) > 10) {
	                weapon_name = string_copy(weapon_name, 1, 8) + "..";
	            }
	            draw_text(slot_x, slot_y + slot_size/2 + 8, weapon_name);
	        } else {
	            // Empty slot
	            draw_set_color(c_gray);
	            draw_set_font(fnt_large);
	            draw_set_halign(fa_center);
	            draw_text(slot_x, slot_y - 10, "?");
            
	            draw_set_font(fnt_default);
	            draw_text(slot_x, slot_y + 10, "EMPTY");
	        }
        
	        // Slot number
	        draw_set_color(c_gray);
	        draw_set_font(fnt_default);
	        draw_set_halign(fa_center);
	        draw_text(slot_x, slot_y - slot_size/2 - 15, "[" + string(i + 1) + "]");
	    }
    
	    current_y += 160;
    
	    // Available weapons hint
	    draw_set_halign(fa_center);
	    draw_set_color(c_ltgray);
	    draw_text(content_x + content_width/2, current_y, "Press ENTER to change weapon");
	}

	/// @function DrawWeaponSelectPopup(_cx, _cy)
	static DrawWeaponSelectPopup = function(_cx, _cy) {
	    var unlocked = GetUnlockedWeaponsForCharacter(selected_character_class);
    
	    var popup_w = 400;
	    var popup_h = min(450, 120 + (array_length(unlocked) * 60));
	    var popup_x = _cx - popup_w / 2;
	    var popup_y = _cy - popup_h / 2;
    
	    // Dark overlay
	    draw_set_alpha(0.7);
	    draw_set_color(c_black);
	    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
	    draw_set_alpha(1);
    
	    // Popup background
	    draw_set_color(c_dkgray);
	    draw_rectangle(popup_x, popup_y, popup_x + popup_w, popup_y + popup_h, false);
	    draw_set_color(c_white);
	    draw_rectangle(popup_x, popup_y, popup_x + popup_w, popup_y + popup_h, true);
    
	    // Title
	    draw_set_halign(fa_center);
	    draw_set_valign(fa_top);
	    draw_set_font(fnt_large);
	    draw_set_color(c_yellow);
	    draw_text(_cx, popup_y + 15, "SELECT WEAPON");
    
	    draw_set_font(fnt_default);
	    draw_set_color(c_ltgray);
	    draw_text(_cx, popup_y + 45, "For Slot " + string(selected_weapon_slot + 1));
    
	    // Weapon list
	    var list_y = popup_y + 80;
	    var item_height = 50;
    
	    for (var i = 0; i < array_length(unlocked); i++) {
	        var weapon = unlocked[i];
	        var item_y = list_y + (i * item_height);
	        var is_selected = (weapon_popup_selected == i);
	        var is_equipped = IsWeaponEquipped(weapon, active_loadout_weapons);
        
	        // Highlight selected
	        if (is_selected) {
	            draw_set_alpha(0.3);
	            draw_set_color(c_yellow);
	            draw_rectangle(popup_x + 10, item_y - 5, 
	                          popup_x + popup_w - 10, item_y + item_height - 10, false);
	            draw_set_alpha(1);
	        }
        
	        // Weapon sprite
	        var weapon_sprite = GetWeaponSprite(weapon);
	        if (sprite_exists(weapon_sprite)) {
	            draw_sprite_ext(weapon_sprite, 0, popup_x + 40, item_y + 15,
	                           0.8, 0.8, 0, c_white, 1);
	        }
        
	        // Weapon name
	        draw_set_halign(fa_left);
	        draw_set_color(is_equipped ? c_lime : c_white);
	        draw_text(popup_x + 80, item_y + 8, GetWeaponName(weapon));
        
	        if (is_equipped) {
	            draw_set_halign(fa_right);
	            draw_text(popup_x + popup_w - 20, item_y + 8, "[EQUIPPED]");
	        }
	    }
    
	    // Instructions
	    draw_set_halign(fa_center);
	    draw_set_color(c_ltgray);
	    draw_text(_cx, popup_y + popup_h - 25, "[W/S] Navigate  [ENTER] Select  [ESC] Cancel");
	}

/// ==========================================
/// RIGHT COLUMN: MODS
/// ==========================================

	/// @function DrawModsColumn(_x, _y, _width, _height, _w, _h)
	static DrawModsColumn = function(_x, _y, _width, _height, _w, _h) {
	    var padding = 20;
	    var content_x = _x + padding;
	    var content_width = _width - (padding * 2);
	    var current_y = _y + padding;
    
	    // Title
	    draw_set_halign(fa_left);
	    draw_set_valign(fa_top);
	    draw_set_font(fnt_default);
	    draw_set_color(c_lime);
	    draw_text(content_x, current_y, "AVAILABLE MODS:");
	    current_y += 30;
    
	    var available_mods = GetAvailableModsForCharacter(selected_character_class);
    
	    if (array_length(available_mods) == 0) {
	        draw_set_halign(fa_center);
	        draw_set_color(c_gray);
	        draw_text(content_x + content_width/2, current_y + 50, "No mods unlocked");
	        draw_text(content_x + content_width/2, current_y + 70, "Visit Skill Tree!");
	        return;
	    }
    
	    // Mod grid
	    var card_width = 100;
	    var card_height = 80;
	    var cols = floor(content_width / (card_width + 10));
	    var spacing_x = (content_width - (cols * card_width)) / (cols + 1);
	    var spacing_y = 10;
    
	    var grid_start_x = content_x;
	    var max_visible = cols * 3; // 3 rows visible
    
	    for (var i = 0; i < min(max_visible, array_length(available_mods)); i++) {
	        var mod_id = available_mods[i + loadout_scroll_offset];
	        if (mod_id == undefined) break;
        
	        var node = global.SkillTree[$ mod_id];
	        if (node == noone) continue;
        
	        var col = i mod cols;
	        var row = floor(i / cols);
        
	        var card_x = grid_start_x + spacing_x + (col * (card_width + spacing_x));
	        var card_y = current_y + (row * (card_height + spacing_y));
        
	        var is_equipped = IsModEquipped(mod_id, global.SaveData.career.active_loadout);
	        var is_selected = (selected_mod_index == i && selected_column == 2);
        
	        // Card background
	        draw_set_alpha(0.7);
	        var bg_color = c_dkgray;
	        if (is_equipped) bg_color = c_lime;
	        if (is_selected) bg_color = c_yellow;
	        draw_set_color(bg_color);
	        draw_rectangle(card_x, card_y, card_x + card_width, card_y + card_height, false);
	        draw_set_alpha(1);
        
	        // Border
	        draw_set_color(is_equipped ? c_lime : c_white);
	        draw_rectangle(card_x, card_y, card_x + card_width, card_y + card_height, true);
        
	        // Mod sprite
	        if (variable_struct_exists(node, "sprite") && sprite_exists(node.sprite)) {
	            draw_sprite_ext(node.sprite, 0, card_x + card_width/2, card_y + 25,
	                           0.6, 0.6, 0, c_white, 1);
	        }
        
	        // Mod name
	        draw_set_font(fnt_default);
	        draw_set_halign(fa_center);
	        draw_set_color(c_white);
	        var mod_name = node.name;
	        if (string_length(mod_name) > 11) {
	            mod_name = string_copy(mod_name, 1, 9) + "..";
	        }
	        draw_text(card_x + card_width/2, card_y + 52, mod_name);
	    }
    
	    // Scroll indicator
	    if (array_length(available_mods) > max_visible) {
	        draw_set_halign(fa_center);
	        draw_set_color(c_ltgray);
	        draw_text(content_x + content_width/2, _h - 100, 
	                 "[Scroll: " + string(loadout_scroll_offset / max_visible + 1) + "/" + 
	                 string(ceil(array_length(available_mods) / max_visible)) + "]");
	    }
	}

	/// ==========================================
	/// INPUT HANDLING
	/// ==========================================

	/// ==========================================
	/// INPUT HANDLING - FIXED WITH PROPER INPUT SYSTEM
	/// ==========================================

	/// @function HandleLoadoutSelect(_input, _audio, _mx, _my)
	static HandleLoadoutSelect = function(_input, _audio, _mx, _my) {
    
	    // Handle weapon popup separately
	    if (weapon_select_open) {
	        HandleWeaponPopupInput(_input, _audio, _mx, _my);
	        return;
	    }
    
	    // MOUSE INPUT - Check all clickable areas first
	    if (_input.FirePress) {
	        // Check weapon slots
	        if (HandleWeaponSlotClicks(_mx, _my, _audio)) return;
        
	        // Check mod cards
	        if (HandleModCardClicks(_mx, _my, _audio)) return;
	    }
    
	    // KEYBOARD/GAMEPAD NAVIGATION
	    // Use TAB to switch between weapons and mods sections
	    if (keyboard_check_pressed(vk_tab)) {
	        selected_column = (selected_column == 1) ? 2 : 1; // Toggle between weapons(1) and mods(2)
	        _audio.PlayUISound(snd_menu_hover);
	    }
    
	    // Handle input based on selected column
	    if (selected_column == 1) {
	        // WEAPONS - horizontal navigation (Left/Right)
	        HandleWeaponColumnInput(_input, _audio);
	    } else if (selected_column == 2) {
	        // MODS - grid navigation (all directions)
	        HandleModColumnInput(_input, _audio);
	    }
    
	    // BACK to character select
	    if (_input.Back || _input.Escape) {
	        _audio.PlayUISound(snd_menu_select);
        
	        // Save changes
	        SaveCharacterWeaponLoadout(selected_character_class, active_loadout_weapons);
	        SaveCharacterLoadout(selected_character_class, global.SaveData.career.active_loadout);
        
	        state = MENU_STATE.CHARACTER_SELECT;
	    }
    
	    // CONFIRM - Only if not in mod selection mode or no mod selected
	    // This prevents accidental level select when selecting mods
	    if (_input.Action && selected_column != 2) {
	        _audio.PlayUISound(snd_menu_select);
        
	        // Save both weapons and mods
	        SaveCharacterWeaponLoadout(selected_character_class, active_loadout_weapons);
	        SaveCharacterLoadout(selected_character_class, global.SaveData.career.active_loadout);
        
	        state = MENU_STATE.LEVEL_SELECT;
	        selected_level = 0;
	    }
	}

	/// ==========================================
	/// MOUSE CLICK HANDLERS
	/// ==========================================

	/// @function HandleWeaponSlotClicks(_mx, _my, _audio)
	static HandleWeaponSlotClicks = function(_mx, _my, _audio) {
	    var gui_w = display_get_gui_width();
	    var left_border = 60;
	    var stats_width = gui_w * 0.15;
	    var weapons_width = gui_w * 0.35;
    
	    var weapons_x = left_border + stats_width;
	    var content_x = weapons_x + 20;
	    var content_width = weapons_width - 40;
    
	    var slot_size = 80;
	    var slot_spacing = 100;
	    var slots_x = content_x + (content_width / 2) - slot_size - 10;
	    var slot_y = 150; // Base Y position
    
	    // Check each weapon slot
	    for (var i = 0; i < 2; i++) {
	        var slot_x = slots_x + (i * slot_spacing);
        
	        if (point_in_rectangle(_mx, _my,
	            slot_x - slot_size/2, slot_y - slot_size/2,
	            slot_x + slot_size/2, slot_y + slot_size/2)) {
            
	            selected_column = 1;
	            selected_weapon_slot = i;
	            weapon_select_open = true;
	            weapon_popup_selected = 0;
	            _audio.PlayUISound(snd_menu_select);
	            return true;
	        }
	    }
    
	    return false;
	}

	/// @function HandleModCardClicks(_mx, _my, _audio)
	static HandleModCardClicks = function(_mx, _my, _audio) {
	    var gui_w = display_get_gui_width();
	    var left_border = 60;
	    var stats_width = gui_w * 0.15;
	    var weapons_width = gui_w * 0.35;
	    var mods_width = gui_w * 0.50;
    
	    var mods_x = left_border + stats_width + weapons_width;
	    var content_x = mods_x + 20;
	    var content_width = mods_width - 40;
	    var current_y = 110; // Base Y position
    
	    var available_mods = GetAvailableModsForCharacter(selected_character_class);
	    if (array_length(available_mods) == 0) return false;
    
	    var card_width = 100;
	    var card_height = 80;
	    var cols = floor(content_width / (card_width + 10));
	    var spacing_x = (content_width - (cols * card_width)) / (cols + 1);
	    var spacing_y = 10;
    
	    var grid_start_x = content_x;
	    var max_visible = cols * 3;
    
	    // Check each visible mod card
	    for (var i = 0; i < min(max_visible, array_length(available_mods)); i++) {
	        var mod_id = available_mods[i + loadout_scroll_offset];
	        if (mod_id == undefined) break;
        
	        var node = global.SkillTree[$ mod_id];
	        if (node == noone) continue;
        
	        var col = i mod cols;
	        var row = floor(i / cols);
        
	        var card_x = grid_start_x + spacing_x + (col * (card_width + spacing_x));
	        var card_y = current_y + (row * (card_height + spacing_y));
        
	        if (point_in_rectangle(_mx, _my,
	            card_x, card_y,
	            card_x + card_width, card_y + card_height)) {
            
	            selected_column = 2;
	            selected_mod_index = i + loadout_scroll_offset;
	            ToggleModInLoadout(mod_id, _audio);
	            return true;
	        }
	    }
    
	    return false;
	}

	/// ==========================================
	/// KEYBOARD/GAMEPAD NAVIGATION
	/// ==========================================

	/// @function HandleWeaponColumnInput(_input, _audio)
	static HandleWeaponColumnInput = function(_input, _audio) {
	    // Navigate weapon slots HORIZONTALLY (Left/Right)
	    if (_input.LeftPress && selected_weapon_slot > 0) {
	        selected_weapon_slot--;
	        _audio.PlayUISound(snd_menu_hover);
	    }
	    if (_input.RightPress && selected_weapon_slot < 1) {
	        selected_weapon_slot++;
	        _audio.PlayUISound(snd_menu_hover);
	    }
    
	    // Open weapon select popup with Action button
	    if (_input.Action) {
	        weapon_select_open = true;
	        weapon_popup_selected = 0;
	        _audio.PlayUISound(snd_menu_select);
	    }
    
	    // Remove weapon with X
	    if (keyboard_check_pressed(ord("X"))) {
	        if (active_loadout_weapons[selected_weapon_slot] != noone) {
	            active_loadout_weapons[selected_weapon_slot] = noone;
	            _audio.PlayUISound(snd_menu_select);
	        }
	    }
	}

	/// @function HandleWeaponPopupInput(_input, _audio, _mx, _my)
	static HandleWeaponPopupInput = function(_input, _audio, _mx, _my) {
	    var unlocked = GetUnlockedWeaponsForCharacter(selected_character_class);
	    var cx = display_get_gui_width() / 2;
	    var cy = display_get_gui_height() / 2;
    
	    var popup_w = 400;
	    var popup_h = min(450, 120 + (array_length(unlocked) * 60));
	    var popup_x = cx - popup_w / 2;
	    var popup_y = cy - popup_h / 2;
    
	    // MOUSE INPUT - Check clicks on weapon list
	    if (_input.FirePress) {
	        var list_y = popup_y + 80;
	        var item_height = 50;
        
	        for (var i = 0; i < array_length(unlocked); i++) {
	            var item_y = list_y + (i * item_height);
            
	            if (point_in_rectangle(_mx, _my,
	                popup_x + 10, item_y - 5,
	                popup_x + popup_w - 10, item_y + item_height - 10)) {
                
	                var selected_weapon = unlocked[i];
	                active_loadout_weapons[selected_weapon_slot] = selected_weapon;
	                weapon_select_open = false;
	                _audio.PlayUISound(snd_menu_select);
	                return;
	            }
	        }
	    }
    
	    // KEYBOARD/GAMEPAD - Navigate popup list
	    if (_input.UpPress && weapon_popup_selected > 0) {
	        weapon_popup_selected--;
	        _audio.PlayUISound(snd_menu_hover);
	    }
	    if (_input.DownPress && weapon_popup_selected < array_length(unlocked) - 1) {
	        weapon_popup_selected++;
	        _audio.PlayUISound(snd_menu_hover);
	    }
    
	    // Select weapon with Action button
	    if (_input.Action) {
	        var selected_weapon = unlocked[weapon_popup_selected];
	        active_loadout_weapons[selected_weapon_slot] = selected_weapon;
	        weapon_select_open = false;
	        _audio.PlayUISound(snd_menu_select);
	    }
    
	    // Cancel with Back/Escape
	    if (_input.Back || _input.Escape) {
	        weapon_select_open = false;
	        _audio.PlayUISound(snd_menu_select);
	    }
	}

	/// @function HandleModColumnInput(_input, _audio)
	static HandleModColumnInput = function(_input, _audio) {
	    var available_mods = GetAvailableModsForCharacter(selected_character_class);
    
	    if (array_length(available_mods) == 0) return;
    
	    var gui_w = display_get_gui_width();
	    var left_border = 60;
	    var stats_width = gui_w * 0.15;
	    var weapons_width = gui_w * 0.35;
	    var mods_width = gui_w * 0.50;
    
	    var content_width = mods_width - 40;
	    var card_width = 100;
	    var cols = floor(content_width / (card_width + 10));
	    var max_visible = cols * 3;
    
	    // Grid navigation
	    var current_col = selected_mod_index mod cols;
	    var current_row = floor(selected_mod_index / cols);
    
	    // Left
	    if (_input.LeftPress && current_col > 0) {
	        selected_mod_index--;
	        _audio.PlayUISound(snd_menu_hover);
	    }
    
	    // Right
	    if (_input.RightPress && current_col < cols - 1 && 
	        selected_mod_index < array_length(available_mods) - 1) {
	        selected_mod_index++;
	        _audio.PlayUISound(snd_menu_hover);
	    }
    
	    // Up
	    if (_input.UpPress && current_row > 0) {
	        selected_mod_index -= cols;
	        if (selected_mod_index < 0) selected_mod_index = 0;
	        _audio.PlayUISound(snd_menu_hover);
	    }
    
	    // Down
	    if (_input.DownPress) {
	        var new_index = selected_mod_index + cols;
	        if (new_index < array_length(available_mods)) {
	            selected_mod_index = new_index;
	            _audio.PlayUISound(snd_menu_hover);
	        }
	    }
    
	    // Scroll handling
	    if (selected_mod_index >= loadout_scroll_offset + max_visible) {
	        loadout_scroll_offset = selected_mod_index - max_visible + 1;
	    }
	    if (selected_mod_index < loadout_scroll_offset) {
	        loadout_scroll_offset = selected_mod_index;
	    }
    
	    // Toggle mod with Action button
	    if (_input.Action) {
	        var mod_id = available_mods[selected_mod_index];
	        if (mod_id != undefined) {
	            ToggleModInLoadout(mod_id, _audio);
	        }
	    }
    
	    // Remove mod with X
	    if (keyboard_check_pressed(ord("X"))) {
	        var mod_id = available_mods[selected_mod_index];
	        if (mod_id != undefined && IsModEquipped(mod_id, global.SaveData.career.active_loadout)) {
	            for (var i = 0; i < array_length(global.SaveData.career.active_loadout); i++) {
	                if (global.SaveData.career.active_loadout[i] == mod_id) {
	                    global.SaveData.career.active_loadout[i] = noone;
	                    _audio.PlayUISound(snd_menu_select);
	                    break;
	                }
	            }
	        }
	    }
	}

	/// @function DrawCharacterActionButtons(_cx, _cy, _character_class)
	static DrawCharacterActionButtons = function(_cx, _cy, _character_class) {
	    var button_width = 180;
	    var button_height = 40;
	    var button_spacing = 200;
    
	    // Get loadout info
	    var loadout = GetCharacterLoadout(_character_class);
	    var equipped_count = CountEquippedMods(loadout);
    
	    // CONFIRM BUTTON (Left)
	    var confirm_x = _cx - button_spacing / 2;
	    var confirm_y = _cy;
    
	    draw_set_alpha(0.7);
	    draw_set_color(c_lime);
	    draw_rectangle(confirm_x - button_width/2, confirm_y - button_height/2,
	                   confirm_x + button_width/2, confirm_y + button_height/2, false);
	    draw_set_alpha(1);
    
	    draw_set_color(c_white);
	    draw_rectangle(confirm_x - button_width/2, confirm_y - button_height/2,
	                   confirm_x + button_width/2, confirm_y + button_height/2, true);
    
	    draw_set_font(fnt_default);
	    draw_set_halign(fa_center);
	    draw_set_valign(fa_middle);
	    draw_set_color(c_white);
	    draw_text(confirm_x, confirm_y - 5, "CONFIRM");
    
	    // Show equipped mod count
	    draw_set_color(equipped_count > 0 ? c_lime : c_gray);
	    draw_text(confirm_x, confirm_y + 10, "Mods: " + string(equipped_count) + "/5");
    
	    // LOADOUT BUTTON (Right)
	    var loadout_x = _cx + button_spacing / 2;
	    var loadout_y = _cy;
    
	    draw_set_alpha(0.7);
	    draw_set_color(c_aqua);
	    draw_rectangle(loadout_x - button_width/2, loadout_y - button_height/2,
	                   loadout_x + button_width/2, loadout_y + button_height/2, false);
	    draw_set_alpha(1);
    
	    draw_set_color(c_white);
	    draw_rectangle(loadout_x - button_width/2, loadout_y - button_height/2,
	                   loadout_x + button_width/2, loadout_y + button_height/2, true);
    
	    draw_set_color(c_white);
	    draw_text(loadout_x, loadout_y - 5, "CUSTOMIZE");
	    draw_text(loadout_x, loadout_y + 10, "LOADOUT");
	}

	/// @function DrawCharacterSelect(_w, _h, _cx, _cy)
	static DrawCharacterSelect = function(_w, _h, _cx, _cy) {
	    // Background
	    draw_set_color(c_black);
	    draw_set_alpha(0.8);
	    draw_rectangle(0, 0, _w, _h, false);
	    draw_set_alpha(menu_alpha);
    
	    draw_set_halign(fa_center);
	    draw_set_valign(fa_middle);
    
	    // Title
	    draw_set_font(fnt_large);
	    draw_set_color(c_yellow);
	    draw_text(_cx, 80, "SELECT CHARACTER");
    
	    var num_chars = array_length(class_options);
    
	    // Calculate indices with wrapping
	    var prev_index = (selected_class - 1 + num_chars) mod num_chars;
	    var curr_index = selected_class;
	    var next_index = (selected_class + 1) mod num_chars;
    
	    // Define positions and properties for the 3 slots
	    var slots = [
	        { // LEFT (previous)
	            target_x: _cx - 300,
	            target_y: _cy + 40,
	            target_scale: 0.7,
	            target_alpha: 0.5,
	            char_index: prev_index
	        },
	        { // CENTER (selected)
	            target_x: _cx,
	            target_y: _cy,
	            target_scale: 1.3,
	            target_alpha: 1.0,
	            char_index: curr_index
	        },
	        { // RIGHT (next)
	            target_x: _cx + 300,
	            target_y: _cy + 40,
	            target_scale: 0.7,
	            target_alpha: 0.5,
	            char_index: next_index
	        }
	    ];
    
	    // Initialize animation arrays if they don't exist
	    if (!variable_struct_exists(self, "char_positions")) {
	        char_positions = [];
	        for (var i = 0; i < num_chars; i++) {
	            array_push(char_positions, {
	                x: _cx,
	                y: _cy,
	                scale: 1.0,
	                alpha: 1.0
	            });
	        }
	    }
    
	    // Update all character positions with smooth lerp
	    for (var i = 0; i < num_chars; i++) {
	        var target_found = false;
	        var target_x = _cx;
	        var target_y = _cy + 100;
	        var target_scale = 0.5;
	        var target_alpha = 0.0;
        
	        for (var s = 0; s < array_length(slots); s++) {
	            if (slots[s].char_index == i) {
	                target_x = slots[s].target_x;
	                target_y = slots[s].target_y;
	                target_scale = slots[s].target_scale;
	                target_alpha = slots[s].target_alpha;
	                target_found = true;
	                break;
	            }
	        }
        
	        char_positions[i].x = lerp(char_positions[i].x, target_x, 0.15);
	        char_positions[i].y = lerp(char_positions[i].y, target_y, 0.15);
	        char_positions[i].scale = lerp(char_positions[i].scale, target_scale, 0.15);
	        char_positions[i].alpha = lerp(char_positions[i].alpha, target_alpha, 0.15);
	    }
    
	    // Draw all characters (draw non-selected first, then selected on top)
	    var selected_draw_data = undefined;
    
	    for (var i = 0; i < num_chars; i++) {
	        if (i == curr_index) {
	            selected_draw_data = i;
	            continue;
	        }
        
	        if (char_positions[i].alpha > 0.01) {
	            DrawCharacterCard(i, char_positions[i].x, char_positions[i].y, 
	                             char_positions[i].scale, char_positions[i].alpha, false);
	        }
	    }
    
	    // Draw selected character on top
	    if (selected_draw_data != undefined) {
	        var pos = char_positions[selected_draw_data];
	        DrawCharacterCard(selected_draw_data, pos.x, pos.y, pos.scale, pos.alpha, true);
	    }
    
	    draw_set_alpha(1);
    
	    // NEW: Draw action buttons below selected character
	    var char_data = class_options[curr_index];
	    var unlocked = IsCharacterUnlocked(char_data.type);
    
	    if (unlocked) {
	        DrawCharacterActionButtons(_cx, _cy + 200, char_data.type);
	    }
    
	    // Instructions
	    draw_set_font(fnt_default);
	    draw_set_halign(fa_center);
	    draw_set_color(c_white);
	    draw_text(_cx, _h - 60, "[A/D] or [CLICK] to Select Character");
    
	    if (unlocked) {
	        draw_text(_cx, _h - 40, "[ENTER] Continue  [L] Customize Loadout  [ESC] Back");
	    } else {
	        draw_text(_cx, _h - 40, "[ESC] Back");
	    }
	}

	/// @function DrawCharacterCard(_index, _x, _y, _scale, _alpha, _is_selected)
	static DrawCharacterCard = function(_index, _x, _y, _scale, _alpha, _is_selected) {
	    var char_data = class_options[_index];
	    var unlocked = IsCharacterUnlocked(char_data.type);
	    var char_stats = GetCharacterStats(char_data.type);
    
	    var alpha = menu_alpha * _alpha;
    
	    // Card dimensions
	    var card_width = 200 * _scale;
	    var card_height = 280 * _scale;
    
	    // Card background
	    var card_alpha = unlocked ? 0.7 : 0.3;
	    draw_set_alpha(alpha * card_alpha);
    
	    var card_color = unlocked ? char_data.color : c_dkgray;
	    draw_rectangle_color(
	        _x - card_width/2, _y - card_height/2,
	        _x + card_width/2, _y + card_height/2,
	        card_color, card_color, c_black, c_black, false
	    );
    
	    // Border
	    draw_set_alpha(alpha);
	    if (_is_selected) {
	        // Selected: bright yellow glow
	        for (var t = 0; t < 4; t++) {
	            draw_set_color(c_yellow);
	            draw_rectangle(
	                _x - card_width/2 - t, _y - card_height/2 - t,
	                _x + card_width/2 + t, _y + card_height/2 + t,
	                true
	            );
	        }
	    } else {
	        // Not selected: single border
	        draw_set_color(char_data.color);
	        draw_rectangle(
	            _x - card_width/2, _y - card_height/2,
	            _x + card_width/2, _y + card_height/2,
	            true
	        );
	    }
    
	    // Character sprite
	    if (unlocked) {
	        draw_set_alpha(alpha * 0.7);
	        draw_set_color(char_data.color);
	        draw_circle(_x, _y - 40 * _scale, 40 * _scale, false);
	        draw_set_alpha(alpha);
	        draw_sprite_ext(char_data.sprite, 0, _x, _y - 40 * _scale, 
	                       _scale, _scale, 0, c_white, alpha);
	    } else {
	        draw_set_alpha(alpha * 0.3);
	        draw_set_color(char_data.color);
	        draw_circle(_x, _y - 40 * _scale, 30 * _scale, false);
	        draw_set_alpha(alpha);
	        draw_sprite_ext(char_data.sprite, 0, _x, _y - 40 * _scale, 
	                       _scale, _scale, 0, c_black, alpha);
	    }
    
	    draw_set_alpha(alpha);
    
	    // Text - only on selected
	    if (_is_selected) {
	        draw_set_font(fnt_default);
	        draw_set_color(unlocked ? c_white : c_gray);
	        draw_text(_x, _y + 50 * _scale, char_data.name);
        
	        draw_set_color(c_ltgray);
	        draw_text_ext(_x, _y + 70 * _scale, char_data.desc, 14, 150);
        
	        // Stats
	        if (unlocked) {
	            draw_set_halign(fa_left);
	            draw_set_color(c_white);
	            var stats_x = _x - 80 * _scale;
	            var stats_y = _y + 95 * _scale;
            
	            draw_text(stats_x, stats_y, "HP: " + string(char_stats.hp_max));
	            draw_text(stats_x, stats_y + 18 * _scale, "ATK: " + string(char_stats.attack_base));
	            draw_text(stats_x, stats_y + 36 * _scale, "SPD: " + string(char_stats.move_speed));
            
	            draw_set_halign(fa_center);
	        } else {
	            draw_set_color(c_red);
	            draw_text(_x, _y + 100 * _scale, "LOCKED");
	        }
	    }
	}

	/// @function HandleCharacterSelect(_input, _audio, _mx, _my)
	static HandleCharacterSelect = function(_input, _audio, _mx, _my) {
	    var num_chars = array_length(class_options);
    
	    // Keyboard navigation
	    if (_input.LeftPress) {
	        selected_class = (selected_class - 1 + num_chars) mod num_chars;
	        _audio.PlayUISound(snd_menu_hover);
	    }
	    if (_input.RightPress) {
	        selected_class = (selected_class + 1) mod num_chars;
	        _audio.PlayUISound(snd_menu_hover);
	    }
    
	    var char_data = class_options[selected_class];
	    var unlocked = IsCharacterUnlocked(char_data.type);
    
	    // Mouse click on visible cards
	    if (_input.FirePress) {
	        for (var i = 0; i < num_chars; i++) {
	            if (!variable_struct_exists(self, "char_positions")) continue;
            
	            var pos = char_positions[i];
	            if (pos.alpha < 0.1) continue;
            
	            var card_width = 200 * pos.scale;
	            var card_height = 280 * pos.scale;
            
	            if (point_in_rectangle(_mx, _my, 
	                pos.x - card_width/2, pos.y - card_height/2,
	                pos.x + card_width/2, pos.y + card_height/2)) {
                
	                if (selected_class == i) {
	                    // Clicking selected = confirm
	                    TryConfirmCharacter(_audio);
	                } else {
	                    // Clicking other = select
	                    selected_class = i;
	                    _audio.PlayUISound(snd_menu_hover);
	                }
	                break;
	            }
	        }
        
	        // Check button clicks (only if unlocked)
	        if (unlocked) {
	            var cx = display_get_gui_width() / 2;
	            var cy = display_get_gui_height() / 2;
	            var button_y = cy + 200;
	            var button_width = 180;
	            var button_height = 40;
	            var button_spacing = 200;
            
	            // CONFIRM button
	            var confirm_x = cx - button_spacing / 2;
	            if (point_in_rectangle(_mx, _my,
	                confirm_x - button_width/2, button_y - button_height/2,
	                confirm_x + button_width/2, button_y + button_height/2)) {
                
	                _audio.PlayUISound(snd_menu_select);
	                TryConfirmCharacter(_audio);
	            }
            
	            // LOADOUT button
	            var loadout_x = cx + button_spacing / 2;
	            if (point_in_rectangle(_mx, _my,
	                loadout_x - button_width/2, button_y - button_height/2,
	                loadout_x + button_width/2, button_y + button_height/2)) {
                
	                _audio.PlayUISound(snd_menu_select);
	                OpenLoadoutScreen(_audio);
	            }
	        }
	    }
    
	    // Keyboard shortcuts
	    if (unlocked) {
	        // ENTER = Confirm
	        if (_input.Action) {
	            TryConfirmCharacter(_audio);
	        }
        
	        // L = Loadout
	        if (keyboard_check_pressed(ord("L"))) {
	            _audio.PlayUISound(snd_menu_select);
	            OpenLoadoutScreen(_audio);
	        }
	    }
    
	    // Back
	    if (_input.Back || _input.Escape) {
	        _audio.PlayUISound(snd_menu_select);
	        state = MENU_STATE.MAIN;
	        selected_option = 0;
	    }
	}
	
	/// @function TryConfirmCharacter(_audio)
	static TryConfirmCharacter = function(_audio) {
	    var char_data = class_options[selected_class];
    
	    if (!IsCharacterUnlocked(char_data.type)) {
	        _audio.PlayUISound(snd_menu_select);
	        show_debug_message("Character locked!");
	        return;
	    }
    
	    _audio.PlayUISound(snd_menu_select);
	    selected_character_class = char_data.type;
    
	    // Auto-equip last used loadout
	    LoadCharacterLoadout(selected_character_class);
    
	    // Skip loadout screen, go straight to level select
	    state = MENU_STATE.LEVEL_SELECT;
	    selected_level = 0;
	}

	/// @function OpenLoadoutScreen(_audio)
	static OpenLoadoutScreen = function(_audio) {
	    var char_data = class_options[selected_class];
    
	    if (!IsCharacterUnlocked(char_data.type)) {
	        return;
	    }
    
	    selected_character_class = char_data.type;
    
	    // Load current mod loadout
	    LoadCharacterLoadout(selected_character_class);
    
	    // Load current weapon loadout
	    active_loadout_weapons = GetCharacterWeaponLoadout(selected_character_class);
    
	    // Go to loadout screen
	    state = MENU_STATE.LOADOUT_SELECT;
	    loadout_selected_slot = 0;
	    loadout_scroll_offset = 0;
	    loadout_weapon_slot = 0;
	}

    // ==========================================
    // LEVEL SELECT
    // ==========================================
    
    /// @function DrawLevelSelect(_w, _h, _cx, _cy)
    static DrawLevelSelect = function(_w, _h, _cx, _cy) {
        draw_set_color(c_black);
        draw_set_alpha(0.8);
        draw_rectangle(0, 0, _w, _h, false);
        draw_set_alpha(menu_alpha);
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        // Title
        draw_set_font(fnt_large);
        draw_set_color(c_yellow);
        draw_text(_cx, 80, "SELECT LEVEL");
        
        // Level cards
        var card_width = 180;
        var card_height = 240;
        var card_spacing = 220;
        
        for (var i = 0; i < array_length(level_options); i++) {
            var level_data = level_options[i];
            var xx = _cx + (i - 1) * card_spacing;
            var yy = _cy + 20;
            var is_selected = (i == selected_level);
            var scale = is_selected ? 1.1 : 1.0;
            var unlocked = IsLevelUnlocked(level_data.id);
            
            // Card background
            var card_alpha = unlocked ? (is_selected ? 0.8 : 0.5) : 0.3;
            draw_set_alpha(menu_alpha * card_alpha);
            
            var card_color = unlocked ? c_dkgray : c_black;
            draw_rectangle_color(
                xx - card_width/2 * scale, yy - card_height/2 * scale,
                xx + card_width/2 * scale, yy + card_height/2 * scale,
                card_color, card_color, c_black, c_black, false
            );
            
            // Border
            draw_set_alpha(menu_alpha);
            var border_color = is_selected ? c_yellow : c_white;
            draw_set_color(border_color);
            draw_rectangle(
                xx - card_width/2 * scale, yy - card_height/2 * scale,
                xx + card_width/2 * scale, yy + card_height/2 * scale,
                true
            );
            
            // Level preview
            if (unlocked) {
                draw_set_alpha(menu_alpha * 0.6);
                draw_set_color(make_color_hsv((i * 40) mod 255, 100, 200));
                draw_rectangle(xx - 60, yy - 70, xx + 60, yy - 10, false);
                draw_set_alpha(menu_alpha);
            } else {
                draw_set_alpha(menu_alpha * 0.5);
                draw_set_color(c_red);
                draw_circle(xx, yy - 40, 30, false);
                draw_set_color(c_white);
                draw_set_font(fnt_large);
                draw_text(xx, yy - 40, "?");
            }
            
            draw_set_alpha(menu_alpha);
            
            // Level info
            draw_set_font(fnt_default);
            draw_set_color(unlocked ? c_white : c_gray);
            draw_text(xx, yy - 96, level_data.name);
            
            // Difficulty color
            var diff_color = c_white;
            switch(level_data.difficulty) {
                case "Normal": diff_color = c_lime; break;
                case "Hard": diff_color = c_orange; break;
                case "Nightmare": diff_color = c_red; break;
            }
            draw_set_color(diff_color);
            draw_text(xx, yy - 82, level_data.difficulty);
            
            // Description
            draw_set_color(c_ltgray);
			
            draw_text_ext(xx, yy + 60, level_data.description, 14, 150);
            
            // Lock requirement
            if (!unlocked && variable_struct_exists(level_data, "unlock_requirement")) {
                draw_set_color(c_red);
                draw_text(xx, yy + 112, level_data.unlock_requirement);
            }
        }
        
        // Instructions
        draw_set_font(fnt_default);
        draw_set_halign(fa_center);
        draw_set_color(c_white);
        draw_text(_cx, _h - 60, "[A/D] Select Level");
        draw_text(_cx, _h - 40, "[ENTER] Start Game  [ESC] Back");
        
        draw_set_alpha(1);
    }
    
    /// @function HandleLevelSelect(_input, _audio, _mx, _my)
    static HandleLevelSelect = function(_input, _audio, _mx, _my) {
        var cx = display_get_gui_width() / 2;
        var cy = display_get_gui_height() / 2 + 20;
        
        // Navigation
        if (_input.LeftPress) {
            selected_level = (selected_level - 1 + array_length(level_options)) mod array_length(level_options);
            _audio.PlayUISound(snd_menu_hover);
        }
        if (_input.RightPress) {
            selected_level = (selected_level + 1) mod array_length(level_options);
            _audio.PlayUISound(snd_menu_hover);
        }
        
        // Mouse hover
        var card_spacing = 220;
        for (var i = 0; i < array_length(level_options); i++) {
            var xx = cx + (i - 1) * card_spacing;
            var is_selected = (i == selected_level);
            var scale = is_selected ? 1.1 : 1.0;
            var card_width = 180 * scale;
            var card_height = 240 * scale;
            
            if (point_in_rectangle(_mx, _my, xx - card_width/2, cy - card_height/2, 
                                             xx + card_width/2, cy + card_height/2)) {
                if (selected_level != i) {
                    selected_level = i;
                    _audio.PlayUISound(snd_menu_hover);
                }
                
                if (_input.FirePress) {
                    TryStartGame(_audio);
                }
            }
        }
        
        // Confirm
        if (_input.Action) {
            TryStartGame(_audio);
        }
        
        // Back
        if (_input.Back || _input.Escape) {
            _audio.PlayUISound(snd_menu_select);
            state = MENU_STATE.CHARACTER_SELECT;
        }
    }
    
    /// @function TryStartGame(_audio)
    static TryStartGame = function(_audio) {
        var level_data = level_options[selected_level];
        
        if (!IsLevelUnlocked(level_data.id)) {
            _audio.PlayUISound(snd_menu_select);
            show_debug_message("Level locked!");
            return;
        }
        
        _audio.PlayUISound(snd_menu_select);
        RecordRunStart(selected_character_class);
        room_goto(level_data.room);
    }
    
    // ==========================================
    // UNLOCKS SCREEN
    // ==========================================
    
	/// @function DrawUnlocks(_w, _h, _cx, _cy)
	static DrawUnlocks = function(_w, _h, _cx, _cy) {
	    // Initialize skill tree if not exists
	    if (!variable_struct_exists(self, "skill_tree")) {
	        skill_tree = new SkillTreeSystem();
	    }
    
	    // Get player souls
	    var player_souls = GetSouls();
    
	    // Draw skill tree
	    skill_tree.Draw(_w, _h, _cx, _cy, player_souls);
	}
    
    // ==========================================
    // STATS SCREEN
    // ==========================================
    
    /// @function DrawStats(_w, _h, _cx, _cy)
    static DrawStats = function(_w, _h, _cx, _cy) {
        draw_set_color(c_black);
        draw_set_alpha(0.8);
        draw_rectangle(0, 0, _w, _h, false);
        draw_set_alpha(menu_alpha);
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_font(fnt_large);
        draw_set_color(c_yellow);
        draw_text(_cx, 60, "CAREER STATS");
        
        var career = global.SaveData.career;
        
        draw_set_font(fnt_default);
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        
        var stats_x = _cx - 200;
        var stats_y = 140;
        var line_height = 25;
        
        draw_text(stats_x, stats_y, "Total Runs: " + string(career.total_runs));
        draw_text(stats_x, stats_y + line_height, "Total Kills: " + string(career.total_kills));
        draw_text(stats_x, stats_y + line_height * 2, "Total Deaths: " + string(career.total_deaths));
        draw_text(stats_x, stats_y + line_height * 3, "Total Score: " + string(career.total_score));
        
        draw_set_color(c_yellow);
        draw_text(stats_x, stats_y + line_height * 5, "BEST RUN:");
        draw_set_color(c_white);
        draw_text(stats_x, stats_y + line_height * 6, "Score: " + string(career.best_score));
        draw_text(stats_x, stats_y + line_height * 7, "Time: " + string(career.best_time_seconds) + "s");
        
        draw_set_halign(fa_center);
        draw_set_color(c_gray);
        draw_text(_cx, _h - 40, "[ESC] Back to Menu");
        
        draw_set_alpha(1);
    }
    
    /// @function HandleStats(_input, _audio)
    static HandleStats = function(_input, _audio) {
        if (_input.Back || _input.Escape) {
            _audio.PlayUISound(snd_menu_select);
            state = MENU_STATE.MAIN;
            selected_option = 2;
        }
    }
    
    // ==========================================
    // SETTINGS SCREEN
    // ==========================================

    /// @function DrawSettings(_w, _h, _cx, _cy, _audio_sys)
	static DrawSettings = function(_w, _h, _cx, _cy, _audio_sys) {
	    // Background
	    draw_set_color(c_black);
	    draw_set_alpha(0.8);
	    draw_rectangle(0, 0, _w, _h, false);
	    draw_set_alpha(1);
    
	    // Title
	    draw_set_halign(fa_center);
	    draw_set_valign(fa_middle);
	    draw_set_font(fnt_large);
	    draw_set_color(c_yellow); // Yellow title
	    draw_text(_cx, _cy - 150, "SETTINGS");
    
	    // Volume sections
	    draw_set_font(fnt_default);
	    draw_set_color(c_white); // WHITE text for labels
    
		var _x_offset = 64;
	
	    var master_y = _cy - 60;
	    //draw_set_halign(fa_right); // Right-align labels
	    draw_text(_cx - _x_offset, master_y, "Master:");
	    DrawVolumeBar(_cx + 100, master_y, _audio_sys.settings.master_volume);
    
	    var music_y = _cy - 20;
	    draw_text(_cx - _x_offset, music_y, "Music:");
	    DrawVolumeBar(_cx + 100, music_y, _audio_sys.music_master_volume);
    
	    var sfx_y = _cy + 20;
	    draw_text(_cx - _x_offset, sfx_y, "SFX:");
	    DrawVolumeBar(_cx + 100, sfx_y, _audio_sys.sfx_master_volume);
    
	    var voice_y = _cy + 60;
	    draw_text(_cx - _x_offset, voice_y, "Voice:");
	    DrawVolumeBar(_cx + 100, voice_y, _audio_sys.voice_volume);
    
	    // Back button
	   // draw_set_halign(fa_center);
	    var is_selected = (selected_option == 4);
	    draw_set_font(is_selected ? fnt_large : fnt_default);
	    var col = is_selected ? c_yellow : c_white;
	    draw_text_color(_cx, _cy + 120, "BACK", col, col, col, col, 1);
    
	    // Instructions
	    draw_set_font(fnt_default);
	    draw_set_color(c_gray);
	    draw_text(_cx, _h - 40, "[LEFT/RIGHT] Adjust  [ESC] Back  [F1] Reset Data & Reset");
	}
    
	  /// @function HandleSettings(_input, _audio, _mx, _my)
	static HandleSettings = function(_input, _audio, _mx, _my) {
	    var cx = display_get_gui_width() / 2;
	    var cy = display_get_gui_height() / 2;
	    var settings_count = 5; // Master, Music, SFX, Voice, Back
    
	    // Keyboard navigation
	    if (_input.UpPress) {
	        selected_option = (selected_option - 1 + settings_count) mod settings_count;
	        _audio.PlayUISound(snd_menu_hover);
	    }
	    if (_input.DownPress) {
	        selected_option = (selected_option + 1) mod settings_count;
	        _audio.PlayUISound(snd_menu_hover);
	    }
    
	    // Mouse hover detection for volume bars
	    var volume_bar_positions = [
	        { y: cy - 60, index: 0 },  // Master
	        { y: cy - 20, index: 1 },  // Music
	        { y: cy + 20, index: 2 },  // SFX
	        { y: cy + 60, index: 3 }   // Voice
	    ];
    
	    var bar_width = 200;
	    var bar_height = 20;
	    var bar_x_center = cx + 100; // Matches DrawSettings positioning
    
	    // Check volume bar hovers
	    for (var i = 0; i < array_length(volume_bar_positions); i++) {
	        var bar_data = volume_bar_positions[i];
	        var bar_x = bar_x_center - bar_width / 2;
	        var bar_y = bar_data.y - bar_height / 2;
        
	        if (point_in_rectangle(_mx, _my, bar_x, bar_y, bar_x + bar_width, bar_y + bar_height)) {
	            // Hover
	            if (selected_option != bar_data.index) {
	                selected_option = bar_data.index;
	                _audio.PlayUISound(snd_menu_hover);
	            }
            
	            // Click and drag to set volume
	            if (_input.FirePress || mouse_check_button(mb_left)) {
	                var click_pos = clamp((_mx - bar_x) / bar_width, 0, 1);
                
	                switch(bar_data.index) {
	                    case 0: _audio.SetMasterVolume(click_pos); break;
	                    case 1: _audio.SetMusicVolume(click_pos); break;
	                    case 2: 
	                        _audio.SetSFXVolume(click_pos);
	                        if (_input.FirePress) _audio.PlaySFX(snd_menu_select);
	                        break;
	                    case 3: _audio.SetVoiceVolume(click_pos); break;
	                }
	            }
	        }
	    }
    
	    // Mouse hover on back button
	    var back_y = cy + 120;
	    if (point_in_rectangle(_mx, _my, cx - 100, back_y - 25, cx + 100, back_y + 25)) {
	        if (selected_option != 4) {
	            selected_option = 4;
	            _audio.PlayUISound(snd_menu_hover);
	        }
        
	        if (_input.FirePress) {
	            _audio.PlayUISound(snd_menu_select);
	            state = MENU_STATE.MAIN;
	            selected_option = 3;
	            SaveAudioSettings(_audio);
	        }
	    }
    
	    // Keyboard adjust volumes
	    var adjustment = 0;
	    if (_input.LeftPress) adjustment = -0.1;
	    if (_input.RightPress) adjustment = 0.1;
    
	    if (adjustment != 0 && selected_option < 4) {
	        _audio.PlayUISound(snd_menu_select);
        
	        switch(selected_option) {
	            case 0: _audio.SetMasterVolume(_audio.settings.master_volume + adjustment); break;
	            case 1: _audio.SetMusicVolume(_audio.music_master_volume + adjustment); break;
	            case 2: 
	                _audio.SetSFXVolume(_audio.sfx_master_volume + adjustment);
	                _audio.PlaySFX(snd_menu_select);
	                break;
	            case 3: _audio.SetVoiceVolume(_audio.voice_volume + adjustment); break;
	        }
        
	        SaveAudioSettings(_audio);
	    }
    
	    // Back button (keyboard)
	    if (selected_option == 4 && _input.Action) {
	        _audio.PlayUISound(snd_menu_select);
	        state = MENU_STATE.MAIN;
	        selected_option = 3;
	        SaveAudioSettings(_audio);
	    }
    
	    // ESC to go back
	    if (_input.Escape) {
	        _audio.PlayUISound(snd_menu_select);
	        state = MENU_STATE.MAIN;
	        selected_option = 3;
	        SaveAudioSettings(_audio);
	    }
	if (keyboard_check(vk_f1)) {
        ResetSaveData();
        show_message("Save data reset!");
		game_restart();
    }
	}
    
    // ==========================================
    // PAUSE MENU
    // ==========================================
    
    /// @function DrawPauseMenu(_w, _h, _cx, _cy)
	static DrawPauseMenu = function(_w, _h, _cx, _cy, _mx, _my) {
	    // Dark overlay
	    drawAlphaRectangle(0, 0, _w, _h, 0.8);
    
	    // Check which sub-screen to show
	    if (show_controls) {
	        DrawControlsScreen(_w, _h, _cx, _cy);
	        return;
	    }
    
	    if (show_stats) {
	        DrawPauseStatsScreen(_w, _h, _cx, _cy, _mx, _my);
	        return;
	    }
    
	    if (show_pause_settings) {
	        DrawPauseSettingsScreen(_w, _h, _cx, _cy);
	        return;
	    }
    
	    if (show_missions) {
	        DrawMissionsScreen(_w, _h, _cx, _cy);
	        return;
	    }
    
	    // Main pause menu panel
	    var panel_w = 400;
	    var panel_h = 450; // Taller for more options
	    var panel_x = _cx - panel_w / 2;
	    var panel_y = _cy - panel_h / 2;
    
	    draw_set_color(c_dkgray);
	    draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);
	    draw_set_color(c_white);
	    draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, true);
    
	    // Title
	    draw_set_halign(fa_center);
	    draw_set_valign(fa_top);
	    draw_set_font(fnt_large);
	    draw_set_color(c_yellow);
	    draw_text(_cx, panel_y + 20, "PAUSED");
    
	    // Options
	    draw_set_font(fnt_default);
	    var start_y = _cy - 100;
	    for (var i = 0; i < array_length(pause_options); i++) {
	        var yy = start_y + i * 45;
	        var is_selected = (i == pause_selected);
        
	        if (is_selected) {
	            draw_set_alpha(0.3);
	            draw_set_color(c_yellow);
	            draw_rectangle(_cx - 140, yy - 18, _cx + 140, yy + 18, false);
	            draw_set_alpha(1);
	        }
        
	        var col = is_selected ? c_yellow : c_white;
	        draw_set_color(col);
	        draw_set_halign(fa_center);
	        draw_set_valign(fa_middle);
	        draw_text(_cx, yy, pause_options[i]);
	    }
    
	    // Instructions
	    draw_set_color(c_ltgray);
	    draw_set_halign(fa_center);
	    draw_set_valign(fa_bottom);
	    draw_text(_cx, panel_y + panel_h - 15, "ESC to Resume");
	}
    
	/// @function DrawControlsScreen(_w, _h, _cx, _cy)
	static DrawControlsScreen = function(_w, _h, _cx, _cy) {
	    var panel_w = 600;
	    var panel_h = 500;
	    var panel_x = _cx - panel_w / 2;
	    var panel_y = _cy - panel_h / 2;
        
	    draw_set_color(c_dkgray);
	    draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);
	    draw_set_color(c_white);
	    draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, true);
        
	    draw_set_halign(fa_center);
	    draw_set_valign(fa_top);
	    draw_set_font(fnt_large);
	    draw_set_color(c_yellow);
	    draw_text(_cx, panel_y + 20, "CONTROLS");
        
	    // Controls list
	    draw_set_font(fnt_default);
	    draw_set_color(c_white);
	    draw_set_halign(fa_left);
        
	    var start_y = panel_y + 70;
	    var line_h = 25;
	    var left_x = panel_x + 40;
        
	    var controls = [
	        "WASD - Move",
	        "Mouse - Aim",
	        "Left Click - Attack",
	        "Right Click - Special Attack",
	        "E - Interact / Pickup",
	        "Q - Drop Item",
	        "1/2 - Switch Weapons",
	        "SPACE - Dash/Dodge",
	        "ESC - Pause Menu"
	    ];
        
	    for (var i = 0; i < array_length(controls); i++) {
	        draw_text(left_x, start_y + i * line_h, controls[i]);
	    }
        
	    draw_set_halign(fa_center);
	    draw_set_valign(fa_bottom);
	    draw_set_color(c_ltgray);
	    draw_text(_cx, panel_y + panel_h - 30, "ESC to return");
	}
    
	static DrawPauseStatsScreen = function(_w, _h, _cx, _cy, _mx, _my) {
	    var panel_w = 700;
	    var panel_h = 500;
	    var panel_x = _cx - panel_w / 2;
	    var panel_y = _cy - panel_h / 2;
    
	    draw_set_color(c_dkgray);
	    draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);
	    draw_set_color(c_white);
	    draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, true);
    
	    draw_set_halign(fa_center);
	    draw_set_valign(fa_top);
	    draw_set_font(fnt_large);
	    draw_set_color(c_yellow);
	    draw_text(_cx, panel_y + 20, "PLAYER STATS");
    
	    if (!instance_exists(obj_player)) {
	        draw_set_font(fnt_default);
	        draw_set_color(c_red);
	        draw_set_valign(fa_middle);
	        draw_text(_cx, _cy, "Player not found");
	        return;
	    }
    
	    draw_set_font(fnt_default);
	    draw_set_color(c_white);
	    draw_set_halign(fa_left);
	    draw_set_valign(fa_top);
    
	    var col1_x = panel_x + 40;
	    var col2_x = panel_x + 360;
	    var start_y = panel_y + 80;
	    var line_h = 30;
    
	    // Left column - Basic stats
	    draw_set_color(c_yellow);
	    draw_text(col1_x, start_y, "BASIC STATS:");
	    draw_set_color(c_white);
    
	    var current_hp = obj_player.damage_sys.hp;
	    var max_hp = obj_player.damage_sys.max_hp;
    
	    draw_text(col1_x, start_y + line_h, "HP: " + string(floor(current_hp)) + "/" + string(max_hp));
	    draw_text(col1_x, start_y + line_h * 2, "Attack: " + string(floor(obj_player.stats.attack)));
	    draw_text(col1_x, start_y + line_h * 3, "Speed: " + string_format(obj_player.stats.speed, 1, 1));
	    draw_text(col1_x, start_y + line_h * 4, "Level: " + string(obj_player.player_level));
    
	    // Character class name
	    var class_name = "Unknown";
	    switch(obj_player.character_class) {
	        case CharacterClass.WARRIOR: class_name = "Warrior"; break;
	        case CharacterClass.HOLY_MAGE: class_name = "Holy Mage"; break;
	        case CharacterClass.VAMPIRE: class_name = "Vampire"; break;
	    }
	    draw_text(col1_x, start_y + line_h * 5, "Class: " + class_name);
    
	    // Right column - Active modifiers WITH INTERACTION
	    draw_set_color(c_yellow);
	    draw_text(col2_x, start_y, "ACTIVE MODIFIERS: " + string(array_length(obj_player.mod_list)));
	    draw_set_color(c_white);
    
	    var mod_y = start_y + line_h;
	    var mods_to_display = [];
    
	    // Get mods from game_manager.playerModsArray or player.mod_list
	    if (instance_exists(obj_game_manager) && 
	        variable_instance_exists(obj_game_manager, "playerModsArray") && 
	        array_length(obj_game_manager.playerModsArray) > 0) {
	        mods_to_display = obj_game_manager.playerModsArray;
	    }
	    else if (variable_instance_exists(obj_player, "mod_list") && 
	             array_length(obj_player.mod_list) > 0) {
	        mods_to_display = obj_player.mod_list;
	    }
		
	    // Track which mod is hovered/selected
	    var hovered_mod = -1;
    
	    // Draw the mods with interaction
	    if (array_length(mods_to_display) > 0) {
	        for (var i = 0; i < min(10, array_length(mods_to_display)); i++) {
	            var _mod = mods_to_display[i];
	            var mod_name = "Unknown Mod";
	            var stack_info = "";
	            var mod_sprite = spr_mod_default;
	            var template = undefined;
            
	            // Get mod data
	            if (variable_struct_exists(_mod, "name")) {
	                mod_name = _mod.name;
	            } else if (variable_struct_exists(_mod, "template_key")) {
	                // Get sprite using game_manager function
	                if (instance_exists(obj_game_manager)) {
	                    mod_sprite = obj_game_manager.GetModifierSprite(_mod.template_key);
	                }
                
	                // Get name and description from template
	                if (variable_struct_exists(global.Modifiers, _mod.template_key)) {
	                    template = global.Modifiers[$ _mod.template_key];
	                    if (variable_struct_exists(template, "name")) {
	                        mod_name = template.name;
	                    } else {
	                        mod_name = _mod.template_key;
	                    }
	                } else {
	                    mod_name = _mod.template_key;
	                }
	            }
            
	            // Stack level
	            if (variable_struct_exists(_mod, "stack_level") && _mod.stack_level > 1) {
	                stack_info = " x" + string(_mod.stack_level);
	            }
            
	            var mod_line_y = mod_y + (i * 32);
	            var mod_icon_x = col2_x;
	            var mod_icon_y = mod_line_y + 12;
	            var mod_text_x = col2_x + 28;
            
	            // Check hover/selection
	            var is_hovered = point_in_rectangle(_mx, _my, 
	                col2_x - 4, mod_line_y - 2, 
	                panel_x + panel_w - 20, mod_line_y + 28);
            
	            var is_selected = (stats_selected_mod == i);
            
	            if (is_hovered || is_selected) {
	                hovered_mod = i;
                
	                // Highlight background
	                draw_set_alpha(0.3);
	                draw_set_color(c_yellow);
	                draw_rectangle(col2_x - 4, mod_line_y - 2, 
	                              panel_x + panel_w - 20, mod_line_y + 28, false);
	                draw_set_alpha(1);
	            }
            
	            // Draw mod sprite
	            draw_sprite_ext(mod_sprite, 0, mod_icon_x, mod_icon_y, 0.5, 0.5, 0, c_white, 1);
            
	            // Draw mod name
	            draw_set_color(is_hovered || is_selected ? c_yellow : c_white);
	            draw_text(mod_text_x, mod_line_y + 6, mod_name + stack_info);
	            draw_set_color(c_white);
	        }
        
	        // Show count if there are more
	        if (array_length(mods_to_display) > 10) {
	            draw_set_color(c_gray);
	            draw_text(col2_x, mod_y + (10 * 32), "+" + string(array_length(mods_to_display) - 10) + " more...");
	        }
        
	        // TOOLTIP: Draw mod description if hovering/selected
	        if (hovered_mod >= 0 && hovered_mod < array_length(mods_to_display)) {
	            DrawModTooltip(mods_to_display[hovered_mod], _mx, _my, panel_x, panel_y, panel_w, panel_h);
	        }
	    } else {
	        draw_set_color(c_gray);
	        draw_text(col2_x, mod_y, "No active modifiers");
	    }
    
	    draw_set_color(c_white);
    
	    // Bottom - Current weapons
	    draw_set_color(c_yellow);
	    draw_text(col1_x, panel_y + panel_h - 120, "EQUIPPED WEAPONS:");
	    draw_set_color(c_white);
    
	    var weapon_y = panel_y + panel_h - 90;
    
	    if (variable_instance_exists(obj_player, "weapons")) {
	        draw_text(col1_x, weapon_y, "Slot 1: " + (obj_player.weapons[0] != noone ? "Equipped" : "Empty"));
	        draw_text(col1_x, weapon_y + 25, "Slot 2: " + (array_length(obj_player.weapons) > 1 && obj_player.weapons[1] != noone ? "Equipped" : "Empty"));
	    }
    
	    // Instructions
	    draw_set_halign(fa_center);
	    draw_set_valign(fa_bottom);
	    draw_set_color(c_ltgray);
	    draw_text(_cx, panel_y + panel_h - 30, "[UP/DOWN] or [HOVER] to view mod details  [ESC] to return");
	}

	/// @function DrawModTooltip(_mod, _mx, _my, _panel_x, _panel_y, _panel_w, _panel_h)
	static DrawModTooltip = function(_mod, _mx, _my, _panel_x, _panel_y, _panel_w, _panel_h) {
	    var tooltip_w = 300;
	    var tooltip_h = 150;
    
	    // Position tooltip to the left of the stats panel
	    var tooltip_x = display_get_gui_width() - (_panel_w * 0.5) + 24;
	    var tooltip_y = _panel_y + tooltip_h;
    
	    // Keep tooltip on screen
	    tooltip_y = clamp(tooltip_y, 10, display_get_gui_height() - tooltip_h - 10);
	    if (tooltip_x < 10) {
	        // If no room on left, put on right
	        tooltip_x = display_get_gui_width() - _panel_w + 20;
	    }
    
	    // Get mod data
	    var mod_name = "Unknown";
	    var mod_desc = "No description available.";
	    var mod_sprite = spr_mod_default;
    
	    if (variable_struct_exists(_mod, "template_key")) {
	        // Get sprite
	        if (instance_exists(obj_game_manager)) {
	            mod_sprite = obj_game_manager.GetModifierSprite(_mod.template_key);
	        }
        
	        // Get template data
	        if (variable_struct_exists(global.Modifiers, _mod.template_key)) {
	            var template = global.Modifiers[$ _mod.template_key];
            
	            if (variable_struct_exists(template, "name")) {
	                mod_name = template.name;
	            }
	            if (variable_struct_exists(template, "description")) {
	                mod_desc = template.description;
	            }
	        }
	    } else if (variable_struct_exists(_mod, "name")) {
	        mod_name = _mod.name;
	        if (variable_struct_exists(_mod, "description")) {
	            mod_desc = _mod.description;
	        }
	    }
    
	    // Background
	    draw_set_alpha(0.95);
	    draw_set_color(c_black);
	    draw_rectangle(tooltip_x, tooltip_y, tooltip_x + tooltip_w, tooltip_y + tooltip_h, false);
	    draw_set_alpha(1);
    
	    // Border
	    draw_set_color(c_yellow);
	    draw_rectangle(tooltip_x, tooltip_y, tooltip_x + tooltip_w, tooltip_y + tooltip_h, true);
	    draw_rectangle(tooltip_x + 1, tooltip_y + 1, tooltip_x + tooltip_w - 1, tooltip_y + tooltip_h - 1, true);
    
	    // Sprite (large)
	    var sprite_x = tooltip_x + 40;
	    var sprite_y = tooltip_y + 40;
	    draw_sprite_ext(mod_sprite, 0, sprite_x, sprite_y, 1, 1, 0, c_white, 1);
    
	    // Name
	    draw_set_halign(fa_left);
	    draw_set_valign(fa_top);
	    draw_set_font(fnt_default);
	    draw_set_color(c_yellow);
	    draw_text(tooltip_x + 80, tooltip_y + 15, mod_name);
    
	    // Stack level
	    if (variable_struct_exists(_mod, "stack_level") && _mod.stack_level > 1) {
	        draw_set_color(c_lime);
	        draw_text(tooltip_x + 80, tooltip_y + 35, "Level: " + string(_mod.stack_level));
	    }
    
	    // Description (wrapped)
	    draw_set_color(c_white);
	    draw_text_ext(tooltip_x + 10, tooltip_y + 70, mod_desc, 14, tooltip_w - 20);
	}

	/// @function HandlePauseSettings(_input, _audio, _mx, _my)
	static HandlePauseSettings = function(_input, _audio, _mx, _my) {
	    var cx = display_get_gui_width() / 2;
	    var cy = display_get_gui_height() / 2;
	    var panel_y = cy - 250;
	    var start_y = panel_y + 80;
	    var line_h = 50;
    
	    // Selection system (0=Master, 1=Music, 2=SFX, 3=Screen Shake)
	    if (!variable_struct_exists(self, "pause_settings_selected")) {
	        pause_settings_selected = 0;
	    }
    
	    // Navigation
	    if (_input.UpPress) {
	        pause_settings_selected = (pause_settings_selected - 1 + 4) mod 4;
	        _audio.PlayUISound(snd_menu_hover);
	    }
	    if (_input.DownPress) {
	        pause_settings_selected = (pause_settings_selected + 1) mod 4;
	        _audio.PlayUISound(snd_menu_hover);
	    }
    
	    // Adjust volumes with keyboard
	    var adjustment = 0;
	    if (_input.LeftPress) adjustment = -0.1;
	    if (_input.RightPress) adjustment = 0.1;
    
	    if (adjustment != 0) {
	        _audio.PlayUISound(snd_menu_select);
        
	        switch(pause_settings_selected) {
	            case 0: // Master
	                _audio.SetMasterVolume(_audio.settings.master_volume + adjustment);
	                break;
	            case 1: // Music
	                _audio.SetMusicVolume(_audio.music_master_volume + adjustment);
	                break;
	            case 2: // SFX
	                _audio.SetSFXVolume(_audio.sfx_master_volume + adjustment);
	                _audio.PlaySFX(snd_menu_select);
	                break;
	        }
        
	        obj_main_controller.menu_system.SaveAudioSettings(_audio);
	    }
    
	    // Screen shake toggle with Enter/Space
	    if (pause_settings_selected == 3 && _input.Action) {
	        global.screen_shake = !global.screen_shake;
	        _audio.PlayUISound(snd_menu_select);
	        SaveGame();
	    }
    
	    // Mouse interactions - Volume bars
	    var volume_bar_positions = [
	        { y: start_y, index: 0, type: "master" },
	        { y: start_y + line_h, index: 1, type: "music" },
	        { y: start_y + line_h * 2, index: 2, type: "sfx" }
	    ];
    
	    var bar_width = 200;
	    var bar_height = 20;
	    var bar_x_center = cx + 100;
    
	    for (var i = 0; i < array_length(volume_bar_positions); i++) {
	        var bar_data = volume_bar_positions[i];
	        var bar_x = bar_x_center - bar_width / 2;
	        var bar_y = bar_data.y - bar_height / 2;
        
	        if (point_in_rectangle(_mx, _my, bar_x, bar_y, bar_x + bar_width, bar_y + bar_height)) {
	            // Hover select
	            pause_settings_selected = bar_data.index;
            
	            // Click/drag to set
	            if (_input.FirePress || mouse_check_button(mb_left)) {
	                var click_pos = clamp((_mx - bar_x) / bar_width, 0, 1);
                
	                switch(bar_data.type) {
	                    case "master":
	                        _audio.SetMasterVolume(click_pos);
	                        break;
	                    case "music":
	                        _audio.SetMusicVolume(click_pos);
	                        break;
	                    case "sfx":
	                        _audio.SetSFXVolume(click_pos);
	                        if (_input.FirePress) _audio.PlaySFX(snd_menu_select);
	                        break;
	                }
                
	                obj_main_controller.menu_system.SaveAudioSettings(_audio);
	            }
	        }
	    }
    
	    // Screen shake toggle - mouse click
	    var shake_toggle_x = cx + 80;
	    var shake_toggle_y = start_y + line_h * 3.5;
    
	    if (point_in_rectangle(_mx, _my, 
	        shake_toggle_x - 40, shake_toggle_y - 15,
	        shake_toggle_x + 40, shake_toggle_y + 15)) {
        
	        pause_settings_selected = 3;
        
	        if (_input.FirePress) {
	            global.screen_shake = !global.screen_shake;
	            _audio.PlayUISound(snd_menu_select);
	            SaveGame();
	        }
	    }
	} 
  
	static HandlePauseMenu = function(_input, _audio, _mx, _my) {
	    var cx = display_get_gui_width() / 2;
	    var cy = display_get_gui_height() / 2;
    
	
	    // Handle ESC in sub-screens
	    if (_input.Escape) {
	        if (show_controls || show_stats || show_pause_settings || show_missions) {
	            show_controls = false;
	            show_stats = false;
	            show_pause_settings = false;
	            show_missions = false;
	            _audio.PlayUISound(snd_menu_select);
	            return;
	        } else {
	            ResumeGame(_audio, obj_game_manager.pause_manager);
	            return;
	        }
		
			// if (menu_system.state == MENU_STATE.PAUSE_MENU) {
		    //    menu_system.ResumeGame(_audio_system, obj_game_manager.pause_manager);
		    //} else {
		    //    menu_system.PauseGame(_audio_system, obj_game_manager.pause_manager);
		    //}
	    }
    
		if (show_stats) {
		    HandleStatsInput(_input, _audio, _mx, _my);
		    return;
		}
	
	    // Handle input within sub-screens
	    if (show_pause_settings) {
	        HandlePauseSettings(_input, _audio, _mx, _my); // CALL THE HANDLER
	        return;
	    }
    
	    if (show_controls || show_stats || show_missions) {
	        return; // No interaction for these screens yet
	    }
    
	    // Main pause menu navigation
	    if (_input.UpPress) {
	        pause_selected = (pause_selected - 1 + array_length(pause_options)) mod array_length(pause_options);
	        _audio.PlayUISound(snd_menu_hover);
	    }
	    if (_input.DownPress) {
	        pause_selected = (pause_selected + 1) mod array_length(pause_options);
	        _audio.PlayUISound(snd_menu_hover);
	    }
    
	    // Mouse hover on main menu
	    var start_y = cy - 100;
	    for (var i = 0; i < array_length(pause_options); i++) {
	        var yy = start_y + i * 45;
	        if (point_in_rectangle(_mx, _my, cx - 140, yy - 18, cx + 140, yy + 18)) {
	            if (pause_selected != i) {
	                pause_selected = i;
	                _audio.PlayUISound(snd_menu_hover);
	            }
            
	            if (_input.FirePress) {
	                _audio.PlayUISound(snd_menu_select);
	                SelectPauseOption(_audio);
	            }
	        }
	    }
    
	    // Confirm
	    if (_input.Action) {
	        _audio.PlayUISound(snd_menu_select);
	        SelectPauseOption(_audio);
	    }
	}
    
    /// @function SelectPauseOption(_audio)
    static SelectPauseOption = function(_audio, _pause_manager) {
         switch(pause_selected) {
	        case 0: // RESUME
	            ResumeGame(_audio);
	            break;
	        case 1: // STATS
	            show_stats = true;
	            break;
	        case 2: // MISSIONS
	            show_missions = true;
	            
	            break;
	        case 3: // SETTINGS
	            show_pause_settings = true;
	            break;
	        case 4: 
				show_controls = true;
	            break;
	        case 5: // QUIT
	            QuitToMenu(_audio);
	            break;
				// pause_options	  = ["RESUME", "STATS", "MISSIONS", "CONTROLS", "QUIT TO MENU"];
		}
    }
	
	/// @function HandleStatsInput(_input, _audio, _mx, _my)
	static HandleStatsInput = function(_input, _audio, _mx, _my) {
	    // Initialize selected mod index
	    if (!variable_struct_exists(self, "stats_selected_mod")) {
	        stats_selected_mod = 0;
	    }
    
	    // Get mod count
	    var mod_count = 0;
	    if (instance_exists(obj_game_manager) && 
	        variable_instance_exists(obj_game_manager, "playerModsArray")) {
	        mod_count = min(10, array_length(obj_game_manager.playerModsArray));
	    } else if (instance_exists(obj_player) && 
	               variable_instance_exists(obj_player, "mod_list")) {
	        mod_count = min(10, array_length(obj_player.mod_list));
	    }
    
	    // Navigate through mods with keyboard
	    if (mod_count > 0) {
	        if (_input.UpPress) {
	            stats_selected_mod = (stats_selected_mod - 1 + mod_count) mod mod_count;
	            _audio.PlayUISound(snd_menu_hover);
	        }
	        if (_input.DownPress) {
	            stats_selected_mod = (stats_selected_mod + 1) mod mod_count;
	            _audio.PlayUISound(snd_menu_hover);
	        }
	    }
	}
	
	static DrawPauseSettingsScreen = function(_w, _h, _cx, _cy) {
    var panel_w = 600;
    var panel_h = 500;
    var panel_x = _cx - panel_w / 2;
    var panel_y = _cy - panel_h / 2;
    
    draw_set_color(c_dkgray);
    draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);
    draw_set_color(c_white);
    draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, true);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_font(fnt_large);
    draw_set_color(c_yellow);
    draw_text(_cx, panel_y + 20, "SETTINGS");
    
    // Volume controls (reuse from main settings)
    draw_set_font(fnt_default);
    draw_set_color(c_white);
    
    var start_y = panel_y + 80;
    var line_h = 50;
    
    draw_set_halign(fa_right);
    draw_text(_cx - 24, start_y, "Master Volume:");
    DrawVolumeBar(_cx + 100, start_y, audio_sys.settings.master_volume);
    draw_set_halign(fa_right);
    draw_text(_cx - 24, start_y + line_h, "Music Volume:");
    DrawVolumeBar(_cx + 100, start_y + line_h, audio_sys.music_master_volume);
    draw_set_halign(fa_right);
    draw_text(_cx - 24, start_y + line_h * 2, "SFX Volume:");
    DrawVolumeBar(_cx + 100, start_y + line_h * 2, audio_sys.sfx_master_volume);
    
    // Screen shake toggle
    draw_set_halign(fa_center);
    draw_text(_cx - 100, start_y + line_h * 3.5, "Screen Shake:");
    
    var shake_toggle_x = _cx + 80;
    var shake_toggle_y = start_y + line_h * 3.5;
    var toggle_col = global.screen_shake ? c_lime : c_red;
    var toggle_text = global.screen_shake ? "ON" : "OFF";
    
    draw_set_color(toggle_col);
    draw_rectangle(shake_toggle_x - 40, shake_toggle_y - 15, 
                   shake_toggle_x + 40, shake_toggle_y + 15, false);
    draw_set_color(c_white);
    draw_text(shake_toggle_x, shake_toggle_y, toggle_text);
    
    // Instructions
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_ltgray);
    draw_text(_cx, panel_y + panel_h - 30, "ESC to return");
}

	static DrawMissionsScreen = function(_w, _h, _cx, _cy) {
	    var panel_w = 700;
	    var panel_h = 500;
	    var panel_x = _cx - panel_w / 2;
	    var panel_y = _cy - panel_h / 2;
    
	    draw_set_color(c_dkgray);
	    draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);
	    draw_set_color(c_white);
	    draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, true);
    
	    draw_set_halign(fa_center);
	    draw_set_valign(fa_top);
	    draw_set_font(fnt_large);
	    draw_set_color(c_yellow);
	    draw_text(_cx, panel_y + 20, "MISSIONS");
    
	    // Placeholder missions
	    draw_set_font(fnt_default);
	    draw_set_color(c_white);
	    draw_set_halign(fa_left);
    
	    var mission_x = panel_x + 40;
	    var mission_y = panel_y + 80;
	    var line_h = 40;
    
	    // Example missions (you'll replace with real data)
	    draw_text(mission_x, mission_y, "[ ] Defeat 100 enemies");
	    draw_text(mission_x, mission_y + line_h, "[ ] Unlock Holy Mage");
	    draw_text(mission_x, mission_y + line_h * 2, "[X] Reach Level 5");
	    draw_text(mission_x, mission_y + line_h * 3, "[ ] Score 10,000 points");
    
	    draw_set_halign(fa_center);
	    draw_set_valign(fa_bottom);
	    draw_set_color(c_ltgray);
	    draw_text(_cx, panel_y + panel_h - 30, "ESC to return");
	}

	/// @function HandleUnlocks(_input, _audio)
	static HandleUnlocks = function(_input, _audio) {
	    // Initialize skill tree if not exists
	    if (!variable_struct_exists(self, "skill_tree")) {
	        skill_tree = new SkillTreeSystem();
	    }
    
	    var mx = device_mouse_x_to_gui(0);
	    var my = device_mouse_y_to_gui(0);
    
	    var player_souls = GetSouls();
    
	    // Update skill tree
	    skill_tree.Update(_input, mx, my, player_souls);
    
	    // Back to menu
	    if (_input.Back || _input.Escape) {
	        _audio.PlayUISound(snd_menu_select);
	        state = MENU_STATE.MAIN;
	        selected_option = 1;
	    }
	}
	
}