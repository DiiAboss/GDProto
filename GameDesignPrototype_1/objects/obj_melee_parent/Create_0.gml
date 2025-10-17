/// @description Melee Parent - Create Event

owner = noone;
active = true;
baseRange = 32;

// Swing properties (YOUR ORIGINAL SYSTEM)
swinging = false;
isSwinging = false; // Alias for compatibility
startSwing = false;
swingSpeed = 8; // How fast the sword swings
swingProgress = 0; // 0 to 1, tracks swing completion


// Current position state (starts at down position)
currentPosition = SwingPosition.Down;
targetPosition = SwingPosition.Up;

// Position offsets from player direction
baseAngleOffset = 100;
angleOffsetMod = 1;
angleOffset = baseAngleOffset * angleOffsetMod;
downAngleOffset = angleOffset;
upAngleOffset = -angleOffset;
currentAngleOffset = downAngleOffset; // Start at down position

// Combat properties
attack = 10;
knockbackForce = 64;

// Combo tracking
comboCount = 0;
comboTimer = 0;
comboWindow = 30; // Steps to chain attacks

// Visual properties
swordLength = 4; // Distance from player center
swordSprite = sprite_index;

// Hit tracking
hasHitThisSwing = false;
hitList = ds_list_create();
hit_enemies = hitList; // Alias for compatibility

// Weapon type
weapon_id = Weapon.None;
current_combo_hit = 0;