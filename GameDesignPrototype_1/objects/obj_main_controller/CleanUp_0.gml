/// @description
/// @desc Main Controller - Clean Up Event

// Stop all music
if (audio_is_playing(current_music)) {
    audio_stop_sound(current_music);
}

if (audio_is_playing(Sound1)) {
    audio_stop_sound(Sound1);
}

if (audio_is_playing(Sound2)) {
    audio_stop_sound(Sound2);
}