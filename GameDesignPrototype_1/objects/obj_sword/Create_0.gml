// --- Create Event ---
owner = noone;
active = true;

// Swing properties
swinging = false;
startSwing = false;
swingSpeed = 12; // How fast the sword swings (degrees per step)
swingProgress = 0; // 0 to 1, tracks swing completion

// Position states
enum SwingPosition {
    Down = 0,
    Up = 1
}

// Current position state (starts at down position)
currentPosition = SwingPosition.Down;
targetPosition = SwingPosition.Up; // Where we're swinging to next

// Position offsets from player direction
downAngleOffset = 100; // Down/right position offset
upAngleOffset = -100; // Up/left position offset
currentAngleOffset = downAngleOffset; // Start at down position

// Combo tracking
comboCount = 0;
comboTimer = 0;
comboWindow = 30; // Steps to chain attacks

// Visual properties
swordLength = 4; // Distance from player center
swordSprite = spr_sword; // Your sword sprite

// Attack properties
hasHitThisSwing = false; // Prevent multiple hits per swing
hitList = ds_list_create(); // Track what we've hit this swing
