/// @description AudioSystem Constructor


// AUDIO ENUMS


enum AUDIO_CHANNEL {
    MUSIC,
    SFX,
    VOICE,
    AMBIENT,
    UI
}

enum FADE_TYPE {
    NONE,
    LINEAR,
    SMOOTH,
    EXPONENTIAL
}


// AUDIO SYSTEM CONSTRUCTOR


/// @function AudioSystem()
/// @description Complete audio management system
function AudioSystem() constructor {
    
    
    // PROPERTIES
    
    
    // Music properties
    current_music = noone;
    queued_music = noone;
    music_volume = 1.0;
    music_master_volume = 1.0;
    
    // Sound effect management
    sfx_volume = 1.0;
    sfx_master_volume = 1.0;
    active_sounds = [];
    
    // Voice/dialogue
    voice_volume = 1.0;
    current_voice = noone;
    
    // Ambient sounds
    ambient_sounds = [];
    ambient_volume = 1.0;
    
    // UI sounds
    ui_volume = 1.0;
    
    // Fade properties
    fade_data = {
        active: false,
        type: FADE_TYPE.SMOOTH,
        current_volume: 1.0,
        target_volume: 1.0,
        duration: 0,
        timer: 0,
        callback: noone,
        callback_args: noone
    };
    
    // Crossfade properties
    crossfade_data = {
        active: false,
        old_sound: noone,
        new_sound: noone,
        old_volume: 1.0,
        new_volume: 0.0,
        duration: 60,
        timer: 0
    };
    
    // Audio pools for performance
    sfx_pool = ds_map_create();
    max_concurrent_sfx = 10;
    
    // Settings (saved/loaded)
    settings = {
        master_volume: 1.0,
        music_enabled: true,
        sfx_enabled: true,
        voice_enabled: true,
        ambient_enabled: true
    };
    
    
    // MUSIC FUNCTIONS
    
    
    /// @function PlayMusic(_sound, _loop, _fade_in_duration)
    /// @param {Asset.GMSound} _sound Sound to play
    /// @param {Bool} _loop Should loop
    /// @param {Real} _fade_in_duration Frames to fade in (0 = instant)
    static PlayMusic = function(_sound, _loop = true, _fade_in_duration = 0) {
        if (!settings.music_enabled) return noone;
        
        // If same music is already playing, ignore
        if (audio_is_playing(current_music)) {
            var current_sound_id = audio_get_name(current_music);
            var new_sound_id = audio_get_name(_sound);
            if (current_sound_id == new_sound_id) {
                return current_music;
            }
        }
        
        // Stop any existing music
        if (current_music != noone && audio_is_playing(current_music)) {
            audio_stop_sound(current_music);
        }
        
        // Cancel any active fades
        fade_data.active = false;
        crossfade_data.active = false;
        
        // Calculate initial volume
        var start_volume = (_fade_in_duration > 0) ? 0 : GetMusicVolume();
        
        // Play the new music
        current_music = audio_play_sound(_sound, 10, _loop);
        audio_sound_gain(current_music, start_volume, 0);
        
        // Setup fade in if requested
        if (_fade_in_duration > 0) {
            FadeMusic(GetMusicVolume(), _fade_in_duration, FADE_TYPE.SMOOTH);
        }
        
        return current_music;
    };
    
    /// @function StopMusic(_fade_out_duration)
    /// @param {Real} _fade_out_duration Frames to fade out (0 = instant)
    static StopMusic = function(_fade_out_duration = 0) {
        if (current_music == noone) return;
        
        if (_fade_out_duration > 0) {
            FadeMusic(0, _fade_out_duration, FADE_TYPE.SMOOTH, function() {
                if (audio_is_playing(current_music)) {
                    audio_stop_sound(current_music);
                }
                current_music = noone;
            });
        } else {
            audio_stop_sound(current_music);
            current_music = noone;
        }
    };
    
    /// @function CrossfadeMusic(_new_sound, _loop, _duration)
    /// @param {Asset.GMSound} _new_sound New music to play
    /// @param {Bool} _loop Should loop
    /// @param {Real} _duration Crossfade duration in frames
    static CrossfadeMusic = function(_new_sound, _loop = true, _duration = 60) {
        if (!settings.music_enabled) return;
        
        // Setup crossfade
        crossfade_data.active = true;
        crossfade_data.old_sound = current_music;
        crossfade_data.new_sound = audio_play_sound(_new_sound, 10, _loop);
        crossfade_data.old_volume = GetMusicVolume();
        crossfade_data.new_volume = 0;
        crossfade_data.duration = _duration;
        crossfade_data.timer = 0;
        
        // Start new sound at 0 volume
        audio_sound_gain(crossfade_data.new_sound, 0, 0);
        
        // Update current music reference
        current_music = crossfade_data.new_sound;
    };
    
    /// @function FadeMusic(_target_volume, _duration, _type, _callback, _callback_args)
    static FadeMusic = function(_target_volume, _duration, _type = FADE_TYPE.SMOOTH, _callback = noone, _callback_args = noone) {
        if (current_music == noone) return;
        
        fade_data.active = true;
        fade_data.type = _type;
        fade_data.current_volume = audio_sound_get_gain(current_music);
        fade_data.target_volume = _target_volume;
        fade_data.duration = max(1, _duration);
        fade_data.timer = 0;
        fade_data.callback = _callback;
        fade_data.callback_args = _callback_args;
    };
    
    /// @function PauseMusic()
    static PauseMusic = function() {
        if (current_music != noone && audio_is_playing(current_music)) {
            audio_pause_sound(current_music);
        }
    };
    
    /// @function ResumeMusic()
    static ResumeMusic = function() {
        if (current_music != noone && audio_is_paused(current_music)) {
            audio_resume_sound(current_music);
        }
    };
    
    
    // SOUND EFFECT FUNCTIONS
    
    
    /// @function PlaySFX(_sound, _pitch_variance, _volume_scale)
    /// @param {Asset.GMSound} _sound Sound to play
    /// @param {Real} _pitch_variance Random pitch variation (0.1 = ±10%)
    /// @param {Real} _volume_scale Volume multiplier (0-1)
    static PlaySFX = function(_sound, _pitch_variance = 0, _volume_scale = 1.0) {
        if (!settings.sfx_enabled) return noone;
        
        // Clean up finished sounds
        CleanupFinishedSounds();
        
        // Check if too many sounds are playing
        if (array_length(active_sounds) >= max_concurrent_sfx) {
            // Remove oldest sound
            var oldest = array_shift(active_sounds);
            if (audio_is_playing(oldest)) {
                audio_stop_sound(oldest);
            }
        }
        
        // Calculate volume
        var volume = GetSFXVolume() * _volume_scale;
        
        // Play sound
        var sound_id = audio_play_sound(_sound, 5, false);
        audio_sound_gain(sound_id, volume, 0);
        
        // Apply pitch variance if specified
        if (_pitch_variance > 0) {
            var pitch = 1.0 + random_range(-_pitch_variance, _pitch_variance);
            audio_sound_pitch(sound_id, pitch);
        }
        
        // Track active sound
        array_push(active_sounds, sound_id);
        
        return sound_id;
    };
    
    /// @function PlaySFXAt(_sound, _x, _y, _falloff_ref, _falloff_max, _falloff_factor)
    static PlaySFXAt = function(_sound, _x, _y, _falloff_ref = 100, _falloff_max = 500, _falloff_factor = 1) {
        if (!settings.sfx_enabled) return noone;
        
        var sound_id = audio_play_sound_at(
            _sound, _x, _y, 0,
            _falloff_ref, _falloff_max, _falloff_factor,
            false, 5
        );
        
        audio_sound_gain(sound_id, GetSFXVolume(), 0);
        array_push(active_sounds, sound_id);
        
        return sound_id;
    };
    
    /// @function PlayUISound(_sound)
    static PlayUISound = function(_sound) {
        if (!settings.sfx_enabled) return noone;
        
        var sound_id = audio_play_sound(_sound, 8, false);
        audio_sound_gain(sound_id, GetUIVolume(), 0);
        
        return sound_id;
    };
    
    
    // VOICE/DIALOGUE FUNCTIONS
    
    
    /// @function PlayVoice(_sound, _interrupt)
    static PlayVoice = function(_sound, _interrupt = true) {
        if (!settings.voice_enabled) return noone;
        
        // Stop current voice if interrupting
        if (_interrupt && current_voice != noone) {
            audio_stop_sound(current_voice);
        }
        
        current_voice = audio_play_sound(_sound, 7, false);
        audio_sound_gain(current_voice, GetVoiceVolume(), 0);
        
        return current_voice;
    };
    
    /// @function StopVoice()
    static StopVoice = function() {
        if (current_voice != noone) {
            audio_stop_sound(current_voice);
            current_voice = noone;
        }
    };
    
    
    // AMBIENT SOUND FUNCTIONS
    
    
    /// @function PlayAmbient(_sound, _volume_scale)
    static PlayAmbient = function(_sound, _volume_scale = 1.0) {
        if (!settings.ambient_enabled) return noone;
        
        var sound_id = audio_play_sound(_sound, 2, true);
        var volume = GetAmbientVolume() * _volume_scale;
        audio_sound_gain(sound_id, volume, 0);
        
        array_push(ambient_sounds, {
            sound_id: sound_id,
            volume_scale: _volume_scale
        });
        
        return sound_id;
    };
    
    /// @function StopAmbient(_sound_id)
    static StopAmbient = function(_sound_id = noone) {
        if (_sound_id == noone) {
            // Stop all ambient sounds
            for (var i = 0; i < array_length(ambient_sounds); i++) {
                audio_stop_sound(ambient_sounds[i].sound_id);
            }
            ambient_sounds = [];
        } else {
            // Stop specific ambient sound
            for (var i = array_length(ambient_sounds) - 1; i >= 0; i--) {
                if (ambient_sounds[i].sound_id == _sound_id) {
                    audio_stop_sound(_sound_id);
                    array_delete(ambient_sounds, i, 1);
                    break;
                }
            }
        }
    };
    
    
    // VOLUME CONTROL FUNCTIONS
    
    
    /// @function SetMasterVolume(_volume)
    static SetMasterVolume = function(_volume) {
        settings.master_volume = clamp(_volume, 0, 1);
        UpdateAllVolumes();
    };
    
    /// @function SetMusicVolume(_volume)
    static SetMusicVolume = function(_volume) {
        music_master_volume = clamp(_volume, 0, 1);
        if (current_music != noone && !fade_data.active) {
            audio_sound_gain(current_music, GetMusicVolume(), 0);
        }
    };
    
    /// @function SetSFXVolume(_volume)
    static SetSFXVolume = function(_volume) {
        sfx_master_volume = clamp(_volume, 0, 1);
    };
    
    /// @function SetVoiceVolume(_volume)
    static SetVoiceVolume = function(_volume) {
        voice_volume = clamp(_volume, 0, 1);
        if (current_voice != noone) {
            audio_sound_gain(current_voice, GetVoiceVolume(), 0);
        }
    };
    
    /// @function SetAmbientVolume(_volume)
    static SetAmbientVolume = function(_volume) {
        ambient_volume = clamp(_volume, 0, 1);
        UpdateAmbientVolumes();
    };
    
    /// @function SetUIVolume(_volume)
    static SetUIVolume = function(_volume) {
        ui_volume = clamp(_volume, 0, 1);
    };
    
    
    // GETTER FUNCTIONS
    
    
    /// @function GetMusicVolume()
    static GetMusicVolume = function() {
        return music_master_volume * settings.master_volume;
    };
    
    /// @function GetSFXVolume()
    static GetSFXVolume = function() {
        return sfx_master_volume * settings.master_volume;
    };
    
    /// @function GetVoiceVolume()
    static GetVoiceVolume = function() {
        return voice_volume * settings.master_volume;
    };
    
    /// @function GetAmbientVolume()
    static GetAmbientVolume = function() {
        return ambient_volume * settings.master_volume;
    };
    
    /// @function GetUIVolume()
    static GetUIVolume = function() {
        return ui_volume * settings.master_volume;
    };
    
    /// @function IsPlayingMusic()
    static IsPlayingMusic = function() {
        return (current_music != noone && audio_is_playing(current_music));
    };
    
    /// @function GetCurrentMusic()
    static GetCurrentMusic = function() {
        if (current_music != noone && audio_is_playing(current_music)) {
            return audio_get_name(current_music);
        }
        return noone;
    };
    
    
    // UPDATE FUNCTION
    
    
    /// @function Update()
    /// @description Call this every step
    static Update = function() {
        // Update fade
        if (fade_data.active) {
            UpdateFade();
        }
        
        // Update crossfade
        if (crossfade_data.active) {
            UpdateCrossfade();
        }
        
        // Clean up finished sounds periodically
        if (current_time mod 60 == 0) {
            CleanupFinishedSounds();
        }
    };
    
    /// @function UpdateFade()
    static UpdateFade = function() {
        fade_data.timer++;
        
        var progress = fade_data.timer / fade_data.duration;
        progress = clamp(progress, 0, 1);
        
        // Apply fade curve based on type
        var curve_progress = progress;
        switch (fade_data.type) {
            case FADE_TYPE.LINEAR:
                curve_progress = progress;
                break;
                
            case FADE_TYPE.SMOOTH:
                curve_progress = smoothstep(0, 1, progress);
                break;
                
            case FADE_TYPE.EXPONENTIAL:
                curve_progress = progress * progress;
                break;
        }
        
        // Calculate new volume
        var new_volume = lerp(fade_data.current_volume, fade_data.target_volume, curve_progress);
        
        // Apply to current music
        if (current_music != noone && audio_is_playing(current_music)) {
            audio_sound_gain(current_music, new_volume, 0);
        }
        
        // Check if fade complete
        if (progress >= 1) {
            fade_data.active = false;
            
            // Execute callback
            if (is_callable(fade_data.callback)) {
                if (fade_data.callback_args != noone) {
                    fade_data.callback(fade_data.callback_args);
                } else {
                    fade_data.callback();
                }
            }
        }
    };
    
    /// @function UpdateCrossfade()
    static UpdateCrossfade = function() {
        crossfade_data.timer++;
        
        var progress = crossfade_data.timer / crossfade_data.duration;
        progress = clamp(progress, 0, 1);
        
        // Smooth curve
        var curve_progress = smoothstep(0, 1, progress);
        
        // Fade out old, fade in new
        var old_vol = lerp(crossfade_data.old_volume, 0, curve_progress);
        var new_vol = lerp(0, GetMusicVolume(), curve_progress);
        
        if (crossfade_data.old_sound != noone && audio_is_playing(crossfade_data.old_sound)) {
            audio_sound_gain(crossfade_data.old_sound, old_vol, 0);
        }
        
        if (crossfade_data.new_sound != noone && audio_is_playing(crossfade_data.new_sound)) {
            audio_sound_gain(crossfade_data.new_sound, new_vol, 0);
        }
        
        // Check if complete
        if (progress >= 1) {
            // Stop old sound
            if (crossfade_data.old_sound != noone) {
                audio_stop_sound(crossfade_data.old_sound);
            }
            
            crossfade_data.active = false;
        }
    };
    
    
    // UTILITY FUNCTIONS
    
    
    /// @function CleanupFinishedSounds()
    static CleanupFinishedSounds = function() {
        for (var i = array_length(active_sounds) - 1; i >= 0; i--) {
            if (!audio_is_playing(active_sounds[i])) {
                array_delete(active_sounds, i, 1);
            }
        }
    };
    
    /// @function UpdateAllVolumes()
    static UpdateAllVolumes = function() {
        // Update music
        if (current_music != noone && !fade_data.active) {
            audio_sound_gain(current_music, GetMusicVolume(), 0);
        }
        
        // Update voice
        if (current_voice != noone) {
            audio_sound_gain(current_voice, GetVoiceVolume(), 0);
        }
        
        // Update ambient
        UpdateAmbientVolumes();
    };
    
    /// @function UpdateAmbientVolumes()
    static UpdateAmbientVolumes = function() {
        for (var i = 0; i < array_length(ambient_sounds); i++) {
            var ambient = ambient_sounds[i];
            var volume = GetAmbientVolume() * ambient.volume_scale;
            audio_sound_gain(ambient.sound_id, volume, 0);
        }
    };
    
    /// @function StopAll()
    static StopAll = function() {
        StopMusic(0);
        StopVoice();
        StopAmbient();
        
        // Stop all tracked SFX
        for (var i = 0; i < array_length(active_sounds); i++) {
            if (audio_is_playing(active_sounds[i])) {
                audio_stop_sound(active_sounds[i]);
            }
        }
        active_sounds = [];
    };
    
    /// @function Cleanup()
    static Cleanup = function() {
        StopAll();
        ds_map_destroy(sfx_pool);
    };
    
    
    // SAVE/LOAD FUNCTIONS
    
    
    /// @function SaveSettings()
    static SaveSettings = function() {
        var save_string = json_stringify(settings);
        // Save to your preferred storage method
        // Example: ini_write_string("Audio", "Settings", save_string);
        return save_string;
    };
    
    /// @function LoadSettings(_json_string)
    static LoadSettings = function(_json_string) {
        try {
            var loaded = json_parse(_json_string);
            settings = loaded;
            UpdateAllVolumes();
            return true;
        } catch (_e) {
            show_debug_message("Failed to load audio settings: " + string(_e));
            return false;
        }
    };
    
    
    // HELPER FUNCTIONS
    
    
    /// @function smoothstep(_edge0, _edge1, _x)
    static smoothstep = function(_edge0, _edge1, _x) {
        var t = clamp((_x - _edge0) / (_edge1 - _edge0), 0.0, 1.0);
        return t * t * (3.0 - 2.0 * t);
    };
}


