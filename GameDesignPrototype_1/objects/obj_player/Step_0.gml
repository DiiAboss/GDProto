/// @description Insert description here
// You can write your code in this editor


// Always recalc stats with passive mods
var stats = obj_game_manager.gm_calculate_player_stats(
    base_attack, base_maxHp, base_knockback, base_speed
);

attack        = stats[0];
maxHp         = stats[1];
knockbackPower= stats[2];
mySpeed       = stats[3];



// Movement
var _left = false;
var _right = false;
var _down = false;
var _up = false;
var _dash = false;

var _mainAtk = false;
var _altAtk = false;

var _mainHold = false;
var _altHold = false;

var _currentSpeed = mySpeed;
var _diagonalSpeedMod = 0.71;

if (controllerType == CONTROL_TYPE.KBM)
{
    _left	 = (keyboard_check(ord("A"))) ? true : false;
    _right	 = (keyboard_check(ord("D"))) ? true : false;
    _down	 = (keyboard_check(ord("S"))) ? true : false;
    _up		 = (keyboard_check(ord("W"))) ? true : false;
    _dash	 = (keyboard_check_pressed(vk_space));
    _mainAtk  = (mouse_check_button_pressed(mb_left));
    _mainHold = (mouse_check_button(mb_left));
    _altAtk   = (mouse_check_button_pressed(mb_right));
    _altHold  = (mouse_check_button(mb_right));    
}

if (controllerType == CONTROL_TYPE.LAPTOP)
{
    _left	 = (keyboard_check(vk_left)) ? true : false;
    _right	 = (keyboard_check(vk_right)) ? true : false;
    _down	 = (keyboard_check(vk_down)) ? true : false;
    _up		 = (keyboard_check(vk_up)) ? true : false;
    _dash	 = (keyboard_check_pressed(vk_shift));
    _mainAtk  = (keyboard_check_pressed(vk_space));
    _mainHold = (mouse_check_button(mb_left));
    _altAtk   = (mouse_check_button_pressed(mb_right));
    _altHold  = (mouse_check_button(mb_right));    
}


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







if (_left && !place_meeting(x - _currentSpeed, y, obj_wall))
{
	x -= _currentSpeed;
}

if (_right && !place_meeting(x + _currentSpeed, y, obj_wall))
{
	x += _currentSpeed;
}

if (_down && !place_meeting(x, y + _currentSpeed, obj_wall))
{
	y += _currentSpeed;
}

if (_up && !place_meeting(x, y - _currentSpeed, obj_wall))
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

var _leftSprite   = spr_char_left;
var _righttSprite = spr_char_right;
var _upSprite     = spr_char_up;

switch (aimDirection)
{
	case 0:
		mySprite     = _righttSprite;
		img_xscale   = -1;
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
    sword.attack = attack;
	sword.startSwing = true;
}


// Apply knockback from DVD ball or other sources
if (abs(knockbackX) > 0.1 || abs(knockbackY) > 0.1) {
     // Store original position
    var prevX = x;
    var prevY = y;
    
    // Try to move
    var nextX = x + knockbackX;
    var nextY = y + knockbackY;
    
    var hitHorizontal = false;
    var hitVertical = false;
    
    // Check both axes simultaneously for corner detection
    if (place_meeting(nextX * 1.01, nextY * 1.01, obj_wall)) {
        // We hit something, figure out what
        
        // Check horizontal collision
        if (place_meeting(nextX * 1.01, y, obj_wall)) {
            hitHorizontal = true;
        }
        
        // Check vertical collision
        if (place_meeting(x, nextY * 1.01, obj_wall)) {
            hitVertical = true;
        }
        
        // Apply bounces with dampening
        if (hitHorizontal && abs(knockbackX)) {
            knockbackX = -knockbackX;
        } else if (hitHorizontal) {
            knockbackX = 0;
        }
        
        if (hitVertical && abs(knockbackY)) {
            knockbackY = -knockbackY;
        } else if (hitVertical) {
            knockbackY = 0;
        }
        
    }
    
    // Move to new position if not blocked
    if (!place_meeting(x + knockbackX, y, obj_wall)) {
        x += knockbackX;
    }
    if (!place_meeting(x, y + knockbackY, obj_wall)) {
        y += knockbackY;
    }
	
    knockbackX *= knockbackFriction;
    knockbackY *= knockbackFriction;
}


// Cannon cooldown
if (cannonCooldown > 0) {
    cannonCooldown--;
}

// Cannon ability (right click)
if (mouse_check_button_pressed(mb_right) && cannonCooldown <= 0) {
	
	mouseDistance = distance_to_point(mouse_x, mouse_y);
	
    // Launch player backwards like a cannonball
    var cannonForce = 25; // Adjust for power
    knockbackX = lengthdir_x(-cannonForce, mouseDirection);
    knockbackY = lengthdir_y(-cannonForce, mouseDirection);
    knockbackPower = cannonForce;
    lob(self, mouseDirection, mouseDistance);
    // Set cannon state
    isCannonBalling = true;
    cannonCooldown = cannonCooldownMax;
    
    // Visual effect
    // effect_create_above(ef_smoke, x, y, 1, c_gray);
    
    // Sound
    // audio_play_sound(snd_cannon_fire, 1, false);
    
    // Make player temporarily invincible during launch?
    // invulnerableTimer = 10;
}

// Update cannonball state
if (isCannonBalling) {
    // Check if we've slowed down enough
    if (abs(knockbackX) < 2 && abs(knockbackY) < 2) {
        isCannonBalling = false;
    }
    
    // Trail effect while cannonballing
    if (current_time % 2 == 0) {
        // Create afterimage or particle
    }
}


function lob(_owner = self, _direction, _distance)
{
	#region Single Shot
	var _totalAcc     = 1;//abs((Accuracy * _owner.maxAccuracy) - (Accuracy * _owner.accuracy));
	var _acc		  = clamp(_totalAcc, 0, _totalAcc);
			
	var _dir		  =	_direction + irandom_range(-_acc, _acc);
	var _bullet		  = instance_create_depth(_owner.x, _owner.y, _owner.depth, obj_lobbed);
	_bullet.owner	  = _owner;
	_bullet.direction = _direction;
	_bullet.speed	  = 4;
	_bullet.targetDistance = _distance;
	_bullet.color     = c_white;
	#endregion Single Shot
}

