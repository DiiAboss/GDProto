enum ENEMY_STATE
{
	IDLE = 0,
	FOLLOW = 1,
	ATTACK = 2,
	HIT = 3
}

mySprite = spr_enemy_1;

size = sprite_get_height(mySprite);

// Wall bounce properties
bounceDampening = 1.1; // How much speed is retained after bounce (0.7 = 70%)
minBounceSpeed = 0; // Minimum speed required to bounce (prevents tiny bounces)
wallBounceCooldown = 0; // Prevents multiple bounces per frame
lastBounceDir = 0; // Track last bounce for combos

// Separation/pushing variables (new)
separationRadius = 24; // How close enemies can get to each other
pushForce = 0.5; // How strongly enemies push each other

hp = 100;
maxHp = 100;

// Knockback variables
knockbackX = 0;
knockbackY = 0;
knockbackFriction = 0.85; // How quickly knockback slows down (0.8-0.95 range works well)
knockbackThreshold = 0.1; // Minimum speed before knockback stops completely

knockbackCooldown = 0;
knockbackCooldownMax = 10; // Frames of immunity after being hit

knockbackForce = 8;
myDir = 0;
levelDecayTimer = 0;
hitFlashTimer = 0;
damage = 0;
moveSpeed = 2;
lastKnockedBy = noone; // Track who knocked this enemy
took_damage = 0;

// Chain knockback tracking
isKnockingBack = false; // True when this enemy is being knocked back
knockbackPower = 0; // Current knockback force (for passing to others)
hasTransferredKnockback = false; // Prevents multiple transfers per knockback


// Breathing/Pulse effect (idle animation)
breathTimer = 0;
breathSpeed = 0.05; // Speed of breathing (lower = slower)
breathScaleAmount = 0.05; // How much to scale (0.05 = 5% size change)
baseScale = 1; // Original scale

// Walking wobble effect
wobbleTimer = 0;
wobbleSpeed = 0.3; // Speed of wobble (higher = faster)
wobbleAmount = 10; // Degrees of rotation wobble
isMoving = false;
lastX = x;
lastY = y;


// Wall impact properties
minImpactSpeed = 3; // Minimum speed to take damage
impactDamageMultiplier = 0.1; // Damage = speed * this
maxImpactDamage = 20; // Cap on wall damage
wallHitCooldown = 0; // Prevents multiple wall damages per knockback
hasHitWall = false; // Track if we've hit a wall this knockback

// Individual variation (so enemies don't all pulse in sync)
breathOffset = random(2 * pi); // Random starting point in breath cycle
wobbleOffset = random(2 * pi); // Random starting point in wobble