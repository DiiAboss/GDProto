/// @description
OnRoomStart(DetermineRoomType(room));

if (room == rm_demo_room) {
    // CRITICAL: Ensure game is unpaused
    pause_manager.ResumeAll();
    global.gameSpeed = 1.0;
    
    audio_play_sound(Sound2, 1, 1);
}