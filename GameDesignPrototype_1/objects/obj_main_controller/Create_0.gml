/// @desc Main Controller - Should be created in the first room
persistent = true;

player_input = new Input();
controller_type = INPUT.KEYBOARD;

// ==========================================
// MENU STATES
// ==========================================
enum MENU_STATE {
    MAIN,
    SETTINGS,
    CHARACTER_SELECT,
    PAUSE_MENU,
    GAME_OVER
}


menu_state = MENU_STATE.MAIN;
selected_option = 0;

menu_options	 = ["START", "SETTINGS", "EXIT"];
settings_options = ["SFX Volume", "Music Volume", "Screen Shake", "Back"];




// Pause menu options
pause_options = ["RESUME", "CONTROLS", "STATS", "QUIT TO MENU"];
pause_selected = 0;
show_controls = false;
show_stats = false;
show_pause_menu = false;

// Character selection
selected_class = 0;

class_options = [
    global.Player_Class.Warrior,
	global.Player_Class.Holy_Mage,
	global.Player_Class.Vampire
];

// ==========================================
// SETTINGS
// ==========================================
global.screen_shake = true;


// Weapon synergy
global.WeaponSynergies = {};
InitWeaponSynergySystem();

// Popup references
global.selection_popup	  = undefined;
global.chest_popup		  = undefined;
global.weapon_swap_prompt = undefined;

// ==========================================
// VISUAL
// ==========================================
logo_scale  = 0;
logo_bounce = 0;
menu_alpha  = 0;

// ==========================================
// AUDIO SYSTEM
// ==========================================
// Create the audio system
_audio_system = new AudioSystem();

// Configure audio settings
_audio_system.SetMasterVolume(1.0);
_audio_system.SetMusicVolume(0.8);
_audio_system.SetSFXVolume(1.0);
_audio_system.SetVoiceVolume(1.0);
_audio_system.SetUIVolume(0.9);

// ==========================================
// GAME OVER SEQUENCE
// ==========================================
death_sequence_active = false;
death_phase = 0;
death_timer = 0;
death_fade_alpha = 0;
death_stats_alpha = 0;
death_player_fade = 0;
final_score = 0;
final_time  = "";

// ==========================================
// HIGHSCORES (for future)
// ==========================================
highscore_table = [];

sequence = layer_sequence_create("Instances", room_width * 0.5, room_height * 0.6, Sequence1);
layer_sequence_play(sequence);




/// @desc Main Controller - ALL Draw Functions
// Add ALL of these to the END of your Create event

/// @function DrawMainMenu(_w, _h, _cx, _cy)
function DrawMainMenu(_w, _h, _cx, _cy) {
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
    for (var i = 0; i < array_length(menu_options); i++) {
        var yy = _cy + i * 60;
        var selected = (i == selected_option);
        
        if (selected) {
            draw_set_alpha(menu_alpha * 0.3);
            draw_rectangle_color(_cx - 100, yy - 25, _cx + 100, yy + 25,
                c_yellow, c_orange, c_orange, c_yellow, false);
            draw_set_alpha(menu_alpha);
        }
        
        draw_set_font(selected ? fnt_large : fnt_default);
        var col = selected ? c_yellow : c_white;
        draw_text_color(_cx, yy, menu_options[i], col, col, col, col, menu_alpha);
    }
    
    draw_set_alpha(1);
}





/// @function DrawCharacterSelect(_w, _h, _cx, _cy)
function DrawCharacterSelect(_w, _h, _cx, _cy) {
    // Background
    draw_set_color(c_black);
    draw_set_alpha(0.8);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(menu_alpha);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Title
    draw_set_font(fnt_large);
    draw_text(_cx, _cy - 100, "SELECT CHARACTER");
    
    // Character boxes
    for (var i = 0; i < array_length(class_options); i++) {
        var xx = _cx + (i - 1) * 250;
        var yy = _cy + 50;
        var selected = (i == selected_class);
        var scale = selected ? 1.2 : 1;
        
        draw_set_alpha(menu_alpha * (selected ? 0.8 : 0.4));
        draw_rectangle_color(xx - 100*scale, yy - 80*scale, 
            xx + 100*scale, yy + 80*scale,
            class_options[i].color, class_options[i].color,
            c_black, c_black, false);
        
        draw_set_alpha(menu_alpha);
        draw_set_font(fnt_large);
        draw_text(xx, yy - 20, class_options[i].name);
        
        draw_set_font(fnt_default);
        draw_text(xx, yy + 20, class_options[i].desc);
    }
    
    draw_set_font(fnt_default);
    draw_text(_cx, _cy + 200, "Click or Press SPACE to Start - ESC to Back");
    
    draw_set_alpha(1);
}

