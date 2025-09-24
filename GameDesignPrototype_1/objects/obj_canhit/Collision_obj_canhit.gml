/// @description
// Chain reactions between hittable objects!
var _other = instance_place(x, y, obj_canhit);
if (_other != noone && _other.id != id && canChainHit && isMoving) {
    if (abs(velocityX) > 2 || abs(velocityY) > 2) {
        // Transfer momentum based on weight difference
        var weightRatio = 1;
        if (_other.weight > 0) {
            weightRatio = weight / (weight + _other.weight);
        }
        
        // Calculate transfer force
        var transferX = velocityX * chainForceMultiplier * (1 - weightRatio);
        var transferY = velocityY * chainForceMultiplier * (1 - weightRatio);
        
        // Apply to other object
        _other.velocityX += transferX;
        _other.velocityY += transferY;
        _other.wasHit = true;
        _other.hitFlashTimer = 5;
        
        // Reduce our velocity (conservation of momentum)
        velocityX *= (1 - chainForceMultiplier);
        velocityY *= (1 - chainForceMultiplier);
    }
}
