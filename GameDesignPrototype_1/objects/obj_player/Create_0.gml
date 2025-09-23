/// @description Insert description here
// You can write your code in this editor
mySpeed = 4;
myDir = 0;

aimDirection = 0;

hp = 100;

mouseDirection = 0;

mySprite = spr_char_right;

img_xscale = 1;

image_speed = 0.2;

dashSpeed = 6;

orb = instance_create_depth(x, y, depth - 1, obj_player_orb);
orb.owner = self;

sword = instance_create_depth(x, y, depth-1, obj_sword);
sword.owner = self;

shotSpeed = 12;

enum Weapon
{
	None = -1,
	Sword = 0,
	Bow = 1,
}

enum CONTROL_TYPE
{
    KBM,
    LAPTOP,
    GAMEPAD
}

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

knockbackCooldown = 0;
knockbackCooldownMax = 10; // Frames of immunity after being hit