// --- Create Event ---
owner = noone;
active = true;

baseRange = 32;

// Swing properties
swinging = false;
startSwing = false;
swingSpeed = 8; // How fast the sword swings (degrees per step)
swingProgress = 0; // 0 to 1, tracks swing completion


comboSequence = [];  // Array to store button presses
maxComboLength = 3;  // Maximum combo length
comboInputWindow = 30; // Frames to input next combo move
comboInputTimer = 0;

// Attack types
//enum AttackType {
//    Light,
//    Heavy,
//    Spin,
//    Jump
//}

current_combo_state = ComboState.LIGHT_1;

// Rotation attack variables
isSpinning = false;
spinProgress = 0;
spinSpeed = 8;  // How fast the spin completes
spinStartAngle = 0;
lightAttackTriggered = false;
heavyAttackTriggered = false;
spinStartPosition = SwingPosition.Down; // Track where spin started

// Position states
enum SwingPosition {
    Down = 0,
    Up = 1
}

attack = 10;

// Current position state (starts at down position)
currentPosition = SwingPosition.Down;
targetPosition = SwingPosition.Up; // Where we're swinging to next

// Position offsets from player direction
baseAngleOffset = 100;
angleOffsetMod = 1;
angleOffset = baseAngleOffset * angleOffsetMod;

downAngleOffset = angleOffset; // Down/right position offset
upAngleOffset = -angleOffset; // Up/left position offset
currentAngleOffset = downAngleOffset; // Start at down position
knockbackForce = 64;
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
