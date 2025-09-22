/// @description Insert description here
// You can write your code in this editor

// Movement

var _left = false;
var _right = false;
var _down = false;
var _up = false;
var _dash = false;

var _currentSpeed = mySpeed;
var _diagonalSpeedMod = 0.71;

_left	 = (keyboard_check(ord("A"))) ? true : false;
_right	 = (keyboard_check(ord("D"))) ? true : false;
_down	 = (keyboard_check(ord("S"))) ? true : false;
_up		 = (keyboard_check(ord("W"))) ? true : false;
_dash	 = (keyboard_check_pressed(vk_space));


if ((_left || _right) && (_up || _down))
{
	_currentSpeed = mySpeed * _diagonalSpeedMod;
}


// Dash handling
if (_dash) { 
	// Using a skill in oPlayer (e.g., dash)
	if (canDash) {
	    dashTimer = maxDashTimer;
	    canDash = false; // Disable dash until cooldown is over
	}
}


if (dashTimer > 0) {
    dashTimer -= 1;
	_currentSpeed *= dashSpeed;
	// Assuming 'dashStep' is a variable that counts the frames of the dash
    if (dashTimer % 2 == 0) { // Create an afterimage every 2 frames, adjust as needed
        var afterimage = instance_create_depth(x, y, depth, obj_afterImage);
        afterimage.mySprite = mySprite;
        afterimage.myImg = image_index;
        afterimage.image_xscale = image_xscale;
        afterimage.image_yscale = image_yscale;
    }
}

else

{
	canDash = true;
}







if (_left)
{
	x -= _currentSpeed;
}

if (_right)
{
	x += _currentSpeed;
}

if (_down)
{
	y += _currentSpeed;
}

if (_up)
{
	y -= _currentSpeed;
}

image_speed = (_up || _down || _left || _right) ? 0.4 : 0.2; 



mouseDirection = point_direction(x, y, mouse_x, mouse_y);
var _NE = 45;
var _NW = 135;
var _SW = 225;
var _SE = 315;

if (mouseDirection > _SE || mouseDirection < _NE) aimDirection = 0;
if (mouseDirection > _NE && mouseDirection < _NW) aimDirection = 90;
if (mouseDirection > _NW && mouseDirection < _SW) aimDirection = 180;
if (mouseDirection > _SW && mouseDirection < _SE) aimDirection = 270;

var _leftSprite = spr_char_left;
var _righttSprite = spr_char_right;
var _upSprite = spr_char_up;

switch (aimDirection)
{
	case 0:
		mySprite = _righttSprite;
		img_xscale = -1;
	break;
	case 90:
		mySprite = _upSprite;
	break;
	case 180:
		mySprite = _leftSprite;
		img_xscale = 1;
	break;
}



if (mouse_check_button(mb_right))
{
	currentWeapon = Weapon.Bow;
	sword.active = false;
	
	if (mouse_check_button_pressed(mb_left))
	{       
			var angle_rad = degtorad(mouseDirection);
	        var xOffset = lengthdir_x(20, mouseDirection);
	        var yOffset = lengthdir_y(20, mouseDirection);


	        var _bullet = instance_create_depth(x + xOffset, y + yOffset, depth, obj_arrow);
	        _bullet.myDir = mouseDirection;
	        _bullet.img_xscale = image_xscale;
			_bullet.image_angle = mouseDirection;
			_bullet.direction = direction;
        
	}
}
else
{
	currentWeapon = Weapon.Sword;
	sword.active = true;
}


// Attack input - trigger sword swing
if (mouse_check_button_pressed(mb_left) && currentWeapon == Weapon.Sword) {
    sword.startSwing = true;
}
