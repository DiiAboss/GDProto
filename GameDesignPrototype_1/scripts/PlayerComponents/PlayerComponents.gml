/// @description PlayerMovement with Pit Detection (FIXED for > 446)
/// Updated PlayerMovement constructor

function PlayerMovement(_self, _playerSpeed) constructor {
    
    callingObject = _self;
    
    baseSpeed = _playerSpeed;
    currentSpeed = baseSpeed;
    
    // Dash Functions
    canDash = true;
    dashTimer = 0;
    maxDashTimer = 6;
    dashSpeed = 4;
    isDashing = false;
    
	dashCooldown = 60;
	
	dashMax = 60;
	
	
    /// Update - Call in Step Event
    static Update = function(_input, _speed = baseSpeed) {
        if (!_input) {
            show_debug_message("Input Script Not Found");
            return false;
        }
        
        var _self = callingObject;
        
        // Check if falling - disable movement
        if (_self.is_falling_in_pit) {
            _self.ProcessPitFall();
            return false;
        }
		
		
        
        var _currentSpeed = _speed;
        
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
        
        currentSpeed = ExecuteDash(_self, baseSpeed, dashTimer);
        dashTimer = timer_tick(dashTimer);
        if (dashCooldown > 0) {
		dashCooldown = timer_tick(dashCooldown);
		}
		else {
			canDash = true;
		}
        
        // PIT AVOIDANCE - Only if NOT dashing
        var can_move_into_pit = (dashTimer > 0); // Can dash into pits
        
        // Apply movement with pit checks
        with (callingObject) {
            var next_x = x;
            var next_y = y;
            
            // Calculate next position
            if (_leftKey) next_x -= other.currentSpeed;
            if (_rightKey) next_x += other.currentSpeed;
            if (_downKey) next_y += other.currentSpeed;
            if (_upKey) next_y -= other.currentSpeed;
            
            // Check if next position is pit (tile > 446 = PIT)
            var tile_ahead = tilemap_get_at_pixel(tilemap_id, next_x, next_y);
            var is_pit_ahead = (tile_ahead > 446 || tile_ahead == 0);
            var is_safe_tile = (tile_ahead <= 446 && tile_ahead != 0);
            // Block movement if pit ahead (unless dashing)
            if (is_pit_ahead && !can_move_into_pit) {
                // Try individual axes (allows sliding along pit edge)
                if (_leftKey) {
                    var test_x = x - other.currentSpeed;
                    var test_tile = tilemap_get_at_pixel(tilemap_id, test_x, y);
					
                    if (is_safe_tile && !place_meeting(test_x, y, obj_wall)) {
                        x = test_x;
                        _hasMoved = true;
                    }
                }
                if (_rightKey) {
                    var test_x = x + other.currentSpeed;
                    var test_tile = tilemap_get_at_pixel(tilemap_id, test_x, y);
                    if (is_safe_tile &&  !place_meeting(test_x, y, obj_wall)) {
                        x = test_x;
                        _hasMoved = true;
                    }
                }
                if (_downKey) {
                    var test_y = y + other.currentSpeed;
                    var test_tile = tilemap_get_at_pixel(tilemap_id, x, test_y);
                    if (is_safe_tile &&  !place_meeting(x, test_y, obj_wall)) {
                        y = test_y;
                        _hasMoved = true;
                    }
                }
                if (_upKey) {
                    var test_y = y - other.currentSpeed;
                    var test_tile = tilemap_get_at_pixel(tilemap_id, x, test_y);
                    if (is_safe_tile &&  !place_meeting(x, test_y, obj_wall)) {
                        y = test_y;
                        _hasMoved = true;
                    }
                }
            } else {
                // Normal movement (no pit or dashing)
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
        }
        
        // Update last safe position and check for pit fall
        _self.UpdateLastSafePosition();
        _self.CheckPitFall();
        
        return _hasMoved;
    }
    
    static CheckCanExecuteDash = function() {
        if !(canDash) return false;
        dashTimer = maxDashTimer;
        canDash = false;
        dashCooldown = dashMax;
        return true;
    }
    
    static ExecuteDash = function(_self, _baseSpeed, _dashTimer) {
        var _currentSpeed = _baseSpeed * global.gameSpeed;
		
        if (_dashTimer > 0) {
            _currentSpeed *= dashSpeed;
            _self.invincibility.active = true;
            _self.invincibility.timer = 2;
            createAfterImage(callingObject, _dashTimer, 2, callingObject.currentSprite, callingObject.image_index);
			
			// Check if we dodged near an enemy projectile
		    var dodged_something = false;
		    with (obj_enemy_attack_orb) { // Or whatever enemy projectiles are
		        if (distance_to_object(other) < 32) {
		            dodged_something = true;
		            break;
		        }
		    }
		    
		    if (dodged_something) {
		        _self.dodge_count++;
		        _self.last_dodge_time = current_time;
		        
		        // Award dodge points
		        if (instance_exists(obj_game_manager)) {
		            obj_game_manager.score_manager.AddScore(10, {dodge: true});
		            
		            // Visual event
		            if (variable_instance_exists(obj_game_manager, "score_display")) {
		                obj_game_manager.score_display.AddComboEvent("DODGE", 10, 1);
		            }
		        }
		    }
			
			
        }
        return _currentSpeed;
    }
}

function createAfterImage(_self, _timer, _framesPerImage, _sprite, _image_index)
{
	if (_timer % _framesPerImage == 0)
	{
		var afterimage = instance_create_depth(_self.x, _self.y, _self.depth, obj_afterImage);
		afterimage.mySprite = _self.currentSprite;
		afterimage.myImg = _self.image_index;
		afterimage.image_xscale = _self.image_xscale;
		afterimage.image_yscale = _self.image_yscale;
		return afterimage;		
	}
	return noone;
}

function SpriteHandler(_leftSprite, _rightSprite, _upSprite, _downSprite) constructor
{
	static drawDirection = EAST;
	
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
				_sprite    = southSprite;
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
		draw_sprite_ext(_sprite, _self.image_index, _self.x, _self.y, 1, 1, 0, c_white, 1);
	}
}