draw_set_font(fnt_default);

function DrawSettings(_w, _h, _cx, _cy) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(fnt_large);
    draw_text(_cx, _cy - 150, "SETTINGS");
    // Master Volume
    var master_y = _cy - 60;
    draw_text(_cx - 200, master_y, "Master Volume:");
    DrawVolumeBar(_cx, master_y, _audio_system.settings.master_volume);
    
    // Music Volume
    var music_y = _cy - 20;
    draw_text(_cx - 200, music_y, "Music Volume:");
    DrawVolumeBar(_cx, music_y, _audio_system.music_master_volume);
    
    // SFX Volume
    var sfx_y = _cy + 20;
    draw_text(_cx - 200, sfx_y, "SFX Volume:");
    DrawVolumeBar(_cx, sfx_y, _audio_system.sfx_master_volume);
    
    // Voice Volume
    var voice_y = _cy + 60;
    draw_text(_cx - 200, voice_y, "Voice Volume:");
    DrawVolumeBar(_cx, voice_y, _audio_system.voice_volume);
    
    // Back button
    var selected = (selected_option == 4);
    draw_set_font(selected ? fnt_large : fnt_default);
    var col = selected ? c_yellow : c_white;
    draw_text_color(_cx, _cy + 120, "BACK", col, col, col, col, 1);
}

/// @function DrawPauseMenu(_w, _h, _cx, _cy)
function DrawPauseMenu(_w, _h, _cx, _cy) {
    // Dark overlay
    drawAlphaRectangle(0, 0, _w, _h, 0.8);
    
    // Show controls screen
    if (show_controls) {
        DrawControlsScreen(_w, _h, _cx, _cy);
        return;
    }
    
    // Show stats screen
    if (show_stats) {
        DrawStatsScreen(_w, _h, _cx, _cy);
        return;
    }
    
    // Menu panel
    var panel_w = 400;
    var panel_h = 350;
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
    for (var i = 0; i < array_length(pause_options); i++) {
        var yy = _cy - 60 + i * 50;
        var selected = (i == pause_selected);
        
        if (selected) {
            draw_set_alpha(0.3);
            draw_set_color(c_yellow);
            draw_rectangle(_cx - 120, yy - 20, _cx + 120, yy + 20, false);
            draw_set_alpha(1);
        }
        
        var col = selected ? c_yellow : c_white;
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
function DrawControlsScreen(_w, _h, _cx, _cy) {
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
    draw_set_valign(fa_top);
    
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
        "ESC - Pause Menu",
        "",
        "F1-F10 - Debug Camera Controls"
    ];
    
    for (var i = 0; i < array_length(controls); i++) {
        draw_text(left_x, start_y + i * line_h, controls[i]);
    }
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_ltgray);
    draw_text(_cx, panel_y + panel_h - 30, "ESC or Right Click to return");
}

/// @function DrawStatsScreen(_w, _h, _cx, _cy)
function DrawStatsScreen(_w, _h, _cx, _cy) {
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
    draw_text(_cx, panel_y + 20, "PLAYER STATS");
    
    draw_set_font(fnt_default);
    draw_set_color(c_white);
    draw_set_valign(fa_middle);
    
    // Get player stats if available
    if (instance_exists(obj_player)) {
        var start_y = panel_y + 80;
        var line_h = 30;
        
        draw_text(_cx, start_y, "Level: " + string(obj_player.player_level));
        draw_text(_cx, start_y + line_h, "HP: " + string(floor(obj_player.hp)) + "/" + string(obj_player.maxHp));
        draw_text(_cx, start_y + line_h * 2, "Attack: " + string(obj_player.attack));
        draw_text(_cx, start_y + line_h * 3, "Speed: " + string(obj_player.mySpeed));
        
        if (instance_exists(obj_game_manager)) {
            draw_text(_cx, start_y + line_h * 5, "Score: " + string(obj_game_manager.score_manager.GetScore()));
            draw_text(_cx, start_y + line_h * 6, "Time: " + obj_game_manager.time_manager.GetFormattedTime());
        }
    } else {
        draw_text(_cx, _cy, "COMING SOON");
    }
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_ltgray);
    draw_text(_cx, panel_y + panel_h - 30, "ESC or Right Click to return");
}