// GLOBAL INSTANCE SETUP (in obj_main_controller Create)

/*
// In obj_main_controller Create Event:
audio_system = new AudioSystem();

// Usage examples:
audio_system.PlayMusic(Sound1, true, 60); // Play with 60 frame fade in
audio_system.CrossfadeMusic(Sound2, true, 120); // Crossfade over 2 seconds
audio_system.PlaySFX(snd_explosion, 0.1, 0.8); // With pitch variance
audio_system.FadeMusic(0, 90, FADE_TYPE.SMOOTH, function() {
    room_goto(rm_main_menu);
});
*/

/// Helper function to draw volume bars:
function DrawVolumeBar(_x, _y, _value) {
    var bar_width = 200;
    var bar_height = 20;
    var bar_x = _x - bar_width / 2;
    
    // Background
    draw_set_color(c_dkgray);
    draw_rectangle(bar_x, _y - bar_height/2, bar_x + bar_width, _y + bar_height/2, false);
    
    // Fill
    draw_set_color(c_lime);
    draw_rectangle(bar_x, _y - bar_height/2, bar_x + (bar_width * _value), _y + bar_height/2, false);
    
    // Border
    draw_set_color(c_white);
    draw_rectangle(bar_x, _y - bar_height/2, bar_x + bar_width, _y + bar_height/2, true);
    
    // Percentage
    draw_set_halign(fa_left);
    draw_text(bar_x + bar_width + 10, _y, string(round(_value * 100)) + "%");
    draw_set_halign(fa_center);
}