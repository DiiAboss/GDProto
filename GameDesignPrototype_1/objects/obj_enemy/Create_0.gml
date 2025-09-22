enum ENEMY_STATE
{
	IDLE = 0,
	FOLLOW = 1,
	ATTACK = 2,
	HIT = 3
}


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

moveSpeed = 2;

// Chain knockback tracking
isKnockingBack = false; // True when this enemy is being knocked back
knockbackPower = 0; // Current knockback force (for passing to others)
hasTransferredKnockback = false; // Prevents multiple transfers per knockback