/// @function DrawDeathSequence(_w, _h, _cx, _cy)
function DrawDeathSequence(_w, _h, _cx, _cy) {
    // Black fade overlay
    if (death_fade_alpha > 0) {
        drawAlphaRectangle(0, 0, _w, _h, death_fade_alpha);
    }
    draw_sprite_ext(spr_vh_dead, 0, _cx, _cy, 3, 3, 0, c_white, death_fade_alpha);
    
	// Stats display
    if (death_phase >= 2 && death_stats_alpha > 0) {
        draw_set_alpha(death_stats_alpha);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        
        // Title
        draw_set_font(fnt_large);
        draw_text(_cx, _cy - 120, "GAME OVER");
        
        draw_set_font(fnt_default);
        
        // Score
        var score_text = "FINAL SCORE: " + string(final_score);
        draw_text(_cx, _cy - 40, score_text);
        
        // Time
        var time_text = "TIME SURVIVED: " + final_time;
        draw_text(_cx, _cy, time_text);
        
        // Thank you message
        draw_set_color(c_yellow);
        draw_text(_cx, _cy + 60, "Thanks for playing the");
        draw_set_font(fnt_large);
        draw_text(_cx, _cy + 90, "TARLHS GAME DEMO");
        
        draw_set_alpha(1);
    }
    
    // Return prompt
    if (death_phase >= 3 && death_timer > 60) {
        var pulse = 0.5 + sin(current_time * 0.005) * 0.5;
        draw_set_alpha(pulse);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_set_font(fnt_default);
        
        draw_text(_cx, _h - 80, "Click or Press ENTER/SPACE to return to Main Menu");
        
        draw_set_alpha(1);
    }
}
	

// ==========================================
// MENU HANDLERS
// ==========================================

/// @function HandleMainMenu(_mx, _my)
function HandleMainMenu(_mx, _my) {
    var cy = room_height / 2;
    var cx = room_width / 2;
    
    // Store previous selection
    var prev_selection = selected_option;
    
    // Keyboard navigation
    if (player_input.UpPress) {
        selected_option = (selected_option - 1 + array_length(menu_options)) mod array_length(menu_options);
    }
    if (player_input.DownPress) {
        selected_option = (selected_option + 1) mod array_length(menu_options);
    }
    
    // NEW: Play navigation sound if selection changed
    if (prev_selection != selected_option) {
        _audio_system.PlayUISound(snd_menu_hover);
    }
    
    // Mouse hover
    for (var i = 0; i < array_length(menu_options); i++) {
        var yy = cy + i * 60;
        if (point_in_rectangle(_mx, _my, cx - 100, yy - 25, cx + 100, yy + 25)) {
            if (selected_option != i) {
                selected_option = i;
                // NEW: Play hover sound
                _audio_system.PlayUISound(snd_menu_hover);
            }
            
            // Mouse click
            if (mouse_check_button_pressed(mb_left)) {
                // NEW: Play select sound
                _audio_system.PlayUISound(snd_menu_select);
                SelectMainMenuOption();
            }
        }
    }
    
    // Keyboard select
    if (player_input.Action) {
        // NEW: Play select sound
        _audio_system.PlayUISound(snd_menu_select);
        SelectMainMenuOption();
    }
}


/// @function SelectMainMenuOption()
function SelectMainMenuOption() {
    switch(selected_option) {
        case 0: // START
            menu_state = MENU_STATE.CHARACTER_SELECT;
            selected_class = 0;
            break;
        case 1: // SETTINGS
            menu_state = MENU_STATE.SETTINGS;
            selected_option = 0;
            break;
        case 2: // EXIT
            game_end();
            break;
    }
}

/// @function HandleCharacterSelect(_mx, _my)
function HandleCharacterSelect(_mx, _my) {
    var gui_w = display_get_gui_width();
    var cx = gui_w / 2;
    var cy = display_get_gui_height() / 2 + 50;
    
    // Keyboard
    if (player_input.LeftPress) {
        selected_class = (selected_class - 1 + array_length(class_options)) mod array_length(class_options);
    }
    if (player_input.RightPress) {
        selected_class = (selected_class + 1) mod array_length(class_options);
    }
    
    // Mouse hover and click
    for (var i = 0; i < array_length(class_options); i++) {
        var xx = cx + (i - 1) * 250;
        var selected = (i == selected_class);
        var scale = selected ? 1.2 : 1;
        
        if (point_in_rectangle(_mx, _my, xx - 100*scale, cy - 80*scale, xx + 100*scale, cy + 80*scale)) {
            selected_class = i;
            
            if (mouse_check_button_pressed(mb_left)) {
                StartGame();
            }
        }
    }
    
    if (player_input.Action) {
        StartGame();
    }
    
    if (player_input.Escape) {
        menu_state = MENU_STATE.MAIN;
        selected_option = 0;
    }
}

