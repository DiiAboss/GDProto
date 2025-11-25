/// @description Insert description here
// You can write your code in this editor

InitializeSaveSystem();


// Try to load existing save
    var loaded = LoadGame();
    
    if (!loaded) {
        show_debug_message("Using default save data");
        // Save default data to create initial save file
        SaveGame();
    }