/// @description
var hit = instance_place(x, y, obj_knockback);
if (hit != noone) {

        // SWORD HIT - Level up and redirect!
        
        // Gain a level
        if (level < maxLevel) {
            level++;
            updateBallStats();
        }
        
        // Reset decay timer to maximum
        levelDecayTimer = 0;
        
        // Calculate new direction
        var newDir = point_direction(hit.x, hit.y, x, y);
        myDir = newDir;
        
        // Boost speed temporarily
        currentSpeed = min(mySpeed + 2, maxSpeed);
        
        // Track who hit it
        wasHitBySword = true;
        lastHitBy = hit.owner;
        
        // Visual feedback
        hitFlashTimer = 10;
        
        // Sound effect for level up
        // audio_play_sound(snd_level_up, 1, false);
    
}
