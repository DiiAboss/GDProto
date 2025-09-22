/// @description Insert description here
// You can write your code in this editor
mySpeed = 4;
myDir = 0;

aimDirection = 0;

mouseDirection = 0;

mySprite = spr_char_right;

img_xscale = 1;

image_speed = 0.2;

dashSpeed = 6;

sword = instance_create_depth(x, y, depth-1, obj_sword);
sword.owner = self;

shotSpeed = 12;

enum Weapon
{
	None = -1,
	Sword = 0,
	Bow = 1,
}

canDash = true;
dashTimer = 0;
maxDashTimer = 8;

currentWeapon = Weapon.Sword;