/// @desc Main Controller - Create Event
// This is PERSISTENT across all rooms

// Make this object persistent
persistent = true  ;

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
menu_options = ["START", "SETTINGS", "EXIT"];
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
    {
        type: CharacterClass.WARRIOR,
        name: "WARRIOR",
        desc: "High damage\nRage builds",
        color: c_red
    },
    {
        type: CharacterClass.HOLY_MAGE, 
        name: "HOLY MAGE",
        desc: "Projectiles\nArea control",
        color: c_aqua
    },
    {
        type: CharacterClass.VAMPIRE,
        name: "VAMPIRE",
        desc: "Lifesteal\nHigh mobility",
        color: c_purple
    }
];

// ==========================================
// SETTINGS
// ==========================================
global.sfx_volume = 0.8;
global.music_volume = 0.5;
global.screen_shake = true;

// ==========================================
// VISUAL
// ==========================================
logo_scale = 0;
logo_bounce = 0;
menu_alpha = 0;

// ==========================================
// AUDIO SYSTEM
// ==========================================
current_music = noone;
music_volume = 0.5;
target_music_volume = 0.5;
is_fading_music = false;
fade_callback = noone;

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
final_time = "";

// ==========================================
// HIGHSCORES (for future)
// ==========================================
highscore_table = [];

// ==========================================
// START MENU MUSIC
// ==========================================
PlayMusic(Sound1, true);

/// @function AddHighscore(_score, _name)
function AddHighscore(_score, _name) {
    // Create new score entry
    var new_entry = {score: _score, name: _name};
    
    // Add to table
    array_push(highscore_table, new_entry);
    
    // Sort by score (highest first)
    array_sort(highscore_table, function(a, b) {
        return b.score - a.score;
    });
    
    // Keep only top 10
    if (array_length(highscore_table) > 10) {
        array_resize(highscore_table, 10);
    }
    
    // Find the index of the score we just added
    global.last_highscore_index = -1;
    for (var i = 0; i < array_length(highscore_table); i++) {
        if (highscore_table[i].score == _score && highscore_table[i].name == _name) {
            global.last_highscore_index = i;
            break;
        }
    }
}

