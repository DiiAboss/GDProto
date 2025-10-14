/// @description Insert description here
// You can write your code in this editor

global.gameSpeed = 1;


playerLevel = 1;
playerExperience = 0;

playerModsArray = [];
allMods = [];           // array for all mods loaded from JSON

depth = -999;
instance_create_depth(0, 0, -9999, obj_ui_manager);


var file = "modifiers.json";
if (file_exists(file)) {
    var f = file_text_open_read(file);
    var json_str = "";

    // read the file line by line
    while (!file_text_eof(f)) {
        json_str += file_text_readln(f); // read full line including whitespace
    }
    file_text_close(f);

    // parse JSON
    var mods_data = json_parse(json_str);

    // store in allMods array
    for (var i = 0; i < array_length(mods_data); i++) {
        array_push(allMods, mods_data[i]);
    }

    // test
    show_debug_message("First mod ID: " + string(allMods[0].id));

} else {
    show_error("Could not find JSON file...", true);
}



var _mod = get_mod_by_id("attack_up");
if (_mod != undefined) {
    array_push(obj_game_manager.playerModsArray, _mod);
}



var options = [
    { name: "Fireball", desc: "Shoots a blazing orb at enemies.", sprite: modifier_bg },
    { name: "Lightning", desc: "Strikes nearby foes.", sprite: modifier_bg },
    { name: "Healing", desc: "Regain health over time.", sprite: modifier_bg }
];

// When player selects, we’ll print the choice for now
function onSelection(index, option) {
    show_debug_message("Player selected: " + option.name);
}

function open_test_popup() {
    var options = [
        { name: "Fireball", desc: "Shoots a blazing orb at enemies.", sprite: modifier_bg },
        { name: "Lightning", desc: "Strikes nearby foes with shocking power.", sprite: modifier_bg },
        { name: "Healing", desc: "Regains health over time.", sprite: modifier_bg }
    ];

    function onSelect(index, option) {
        show_debug_message("Player selected: " + option.name);
    }

    global.selection_popup = new SelectionPopup(
        display_get_gui_width()/2,
        display_get_gui_height()/2,
        options,
        onSelect
    );
}

global.selection_popup = new SelectionPopup(
    display_get_gui_width() / 2,
    display_get_gui_height() / 2,
    options,
    onSelection
);