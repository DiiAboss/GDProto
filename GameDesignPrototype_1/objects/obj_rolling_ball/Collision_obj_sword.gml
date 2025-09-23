var hitSword = instance_place(x, y, obj_sword);
if (hitSword != noone && hitSword.swinging) {
    if (hitSword.swingProgress > 0.2 && hitSword.swingProgress < 0.8) {
        // SWORD HIT - Level up and redirect!
        
        // Gain a level
        if (level < maxLevel) {
            level++;
            updateBallStats();
        }
        
        // Reset decay timer to maximum
        levelDecayTimer = 0;
        
        // Calculate new direction
        var newDir = point_direction(hitSword.owner.x, hitSword.owner.y, x, y);
        var swingAngle = hitSword.currentAngleOffset;
        myDir = newDir + (swingAngle * 0.3);
        
        // Boost speed temporarily
        currentSpeed = min(mySpeed + 2, maxSpeed);
        
        // Track who hit it
        wasHitBySword = true;
        lastHitBy = hitSword.owner;
        
        // Visual feedback
        hitFlashTimer = 10;
        
        // Sound effect for level up
        // audio_play_sound(snd_level_up, 1, false);
    }
}