/// @function DrawHighscores(_w, _h)
function DrawHighscores(_w, _h) {
    // Position on the right side of the screen
    var table_x = _w - 250;
    var table_y = 100;
    var row_height = 32;
    
    // Draw background panel
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(table_x - 20, table_y - 40, table_x + 220, table_y + (row_height * 10) + 20, false);
    
    // Draw title
    draw_set_alpha(1);
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(table_x + 100, table_y - 30, "HIGH SCORES");
    
    // Draw column headers
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_text(table_x, table_y - 10, "RANK");
    draw_text(table_x + 60, table_y - 10, "SCORE");
    draw_text(table_x + 140, table_y - 10, "NAME");
    
    // Get highscores (top 10)
    var num_scores = min(10, array_length(highscore_table));
    
    for (var i = 0; i < num_scores; i++) {
        var yy = table_y + 10 + (i * row_height);
        
        // Check if this is the last score added
        var is_latest = (i == global.last_highscore_index);
        
        // Draw arrow for latest score
        if (is_latest) {
            draw_set_color(c_lime);
            draw_text(table_x - 15, yy, ">");
        }
        
        // Set color based on rank
        if (i == 0) draw_set_color(c_yellow);      // 1st place
        else if (i == 1) draw_set_color(c_silver); // 2nd place
        else if (i == 2) draw_set_color(c_orange); // 3rd place
        else if (is_latest) draw_set_color(c_lime); // Latest score
        else draw_set_color(c_white);
        
        // Draw rank, score, and name
        draw_text(table_x + 10, yy, string(i + 1));
        draw_text(table_x + 60, yy, string(highscore_table[i].score));
        draw_text(table_x + 140, yy, highscore_table[i].name);
    }
    
    // Reset drawing settings
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

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

/// @function DrawSettings(_w, _h, _cx, _cy)
function DrawSettings(_w, _h, _cx, _cy) {
    draw_set_color(c_black);
    draw_set_alpha(0.8);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(fnt_large);
    draw_text(_cx, _cy - 100, "SETTINGS");
    
    draw_set_font(fnt_default);
    draw_text(_cx, _cy, "Coming Soon!");
    draw_text(_cx, _cy + 100, "Press ESC to return");
}

/// @function DrawPauseMenu(_w, _h, _cx, _cy)
function DrawPauseMenu(_w, _h, _cx, _cy) {
    // Dark overlay
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);
    
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
        draw_set_alpha(death_fade_alpha);
        draw_set_color(c_black);
        draw_rectangle(0, 0, _w, _h, false);
        draw_set_alpha(1);
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
// AUDIO FUNCTIONS
// ==========================================

/// @function PlayMusic(_sound, _loop)
function PlayMusic(_sound, _loop = true) {
    // Stop current music
    if (audio_is_playing(current_music)) {
        audio_stop_sound(current_music);
    }
    
    // Play new music
    current_music = audio_play_sound(_sound, 1, _loop, music_volume);
    target_music_volume = global.music_volume;
}

/// @function FadeOutMusic(_callback)
function FadeOutMusic(_callback = noone) {
    is_fading_music = true;
    target_music_volume = 0;
    fade_callback = _callback;
}

/// @function FadeInMusic(_sound, _loop)
function FadeInMusic(_sound, _loop = true) {
    // Start at 0 volume
    music_volume = 0;
    current_music = audio_play_sound(_sound, 1, _loop, 0);
    target_music_volume = global.music_volume;
}

/// @function UpdateMusic()
function UpdateMusic() {
    if (!audio_is_playing(current_music)) return;
    
    // Lerp volume
    if (music_volume != target_music_volume) {
        music_volume = lerp(music_volume, target_music_volume, 0.05);
        audio_sound_gain(current_music, music_volume, 0);
        
        // Check if fade complete
        if (abs(music_volume - target_music_volume) < 0.01) {
            music_volume = target_music_volume;
            
            // If faded to 0, stop and call callback
            if (music_volume == 0) {
                audio_stop_sound(current_music);
                if (is_callable(fade_callback)) {
                    fade_callback();
                }
                is_fading_music = false;
                fade_callback = noone;
            }
        }
    }
}

// ==========================================
// MENU HANDLERS
// ==========================================

/// @function HandleMainMenu(_mx, _my)
function HandleMainMenu(_mx, _my) {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var cx = gui_w / 2;
    var cy = gui_h / 2;
    
    // Keyboard
    if (keyboard_check_pressed(vk_up)) {
        selected_option = (selected_option - 1 + array_length(menu_options)) mod array_length(menu_options);
    }
    if (keyboard_check_pressed(vk_down)) {
        selected_option = (selected_option + 1) mod array_length(menu_options);
    }
    
    // Mouse hover
    for (var i = 0; i < array_length(menu_options); i++) {
        var yy = cy + i * 60;
        if (point_in_rectangle(_mx, _my, cx - 100, yy - 25, cx + 100, yy + 25)) {
            selected_option = i;
            
            // Mouse click
            if (mouse_check_button_pressed(mb_left)) {
                SelectMainMenuOption();
            }
        }
    }
    
    // Keyboard select
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
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
    if (keyboard_check_pressed(vk_left)) {
        selected_class = (selected_class - 1 + array_length(class_options)) mod array_length(class_options);
    }
    if (keyboard_check_pressed(vk_right)) {
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
    
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
        StartGame();
    }
    
    if (keyboard_check_pressed(vk_escape)) {
        menu_state = MENU_STATE.MAIN;
        selected_option = 0;
    }
}

/// @function StartGame()
function StartGame() {
    global.selected_class = class_options[selected_class].type;
    
    // Fade out menu music, then switch to gameplay
    FadeOutMusic(function() {
        room_goto(rm_demo_room);
    });
}

/// @function HandleSettings(_mx, _my)
function HandleSettings(_mx, _my) {
    if (keyboard_check_pressed(vk_escape)) {
        menu_state = MENU_STATE.MAIN;
        selected_option = 0;
    }
    // TODO: Implement settings controls
}

/// @function HandlePauseMenu(_mx, _my)
function HandlePauseMenu(_mx, _my) {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var cx = gui_w / 2;
    var cy = gui_h / 2;
    
    // Return from sub-screens
    if (show_controls || show_stats) {
        if (keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right)) {
            show_controls = false;
            show_stats = false;
        }
        return;
    }
    
    // Keyboard
    if (keyboard_check_pressed(vk_up)) {
        pause_selected = (pause_selected - 1 + array_length(pause_options)) mod array_length(pause_options);
    }
    if (keyboard_check_pressed(vk_down)) {
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

/// @function PauseGame()
function PauseGame() {

 	obj_game_manager.pause_manager.Pause(PAUSE_REASON.PAUSE_MENU);
    
    menu_state = MENU_STATE.PAUSE_MENU;
    pause_selected = 0;
    show_controls = false;
    show_stats = false;
}

function ResumeGame() {
    // ONLY resume if we're actually in the pause menu state
    if (menu_state == MENU_STATE.PAUSE_MENU && instance_exists(obj_game_manager)) {
        obj_game_manager.pause_manager.Resume(PAUSE_REASON.PAUSE_MENU);
        menu_state = MENU_STATE.MAIN;
    }
}

/// @function QuitToMenu()
function QuitToMenu() {
    // CRITICAL: Resume ALL game systems first
    if (instance_exists(obj_game_manager)) {
        obj_game_manager.pause_manager.ResumeAll();
    }
    
    // Stop gameplay music
    if (audio_is_playing(Sound2)) {
        audio_stop_sound(Sound2);
    }
    
    // Reset states
    death_sequence_active = false;
    menu_state = MENU_STATE.MAIN;
    selected_option = 0;
    show_controls = false;
    show_stats = false;
    
    // Play menu music
    PlayMusic(Sound1, true);
    
    // Go to menu
    room_goto(rm_main_menu);
}

// ==========================================
// DEATH SEQUENCE
// ==========================================

/// @function TriggerDeathSequence()
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
    
    // Fade out gameplay music
    if (audio_is_playing(Sound2)) {
        var fade_speed = 0.02;
        audio_sound_gain(Sound2, 0, 1000); // Fade over 1 second
    }
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
                FadeInMusic(Sound1, true);
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
					AddHighscore(final_score, string(final_time));
                QuitToMenu();
            }
            break;
    }
}