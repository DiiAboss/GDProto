
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