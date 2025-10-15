/// @function ShowLevelUpPopup()
function ShowLevelUpPopup() {
    // Generate 3 random modifier options
    var options = [];
    
    for (var i = 0; i < 3; i++) {
        var random_mod = allMods[irandom(array_length(allMods) - 1)];
        array_push(options, {
            name: random_mod.name ?? random_mod.id,
            desc: random_mod.description ?? "A powerful modifier",
            sprite: modifier_bg,
            mod_id: random_mod.id
        });
    }
    
    // Callback when player selects
    function on_level_up_select(index, option) {
        show_debug_message("Selected: " + option.name);
        
        // Add the modifier to the player
        if (instance_exists(obj_player)) {
            AddModifier(obj_player, option.mod_id);
        }
        
        // Resume game
        global.gameSpeed = 1;
    }
    
    // Pause game
    global.gameSpeed = 0;
    
    // Create popup
    global.selection_popup = new SelectionPopup(
        display_get_gui_width() / 2,
        display_get_gui_height() / 2,
        options,
        on_level_up_select
    );
}