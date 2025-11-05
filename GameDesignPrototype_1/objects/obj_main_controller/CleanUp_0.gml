// Clean up the audio system
if (_audio_system != undefined) {
    _audio_system.Cleanup();
    delete _audio_system;
    _audio_system = undefined;
}