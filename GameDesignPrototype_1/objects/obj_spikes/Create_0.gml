/// @description
// Damage properties
baseDamage = 10; // Base spike damage
velocityDamageMultiplier = 0.5; // Extra damage based on impact speed
maxDamage = 30; // Cap maximum damage

// Visual properties
originalSprite = sprite_index;
bloodTimer = 0; // Shows blood effect after hit
shake = 0; // Shake on impact

// Tracking for combos/scoring
lastKnockedBy = noone; // Who knocked enemy into spikes
comboWindow = 60; // Frames to credit knockback killer

// List of enemies currently touching (prevents multi-hit per frame)
hitList = ds_list_create();
hitCooldown = 15; // Frames before same enemy can be hit again

// Sound/effect flags
playedSound = false;