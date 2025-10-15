function PlayerMovement(_self, _playerSpeed) constructor
{
	
	callingObject    = _self;
	
	
	baseSpeed	 = _playerSpeed;
	currentSpeed = baseSpeed;
		
	// Dash Functions
	canDash			 = true;
	dashTimer		 = 0;
	maxDashTimer	 = 8;
	dashSpeed		 = 6;
	isDashing        = false;
	
	///Update - Call in Step Event
	static Update = function(_input, _speed = baseSpeed) {
    if (!_input) {
        show_debug_message("Input Script Not Found");
        return false;
    }
    
    var _self = callingObject;
    var _currentSpeed = _speed; // Already scaled by caller
    
    // Movement keys
    var _leftKey = _input.Left;
    var _rightKey = _input.Right;
    var _downKey = _input.Down;
    var _upKey = _input.Up;
    var _dashKey = _input.Action;
    var _hasMoved = false;
    
    // Diagonal adjustment
    if ((_leftKey || _rightKey) && (_upKey || _downKey)) {
        var _diagonalAdjust = 0.71;
        currentSpeed = _currentSpeed * _diagonalAdjust;
    } else {
        currentSpeed = _currentSpeed;
    }
    
    // Dash handling
    if (_dashKey) CheckCanExecuteDash();
    
    currentSpeed = ExecuteDash(baseSpeed, dashTimer);
    dashTimer = timer_tick(dashTimer); // CHANGED
    
    if (dashTimer <= 0) {
        canDash = true;
    }
    
    // Apply movement
    with (callingObject) {
        if (_leftKey && !place_meeting(x - other.currentSpeed, y, obj_wall)) {
            x -= other.currentSpeed;
            _hasMoved = true;
        }

        if (_rightKey && !place_meeting(x + other.currentSpeed, y, obj_wall)) {
            x += other.currentSpeed;
            _hasMoved = true;
        }

        if (_downKey && !place_meeting(x, y + other.currentSpeed, obj_wall)) {
            y += other.currentSpeed;
            _hasMoved = true;
        }

        if (_upKey && !place_meeting(x, y - other.currentSpeed, obj_wall)) {
            y -= other.currentSpeed;
            _hasMoved = true;
        }
    }
    
    return _hasMoved;
}
	

	
	
	static CheckCanExecuteDash = function()
	{
		if !(canDash) return false;
		dashTimer = maxDashTimer;
		canDash   = false;
		
		return true;
	}
	
	static ExecuteDash = function(_baseSpeed, _dashTimer)
	{
		var _currentSpeed = _baseSpeed;
		
		if (_dashTimer > 0) {
			_currentSpeed *= dashSpeed;
			
			createAfterImage(callingObject, _dashTimer, 2, callingObject.mySprite, callingObject.image_index);
		}
		return _currentSpeed;
	}
}



function createAfterImage(_self, _timer, _framesPerImage, _sprite, _image_index)
{
	if (_timer % _framesPerImage == 0)
	{
		var afterimage = instance_create_depth(_self.x, _self.y, _self.depth, obj_afterImage);
		afterimage.mySprite = _self.mySprite;
		afterimage.myImg = _self.image_index;
		afterimage.image_xscale = _self.image_xscale;
		afterimage.image_yscale = _self.image_yscale;
		return afterimage;		
	}
	return noone;
}





function KnockbackController() constructor
{
	knockbackX = 0;
	knockbackY = 0;
	knockbackForce = 0;
	knockbackFriction = 0;
	
	collisionList = [obj_solid];
	
	static Update = function(_self)
	{
		if (abs(knockbackX) > 0.1 || abs(knockbackY) > 0.1)
		{
			// Store original position
		    var prevX = _self.x;
		    var prevY = _self.y;
			
			// Try to move
		    var nextX = _self.x + knockbackX;
		    var nextY = _self.y + knockbackY;
    
		    var hitHorizontal = false;
		    var hitVertical   = false;
    
		    // Check both axes simultaneously for corner detection
		    if (place_meeting(nextX * 1.01, nextY * 1.01, obj_wall)) {
		        // We hit something, figure out what
        
		        // Check horizontal collision
		        if (place_meeting(nextX * 1.01, _self.y, obj_wall)) {
		            hitHorizontal = true;
		        }
        
		        // Check vertical collision
		        if (place_meeting(_self.x, nextY * 1.01, obj_wall)) {
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
		    if (!place_meeting(_self.x + knockbackX, _self.y, obj_wall)) {
		        _self.x += knockbackX;
		    }
		    if (!place_meeting(_self.x, _self.y + knockbackY, obj_wall)) {
		        _self.y += knockbackY;
		    }
	
		    knockbackX *= knockbackFriction;
		    knockbackY *= knockbackFriction;
				}
			}	
}









function SpriteHandler(_leftSprite, _rightSprite, _upSprite, _downSprite) constructor
{
	drawDirection = EAST;
	
	static eastSprite    = _rightSprite;
	static northSprite   = _upSprite;
	static westSprite    = _leftSprite;
	static southSprite   = _downSprite;
	
	//currentSprite = eastSprite;
	
	img_xscale    = 1;
	
	
	
	static UpdateSpriteByAimDirection = function(_currentSprite, _aimDirection)
	{
		var _sprite = _currentSprite;
		
		if (_aimDirection > SOUTHEAST || _aimDirection < NORTHEAST) drawDirection = EAST;
		if (_aimDirection > NORTHEAST && _aimDirection < NORTHWEST) drawDirection = NORTH;
		if (_aimDirection > NORTHWEST && _aimDirection < SOUTHWEST) drawDirection = WEST;
		if (_aimDirection > SOUTHWEST && _aimDirection < SOUTHEAST) drawDirection = SOUTH;
		
		switch (drawDirection)
		{
			// Right
			case EAST: 
				_sprite    = eastSprite;
			break;
			
			// Up
			case NORTH: 
				_sprite    = northSprite;
			break;
			
			// Left
			case WEST: 
				_sprite    = westSprite;
			break;
			
			// Down
			case SOUTH: 
			break;
			
			case NORTHEAST:  //topleft
			break;
			case NORTHWEST: //topright
			break;
			case SOUTHEAST: //bottomleft
			break;
			case SOUTHWEST: //bottomright
			break;
			
			default:
			break;
		}
		
		return _sprite;
		
	}
	
	static DrawSprite = function(_self, _sprite)
	{
		draw_sprite_ext(_sprite, -1, _self.x, _self.y, 1, 1, 0, c_white, 1);
	}
}