/// @function StartGame()
function StartGame() {
    global.selected_class = class_options[selected_class].type;
	room_goto(rm_demo_room); 
}

/// Handle settings input:
function HandleSettings(_mx, _my) {
    var settings_options = 5; // Master, Music, SFX, Voice, Back
    
    // Keyboard navigation
    if (player_input.UpPress) {
        selected_option = (selected_option - 1 + settings_options) mod settings_options;
        _audio_system.PlayUISound(snd_menu_hover);
    }
    if (player_input.DownPress) {
        selected_option = (selected_option + 1) mod settings_options;
        _audio_system.PlayUISound(snd_menu_hover);
    }
    
    // Adjust volumes with left/right
    var adjustment = 0;
    if (player_input.LeftPress) adjustment = -0.1;
    if (player_input.RightPress) adjustment = 0.1;
    
    if (adjustment != 0) {
        _audio_system.PlayUISound(snd_menu_select);
        
        switch(selected_option) {
            case 0: // Master
                _audio_system.SetMasterVolume(_audio_system.settings.master_volume + adjustment);
                break;
            case 1: // Music
                _audio_system.SetMusicVolume(_audio_system.music_master_volume + adjustment);
                break;
            case 2: // SFX
                _audio_system.SetSFXVolume(_audio_system.sfx_master_volume + adjustment);
                // Play test sound
                _audio_system.PlaySFX(snd_menu_select);
                break;
            case 3: // Voice
                _audio_system.SetVoiceVolume(_audio_system.voice_volume + adjustment);
                break;
        }
    }
    
    // Back button
    if (selected_option == 4 && (player_input.Action)) {
        _audio_system.PlayUISound(snd_menu_select);
        menu_state = MENU_STATE.MAIN;
        selected_option = 1; // Return to Settings option
        
        // Save audio settings
        SaveAudioSettings();
    }
    
    // ESC to go back
    if (keyboard_check_pressed(vk_escape)) {
        _audio_system.PlayUISound(snd_menu_select);
        menu_state = MENU_STATE.MAIN;
        selected_option = 1;
        SaveAudioSettings();
    }
}

/// @function HandlePauseMenu(_mx, _my)
function HandlePauseMenu(_mx, _my) {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var cx = gui_w / 2;
    var cy = gui_h / 2;
    
    // Return from sub-screens
    if (show_controls || show_stats) {
        if (player_input.Escape || mouse_check_button_pressed(mb_right)) {
            show_controls = false;
            show_stats = false;
        }
        return;
    }
    
    // Keyboard
    if (player_input.UpPress) {
        pause_selected = (pause_selected - 1 + array_length(pause_options)) mod array_length(pause_options);
    }
    if (player_input.DownPress) {
        pause_selected = (pause_selected + 1) mod array_length(pause_options);
    }
    
    // Mouse hover
    for (var i = 0; i < array_length(pause_options); i++) {
        var yy = cy - 60 + i * 50;
        if (point_in_rectangle(_mx, _my, cx - 120, yy - 20, cx + 120, yy + 20)) {
            pause_selected = i;
            
            if (mouse_check_button_pressed(mb_left)) {
                SelectPauseOption();
            }
        }
    }
    
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
        SelectPauseOption();
    }
}

/// @function SelectPauseOption()
function SelectPauseOption() {
    switch(pause_selected) {
        case 0: // RESUME
            ResumeGame();
            break;
        case 1: // CONTROLS
            show_controls = true;
            break;
        case 2: // STATS
            show_stats = true;
            break;
        case 3: // QUIT
            QuitToMenu();
            break;
    }
}

// ==========================================
// PAUSE/RESUME
// ==========================================

function PauseGame() {
    if (instance_exists(obj_game_manager)) {
        obj_game_manager.pause_manager.Pause(PAUSE_REASON.PAUSE_MENU, 0);
        menu_state = MENU_STATE.PAUSE_MENU;
        
        // NEW: Duck music volume while paused
        _audio_system.FadeMusic(_audio_system.GetMusicVolume() * 0.5, 15, FADE_TYPE.LINEAR);
        
        // Play pause sound
        //_audio_system.PlayUISound(snd_pause_menu_open);
    }
}

/// Update ResumeGame() function:

function ResumeGame() {
    if (instance_exists(obj_game_manager)) {
        obj_game_manager.pause_manager.Resume(PAUSE_REASON.PAUSE_MENU);
        menu_state = MENU_STATE.MAIN;
        
        // NEW: Restore music volume
        _audio_system.FadeMusic(_audio_system.music_master_volume, 15, FADE_TYPE.LINEAR);
        
        // Play resume sound
        //_audio_system.PlayUISound(snd_pause_menu_close);
    }
}

