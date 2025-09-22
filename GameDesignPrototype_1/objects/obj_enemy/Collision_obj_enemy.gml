// CHAIN KNOCKBACK: If we're being knocked back, transfer force to the enemy we hit
if (isKnockingBack && !hasTransferredKnockback) {
    // Calculate direction from us to the other enemy
    var transferDir = point_direction(x, y, other.x, other.y);
    
    // Transfer a percentage of our knockback force
    var transferForce = knockbackPower * 0.75; // 50% force transfer (adjust as needed)
    
    // Only transfer if the force is meaningful
    if (transferForce > 0.5 && other.knockbackCooldown <= 0) {
        // Apply knockback to the other enemy
        other.knockbackX = lengthdir_x(transferForce, transferDir);
        other.knockbackY = lengthdir_y(transferForce, transferDir);
        other.knockbackCooldown = 5; // Short cooldown to prevent instant re-knockback
        
        // Mark that we've transferred knockback this cycle
        hasTransferredKnockback = true;
        
        // Optional: Reduce our own knockback slightly (conservation of momentum)
        knockbackX *= 0.8;
        knockbackY *= 0.8;
        
        // Visual/Audio feedback for chain hit
        // effect_create_above(ef_ring, other.x, other.y, 0, c_yellow);
        // audio_play_sound(snd_chain_hit, 1, false);
    }
}

// NORMAL SEPARATION: Regular pushing when enemies overlap
else if (!isKnockingBack && !other.isKnockingBack) {
    // Normal enemy-enemy collision (gentle push)
    var pushDir = point_direction(other.x, other.y, x, y);
    var pushForce = 0.5;
    
    x += lengthdir_x(pushForce, pushDir);
    y += lengthdir_y(pushForce, pushDir);
}
