/// scr_camera_system.gml

function Camera(_target) constructor {
    // Target tracking
    target = _target;
    follow_x = _target.x;
    follow_y = _target.y;
    
    // Camera dimensions
    base_width = 640;
    base_height = 360;
    current_width = base_width;
    current_height = base_height;
    
    // Smoothing
    follow_speed = 0.15;
    zoom_speed = 0.08;
    
    // Zoom
    target_zoom = 1.0;
    current_zoom = 1.0;
    
    // Shake
    shake_magnitude = 0;
    shake_decay = 0.92;
    shake_x = 0;
    shake_y = 0;
    
    // Panning
    is_panning = false;
    pan_target_x = 0;
    pan_target_y = 0;
    pan_speed = 0.08;
    pan_callback = noone;
    
    // Lock mode
    is_locked = false;
    lock_x = 0;
    lock_y = 0;
    
    // Bounds (optional room clamping)
    use_bounds = false;
    bound_left = 0;
    bound_top = 0;
    bound_right = room_width;
    bound_bottom = room_height;
    
    // GameMaker camera reference
    gm_camera = view_camera[0];
    
    /// @method update()
    static update = function() {
        // Determine target position
        var target_x = follow_x;
        var target_y = follow_y;
        
        if (is_locked) {
            target_x = lock_x;
            target_y = lock_y;
        } else if (is_panning) {
            target_x = pan_target_x;
            target_y = pan_target_y;
            
            // Check if pan is complete
            var dist = point_distance(follow_x, follow_y, pan_target_x, pan_target_y);
            if (dist < 5) {
                is_panning = false;
                if (is_callable(pan_callback)) {
                    pan_callback();
                }
            }
        } else if (instance_exists(target)) {
            target_x = target.x;
            target_y = target.y;
        }
        
        // Smooth follow
        follow_x = lerp(follow_x, target_x, is_panning ? pan_speed : follow_speed);
        follow_y = lerp(follow_y, target_y, is_panning ? pan_speed : follow_speed);
        
        // Update zoom
        current_zoom = lerp(current_zoom, target_zoom, zoom_speed);
        current_width = base_width / current_zoom;
        current_height = base_height / current_zoom;
        
        // Apply shake
        if (shake_magnitude > 0) {
            shake_x = random_range(-shake_magnitude, shake_magnitude);
            shake_y = random_range(-shake_magnitude, shake_magnitude);
            shake_magnitude *= shake_decay;
            
            if (shake_magnitude < 0.1) {
                shake_magnitude = 0;
                shake_x = 0;
                shake_y = 0;
            }
        }
        
        // Calculate final camera position
        var cam_x = follow_x - current_width * 0.5 + shake_x;
        var cam_y = follow_y - current_height * 0.5 + shake_y;
        
        // Apply bounds if enabled
        if (use_bounds) {
            cam_x = clamp(cam_x, bound_left, bound_right - current_width);
            cam_y = clamp(cam_y, bound_top, bound_bottom - current_height);
        }
        
        // Update GameMaker camera
        camera_set_view_pos(gm_camera, cam_x, cam_y);
        camera_set_view_size(gm_camera, current_width, current_height);
    }
    
    /// @method add_shake(magnitude)
    static add_shake = function(_magnitude) {
        shake_magnitude = max(shake_magnitude, _magnitude);
    }
    
    /// @method set_zoom(zoom_level)
    static set_zoom = function(_zoom) {
        target_zoom = clamp(_zoom, 0.5, 3.0);
    }
    
    /// @method pan_to(x, y, callback)
    static pan_to = function(_x, _y, _callback = noone) {
        is_panning = true;
        pan_target_x = _x;
        pan_target_y = _y;
        pan_callback = _callback;
    }
    
    /// @method lock_at(x, y)
    static lock_at = function(_x, _y) {
        is_locked = true;
        lock_x = _x;
        lock_y = _y;
    }
    
    /// @method unlock()
    static unlock = function() {
        is_locked = false;
    }
    
    /// @method set_bounds(left, top, right, bottom)
    static set_bounds = function(_left, _top, _right, _bottom) {
        use_bounds = true;
        bound_left = _left;
        bound_top = _top;
        bound_right = _right;
        bound_bottom = _bottom;
    }
    
    /// @method remove_bounds()
    static remove_bounds = function() {
        use_bounds = false;
    }
}