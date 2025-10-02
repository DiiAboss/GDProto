/// @description
// Chain reactions between hittable objects!
if (other != noone && other.id != id && canChainHit && isMoving) {
    if (abs(velocityX) > 2 || abs(velocityY) > 2) {
        // Transfer momentum based on weight difference
        var weightRatio = 1;
        if (other.weight > 0) {
            weightRatio = weight / (weight + other.weight);
        }
        
        // Calculate transfer force
        var transferX = velocityX * chainForceMultiplier * (1 - weightRatio);
        var transferY = velocityY * chainForceMultiplier * (1 - weightRatio);
        
        // Apply to other object
        other.velocityX += transferX;
        other.velocityY += transferY;
        other.wasHit = true;
        other.hitFlashTimer = 5;
        
        // Reduce our velocity (conservation of momentum)
        velocityX *= (1 - chainForceMultiplier);
        velocityY *= (1 - chainForceMultiplier);
    }
}
