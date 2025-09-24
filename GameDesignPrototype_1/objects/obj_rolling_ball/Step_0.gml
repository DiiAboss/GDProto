// Movement with current speed
var nextX = x + lengthdir_x(currentSpeed, myDir);
var nextY = y + lengthdir_y(currentSpeed, myDir);

// Wall bouncing (DVD style)
var bounced = false;
if (place_meeting(nextX, y, obj_obstacle)) {
    myDir = 180 - myDir;
    bounced = true;
}
if (place_meeting(x, nextY, obj_obstacle)) {
    myDir = -myDir;
    bounced = true;
}

// Apply movement
x += lengthdir_x(currentSpeed, myDir);
y += lengthdir_y(currentSpeed, myDir);

// === LEVEL DECAY SYSTEM ===
// Increment decay timer when not hitting anything
levelDecayTimer++;

// Check if we should decay a level
if (level > 0 && levelDecayTimer > levelDecayDelay + levelDecayRate) {
    // Lose a level
    level--;
    levelDecayTimer = levelDecayDelay; // Reset to delay, not 0
    
    // Update stats for new level
    updateBallStats();
}

// === UPDATE STATS BASED ON LEVEL ===
function updateBallStats() {
    // Damage scales with level
    damage = baseDamage + (level * 2); // +2 damage per level
    
    // Knockback scales with level
    knockbackForce = baseKnockback + (level * 1.5); // +1.5 knockback per level
    
    // Speed scales with level
    mySpeed = 4 + (level * 0.5); // +0.5 speed per level
    currentSpeed = max(currentSpeed, mySpeed); // Don't reduce current if it's boosted
    
    // Color changes with level
    currentColor = colorList[min(level, array_length(colorList) - 1)];
}

// Update hit cooldown list
for (var i = ds_list_size(hitList) - 1; i >= 0; i--) {
    var hitData = hitList[| i];
    hitData[1]--; // Decrease cooldown
    if (hitData[1] <= 0) {
        ds_list_delete(hitList, i);
    }
}

// Visual effect timers
if (hitFlashTimer > 0) hitFlashTimer--;

// Keep direction in valid range
while (myDir < 0) myDir += 360;
while (myDir >= 360) myDir -= 360;

// Corner hit timer
if (cornerHitTimer > 0) {
    cornerHitTimer--;
}