function QuitToMenu() {
    // Resume game systems
    if (instance_exists(obj_game_manager)) {
        obj_game_manager.pause_manager.ResumeAll();
    }
    
    // Reset states
    death_sequence_active = false;
    menu_state = MENU_STATE.MAIN;
    selected_option = 0;
    show_controls = false;
    show_stats = false;
    
    // NEW: Crossfade back to menu music
    _audio_system.CrossfadeMusic(Sound1, true, 30); // Quick 0.5 second crossfade
    
    // Go to menu
    room_goto(rm_main_menu);
}

// ==========================================
// DEATH SEQUENCE
// ==========================================

function TriggerDeathSequence() {
    death_sequence_active = true;
    death_phase = 0;
    death_timer = 0;
    death_fade_alpha = 0;
    death_stats_alpha = 0;
    death_player_fade = 0;
    menu_state = MENU_STATE.GAME_OVER;
    
    // Get final stats
    if (instance_exists(obj_game_manager)) {
        final_score = obj_game_manager.score_manager.GetScore();
        final_time = obj_game_manager.time_manager.GetFormattedTime();
        obj_game_manager.pause_manager.Pause(PAUSE_REASON.GAME_OVER);
    }
    
    // NEW: Use audio system for death music fade
    _audio_system.FadeMusic(0.2, 90, FADE_TYPE.SMOOTH); // Fade to 20% over 1.5 seconds
    
    // Optionally play death sound effect
    //_audio_system.PlaySFX(snd_player_death, 0, 1.0);
}

/// @function UpdateDeathSequence()
function UpdateDeathSequence() {
    death_timer++;
    
    switch(death_phase) {
        case 0: // ZOOM TO PLAYER (60 frames)
            if (instance_exists(obj_player) && variable_instance_exists(obj_player, "camera")) {
                obj_player.camera.lock_at(obj_player.x, obj_player.y);
                obj_player.camera.set_zoom(2.0);
            }
            
            if (death_timer >= 60) {
                death_phase = 1;
                death_timer = 0;
            }
            break;
            
        case 1: // FADE TO BLACK (60 frames)
            death_fade_alpha = min(death_fade_alpha + 0.015, 1);
            
            if (death_timer >= 60) {
                death_phase = 2;
                death_timer = 0;
            }
            break;
            
        case 2: // SHOW STATS (90 frames)
            death_stats_alpha = min(death_stats_alpha + 0.02, 1);
            
            if (death_timer > 30) {
                death_player_fade = min(death_player_fade + 0.015, 1);
            }
            
            if (death_timer >= 90) {
                death_phase = 3;
                death_timer = 0;
            }
            break;
            
        case 3: // WAIT FOR INPUT
            if (death_timer > 60 && (keyboard_check_pressed(vk_enter) || 
                keyboard_check_pressed(vk_space) || 
                mouse_check_button_pressed(mb_left))) {
					AddHighscore(highscore_table, final_score, string(final_time));
                QuitToMenu();
            }
            break;
    }
}


function LoadAudioSettings() {
    ini_open("settings.ini");
    
    var settings_string = ini_read_string("Audio", "Settings", "");
    if (settings_string != "") {
        _audio_system.LoadSettings(settings_string);
    }
    
    // Load individual volumes for backwards compatibility
    _audio_system.SetMasterVolume(ini_read_real("Audio", "Master", 1.0));
    _audio_system.SetMusicVolume(ini_read_real("Audio", "Music", 0.8));
    _audio_system.SetSFXVolume(ini_read_real("Audio", "SFX", 1.0));
    _audio_system.SetVoiceVolume(ini_read_real("Audio", "Voice", 1.0));
    
    ini_close();
}

function SaveAudioSettings() {
    ini_open("settings.ini");
    
    // Save as JSON string
    var settings_string = _audio_system.SaveSettings();
    ini_write_string("Audio", "Settings", settings_string);
    
    // Also save individually for easy editing
    ini_write_real("Audio", "Master", _audio_system.settings.master_volume);
    ini_write_real("Audio", "Music", _audio_system.music_master_volume);
    ini_write_real("Audio", "SFX", _audio_system.sfx_master_volume);
    ini_write_real("Audio", "Voice", _audio_system.voice_volume);
    
    ini_close();
}

// Call LoadAudioSettings() at the end of Create Event
LoadAudioSettings();

input_caller = self;