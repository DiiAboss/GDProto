// Movement with current speed
var nextX = x + lengthdir_x(currentSpeed, myDir);
var nextY = y + lengthdir_y(currentSpeed, myDir);

// Get tile layer
var tile_layer_id = layer_get_id("Tiles_2");
var tilemap_id = layer_tilemap_get_id(tile_layer_id);

// Wall and tile bouncing (DVD style)
var bounced = false;

// Check horizontal collision (walls + tiles)
var tile_x = tilemap_get_at_pixel(tilemap_id, nextX, y);
if (place_meeting(nextX, y, obj_wall) || place_meeting(nextX, y, obj_spikes) || (tile_x > 446 || tile_x <= 0)) {
    myDir = 180 - myDir;
    bounced = true;
}

// Check vertical collision (walls + tiles)
var tile_y = tilemap_get_at_pixel(tilemap_id, x, nextY);
if (place_meeting(x, nextY, obj_wall) || place_meeting(x, nextY, obj_spikes) || (tile_y > 446 || tile_y <= 0)) {
    myDir = -myDir;
    bounced = true;
}

// Apply movement
x += lengthdir_x(currentSpeed, myDir) * game_speed_delta();
y += lengthdir_y(currentSpeed, myDir) * game_speed_delta();

// === LEVEL DECAY SYSTEM ===
// Increment decay timer when not hitting anything
levelDecayTimer += game_speed_delta();

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