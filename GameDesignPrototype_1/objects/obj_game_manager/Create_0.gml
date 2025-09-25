/// @description Insert description here
// You can write your code in this editor

global.gameSpeed = 1;


playerLevel = 1;
playerExperience = 0;

playerModsArray = [];
allMods = [];           // array for all mods loaded from JSON

depth = -999;



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
