/// @description
/// obj_menu_controller - Create Event
// Menu state
enum MENU_STATE {
    MAIN,
    SETTINGS,
    CHARACTER_SELECT
}

menu_state = MENU_STATE.MAIN;
selected_option = 0;
menu_options = ["START", "SETTINGS", "EXIT"];
settings_options = ["SFX Volume", "Music Volume", "Screen Shake", "Back"];

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

// Settings
global.sfx_volume = 0.8;
global.music_volume = 0.5;
global.screen_shake = true;

// Visual
logo_scale = 0;
logo_bounce = 0;
menu_alpha = 0;