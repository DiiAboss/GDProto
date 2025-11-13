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