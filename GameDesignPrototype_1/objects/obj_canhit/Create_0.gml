/// @description
has_friction = true;

// Weight system (0 = no friction, higher = more resistance)
weight = 10; // Default weight (medium object)
// 0 = projectile (never slows)
// 5-10 = light objects (crates, barrels)
// 20-40 = medium objects (boxes, small rocks)
// 50-80 = heavy objects (large crates, boulders)
// 100+ = immovable (basically walls)

// Physics properties
velocityX = 0;
velocityY = 0;
friction_amount = 0.9; // How quickly it slows (affected by weight)
minSpeed = 0.1; // Minimum speed before stopping
maxSpeed = 20; // Maximum velocity cap

// State
isMoving = false;
wasHit = false;
hitCooldown = 0; // Prevents multiple hits per frame

// Bounce properties
bounceDampening = 0.7; // Energy retained on wall bounce
canBounce = true; // Whether this object bounces off walls

// Visual feedback
hitFlashTimer = 0;
originalSprite = sprite_index;

// Special properties
isProjectile = false; // True for enemy projectiles
isHazard = false; // True if it damages on contact
hazardDamage = 5; // Damage if hazardous

// Chain hit properties
canChainHit = true; // Can this knock into other objects?
chainForceMultiplier = 0.5; // How much force transfers to next object

owner = noone;