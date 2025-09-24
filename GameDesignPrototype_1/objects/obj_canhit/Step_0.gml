/// @description
// Update hit cooldown
if (hitCooldown > 0) {
    hitCooldown--;
}

// Apply velocity with weight-based physics
if (abs(velocityX) > minSpeed || abs(velocityY) > minSpeed) {
    isMoving = true;
    
    // Calculate friction based on weight
    var actualFriction = 1;
    if (weight > 0) {
        // Heavier objects slow down faster
        actualFriction = 1 - ((1 - friction_amount) * (weight / 100));
        actualFriction = max(actualFriction, 0.7); // Minimum 70% speed retained
    }
    // Weight 0 (projectiles) never slow down
    
    // Check for wall collisions
    var nextX = x + velocityX;
    var nextY = y + velocityY;
    
    // Horizontal collision
    if (place_meeting(nextX, y, obj_wall)) {
        if (canBounce && abs(velocityX) > 2) {
            velocityX = -velocityX * bounceDampening;
        } else {
            velocityX = 0;
        }
    } else {
        x = nextX;
    }
    
    // Vertical collision
    if (place_meeting(x, nextY, obj_wall)) {
        if (canBounce && abs(velocityY) > 2) {
            velocityY = -velocityY * bounceDampening;
        } else {
            velocityY = 0;
        }
    } else {
        y = nextY;
    }
    
    // Apply friction (except for projectiles)
    if (weight > 0) {
        velocityX *= actualFriction;
        velocityY *= actualFriction;
        
        // Stop if too slow
        if (abs(velocityX) < minSpeed) velocityX = 0;
        if (abs(velocityY) < minSpeed) velocityY = 0;
    }
    
    // Cap maximum speed
    var currentSpeed = point_distance(0, 0, velocityX, velocityY);
    if (currentSpeed > maxSpeed) {
        var ratio = maxSpeed / currentSpeed;
        velocityX *= ratio;
        velocityY *= ratio;
    }
} else {
    isMoving = false;
    velocityX = 0;
    velocityY = 0;
}

// Update visual effects
if (hitFlashTimer > 0) {
    hitFlashTimer--;
}

// Special behavior for projectiles
if (isProjectile && weight == 0) {
    // Projectiles maintain constant speed
    if (speed < 5 && isMoving) {
        speed = 5; // Minimum projectile speed
    }
}