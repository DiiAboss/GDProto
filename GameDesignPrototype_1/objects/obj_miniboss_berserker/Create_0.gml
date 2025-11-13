/// @description
/// @desc Miniboss Create Event - Enhanced Tank Enemy

// Inherit base enemy components
event_inherited();


// OVERRIDE BASE ENEMY VALUES

mySprite = spr_mini_boss_1;
size = sprite_get_height(mySprite);

// Enhanced stats
damage_sys = new DamageComponent(self, 1000); // 5x base enemy HP
hp = damage_sys.hp;
maxHp = damage_sys.max_hp;

moveSpeed = 3; // Slower than regular enemies
baseSpeed = 3;

score_value = 100; // 10x regular enemy score

// Larger separation radius
separationRadius = 48;

// Enhanced knockback resistance
knockback = new KnockbackComponent(0.5, 0.05); // More resistant
knockbackFriction = 0.5;


// MINIBOSS-SPECIFIC PROPERTIES



state = BOSS_STATE.FOLLOW;

// Attack properties
attackRange = 320;
attackWindupTime = 45; // Frames to charge attack
attackCooldownTime = 60; // Frames between attacks
attackTimer = 0;

// Projectile properties
projectileCount = 6; // Number of projectiles per attack
projectileSpread = 10; // Degrees between projectiles
projectileSpeed = 6;
projectileDamage = 10;

// Animation
currentSprite = mySprite;
attackSprite = spr_mini_boss_1_atk;
animationLocked = false;
chargeScale = 1.0;
maxChargeScale = 1.3;

// Visual telegraphing
isCharging = false;
chargeProgress = 0;

// Boss-specific flags
isBoss = true;
miniboss_defeated = false;