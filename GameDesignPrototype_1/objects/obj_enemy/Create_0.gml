/// @desc Enemy Create Event - Component-based

mySprite = spr_enemy_1;
size = sprite_get_height(mySprite);
img_index = 0;

marked_for_death = false;

// ==========================================
// COMPONENTS (matching player)
// ==========================================
damage_sys = new DamageComponent(100); // 100 base HP
knockback = new KnockbackComponent(0.85, 0.1);

// Legacy compatibility
hp = damage_sys.hp;
maxHp = damage_sys.max_hp;

// Movement
moveSpeed = 2;
myDir = 0;

// Visual effects
hitFlashTimer = 0;
breathTimer = 0;
breathSpeed = 0.05;
breathScaleAmount = 0.05;
baseScale = 1;
wobbleTimer = 0;
wobbleSpeed = 0.3;
wobbleAmount = 10;
isMoving = false;
lastX = x;
lastY = y;
breathOffset = random(2 * pi);
wobbleOffset = random(2 * pi);

// Knockback tracking
knockbackX = 0;
knockbackY = 0;
knockbackFriction = 0.85;
knockbackThreshold = 0.1;
knockbackCooldown = 0;
knockbackCooldownMax = 10;
knockbackForce = 8;

// Wall impact
minImpactSpeed = 3;
impactDamageMultiplier = 0.1;
maxImpactDamage = 999;
wallHitCooldown = 0;
hasHitWall = false;

// Wall bounce
bounceDampening = 1.1;
minBounceSpeed = 0;
wallBounceCooldown = 0;
lastBounceDir = 0;

// Separation
separationRadius = 24;
pushForce = 0.5;

// Damage tracking
damage = 1; // Damage enemy deals to player
last_hit_by = noone;
last_damage_taken = 0;
took_damage = 0;

// Chain knockback
isKnockingBack = false;
knockbackPower = 0;
hasTransferredKnockback = false;

// Decay
levelDecayTimer = 0;

depth = -y;

is_burning = false;
burn_timer = 0;
burn_damage_per_tick = 2;
burn_tick_counter = 0;

// NEW: Holy water chain reaction tracking
holy_water_splash_direction = 0;
killed_by_holy_water = false;