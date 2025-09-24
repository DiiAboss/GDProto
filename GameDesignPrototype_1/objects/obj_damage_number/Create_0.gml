/// @description
// The damage value to display
damage = 0;
damageString = "0";

// Movement properties
floatSpeed = 1; // How fast it floats up
floatAccel = -0.01; // Slows down as it rises
currentSpeed = floatSpeed;


driftX = random_range(-0.5, 0.5); // Horizontal drift (slight random movement)
driftDecay = 0.95; // Drift slows over time

// Visual properties
fadeSpeed = 0.02; // How fast it fades
currentAlpha = 1;
scale = 0.4;
scaleSpeed = 0.01; // Grows slightly as it rises

lifetime = 60; // Frames before destruction
age = 0;

// Color based on damage type
textColor = c_white;
outlineColor = c_black;

// Critical hit properties
isCrit = false;
critScale = 1.5;
critShake = 0;

owner = noone;