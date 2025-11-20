// Clean up the audio system
if (_audio_system != noone) {
    _audio_system.Cleanup();
    delete _audio_system;
    _audio_system = noone;
}

menu_system.Cleanup();