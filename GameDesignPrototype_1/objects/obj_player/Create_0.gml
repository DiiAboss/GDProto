


mySpeed = 4;
myDir = 0;
aimDirection = 0;

hp			   = 100;
maxHp	       = 100;
attack		   = 5;
knockbackPower = 5;
attackSpeed    = 1;


base_attack    = 5;
base_maxHp     = 100;
base_knockback = 5;
base_speed     = 4;

hp             = base_maxHp;
attack         = base_attack;
knockbackPower = base_knockback;
mySpeed        = base_speed;

attack_counter = 0;



mouseDirection = 0;
mouseDistance = 0;

mySprite = spr_char_right;

img_xscale = 1;

depth = -y;

image_speed = 0.2;

dashSpeed = 6;

//orb = instance_create_depth(x, y, depth - 1, obj_player_orb);
//orb.owner = self;

sword = instance_create_depth(x, y, depth-1, obj_sword);
sword.owner = self;

shotSpeed = 12;

controllerType = CONTROL_TYPE.KBM;

canDash = true;
dashTimer = 0;
maxDashTimer = 8;

currentWeapon = Weapon.Sword;

// Knockback variables
knockbackX = 0;
knockbackY = 0;
knockbackFriction = 0.85; // How quickly knockback slows down (0.8-0.95 range works well)
knockbackThreshold = 0.1; // Minimum speed before knockback stops completely
knockbackPower = 0;

knockbackCooldown = 0;
knockbackCooldownMax = 10; // Frames of immunity after being hit

cannonCooldown = 0;
cannonCooldownMax = 30; // Half second between cannon uses
isCannonBalling = false; // Track if we're in cannon ball state
cannonDamage = 20; // Damage dealt when ramming enemies