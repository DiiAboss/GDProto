
myDir = irandom(360);
mySpeed = 4;
maxSpeed = 8;
currentSpeed = mySpeed;


name = "rolling_ball";

// Level system
level = 0;
maxLevel = 6; // Cap at level 6 (7 colors in array)
levelDecayTimer = 0;
levelDecayDelay = 120; // 2 seconds at 60fps before decay starts
levelDecayRate = 180; // 3 seconds to lose a level when idle

// Color based on level
currentColor = c_white;
colorList = [c_white, c_yellow, c_orange, c_red, c_fuchsia, c_blue, c_teal];
colorIndex = 0;

// Stats that scale with level
baseDamage = 5;
damage = baseDamage;
baseKnockback = 24;
knockbackForce = baseKnockback;

// State tracking
wasHitBySword = false;
hitFlashTimer = 0;
lastHitBy = noone;

// Hit tracking
hitList = ds_list_create();
hitCooldown = 10;

// Corner hit (keeping from original)
cornerHitTimer = 0;

alarm[0] = 600;

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

