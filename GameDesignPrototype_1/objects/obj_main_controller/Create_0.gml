/// @desc Main Controller - Create Event
persistent = true;

// Initialize save system first
InitializeSaveSystem();
InitializeMissions();
// Input system
player_input = new Input();
input_caller = self;

// Audio system
_audio_system = new AudioSystem();
//LoadAudioSettings();


// Sub-room return system
sub_room_return_data = noone;
current_zone = MAP_ZONE.FOREST;
current_room_type = ROOM_TYPE.OVERWORLD;

// Apply saved audio settings
var settings = GetSettings();
_audio_system.SetMasterVolume(settings.master_volume);
_audio_system.SetMusicVolume(settings.music_volume);
_audio_system.SetSFXVolume(settings.sfx_volume);
_audio_system.SetVoiceVolume(settings.voice_volume);

// Menu system
menu_system = new MenuSystem();

menu_system.audio_sys = _audio_system;

// Death sequence
death_sequence = new DeathSequence(self);

// Highscore system
highscore_system = new HighscoreSystem();
highscore_system.LoadHighscores();

// Global references (legacy - remove eventually)
global.screen_shake = true;
global.WeaponSynergies = {};
InitWeaponSynergySystem();
global.selection_popup = noone;
global.chest_popup = noone;
global.weapon_swap_prompt = noone;
global.SaveData.career.currency.souls = 5000;

/// @function ReturnToOverworld()
function ReturnToOverworld() {
    if (sub_room_return_data == noone) {
        show_debug_message("ERROR: No return data!");
        room_goto(rm_demo_room);
        return;
    }
    
    // Return to saved location
    room_goto(sub_room_return_data.room);
    
    // Position player at door location (in Room Start)
    with (obj_player) {
        x = other.sub_room_return_data.x;
        y = other.sub_room_return_data.y;
    }
    
    // Clear return data
    sub_room_return_data = noone;
}

/// @function UnlockDoor(_zone, _door_type)
function UnlockDoor(_zone, _door_type) {
    var zone_key = "";
    switch(_zone) {
        case MAP_ZONE.FOREST: zone_key = "forest"; break;
        case MAP_ZONE.DESERT: zone_key = "desert"; break;
        case MAP_ZONE.HELL: zone_key = "hell"; break;
        default: zone_key = "tutorial"; break;
    }
    
    var door_key = "";
    switch(_door_type) {
        case ROOM_TYPE.ARENA: door_key = "arena"; break;
        case ROOM_TYPE.CHALLENGE: door_key = "challenge"; break;
        case ROOM_TYPE.BOSS: door_key = "boss"; break;
        case ROOM_TYPE.SECRET: door_key = "secret"; break;
    }
    
    // Save to persistent data
    global.SaveData.discovered_doors[$ zone_key][$ door_key] = true;
    SaveGame();
    
    show_debug_message("UNLOCKED: " + zone_key + " " + door_key);
}