/// @description scr_pit_avoidance.gml
/// Create this as a new script file

/// @function CheckPitAhead(_x, _y, _direction, _distance)
/// @param {real} _x Current x position
/// @param {real} _y Current y position  
/// @param {real} _direction Direction to check
/// @param {real} _distance How far ahead to check
/// @returns {bool} True if pit detected ahead
function CheckPitAhead(_x, _y, _direction, _distance) {
    // Get tilemap reference
    var tile_layer_id = layer_get_id("Tiles_2");
    if (tile_layer_id == -1) return false;
    
    var tilemap_id = layer_tilemap_get_id(tile_layer_id);
    if (tilemap_id == -1) return false;
    
    // Check ahead
    var check_x = _x + lengthdir_x(_distance, _direction);
    var check_y = _y + lengthdir_y(_distance, _direction);
    
    var tile = tilemap_get_at_pixel(tilemap_id, check_x, check_y);
    
    // 405 = floor, anything else = pit
    return (tile != 405);
}

/// @function IsSafeTile(_tilemap_id, _x, _y, _buffer_radius)
/// @param {Id.Tilemap} _tilemap_id Tilemap to check
/// @param {real} _x X position to check
/// @param {real} _y Y position to check
/// @param {real} _buffer_radius Safety buffer (default 8)
/// @returns {bool} True if tile and buffer zone are safe
function IsSafeTile(_tilemap_id, _x, _y, _buffer_radius = 8) {
    // Check center
    var center_tile = tilemap_get_at_pixel(_tilemap_id, _x, _y);
    if (center_tile != 405) return false;
    
    // Check buffer points around position (4 cardinal directions)
    var check_points = [
        [_x + _buffer_radius, _y],  // Right
        [_x - _buffer_radius, _y],  // Left
        [_x, _y + _buffer_radius],  // Down
        [_x, _y - _buffer_radius]   // Up
    ];
    
    for (var i = 0; i < array_length(check_points); i++) {
        var tile = tilemap_get_at_pixel(_tilemap_id, check_points[i][0], check_points[i][1]);
        if (tile != 405) return false; // Buffer touches pit
    }
    
    return true; // All checks passed
}

/// @function FindSafeDashDirection(_start_x, _start_y, _target_x, _target_y, _check_distance, _buffer)
/// @param {real} _start_x Starting x position
/// @param {real} _start_y Starting y position
/// @param {real} _target_x Target x position
/// @param {real} _target_y Target y position
/// @param {real} _check_distance How far to check for pits
/// @param {real} _buffer Safety buffer radius (default 8)
/// @returns {struct} {safe: bool, target_x: real, target_y: real, direction: real}
function FindSafeDashDirection(_start_x, _start_y, _target_x, _target_y, _check_distance, _buffer = 8) {
    var original_dir = point_direction(_start_x, _start_y, _target_x, _target_y);
    var original_dist = point_distance(_start_x, _start_y, _target_x, _target_y);
    
    // Get tilemap
    var tile_layer_id = layer_get_id("Tiles_2");
    if (tile_layer_id == -1) {
        return {
            safe: true,
            target_x: _target_x,
            target_y: _target_y,
            direction: original_dir
        };
    }
    
    var tilemap_id = layer_tilemap_get_id(tile_layer_id);
    if (tilemap_id == -1) {
        return {
            safe: true,
            target_x: _target_x,
            target_y: _target_y,
            direction: original_dir
        };
    }
    
    // Check if original target is safe (with buffer)
    if (IsSafeTile(tilemap_id, _target_x, _target_y, _buffer)) {
        return {
            safe: true,
            target_x: _target_x,
            target_y: _target_y,
            direction: original_dir
        };
    }
    
    // Original target unsafe - find alternative
    var try_angles = [0, 30, -30, 60, -60, 90, -90, 120, -120, 150, -150, 180];
    
    for (var i = 0; i < array_length(try_angles); i++) {
        var test_dir = original_dir + try_angles[i];
        var test_x = _start_x + lengthdir_x(original_dist, test_dir);
        var test_y = _start_y + lengthdir_y(original_dist, test_dir);
        
        if (IsSafeTile(tilemap_id, test_x, test_y, _buffer)) {
            return {
                safe: true,
                target_x: test_x,
                target_y: test_y,
                direction: test_dir
            };
        }
    }
    
    // No safe direction found
    return {
        safe: false,
        target_x: _start_x,
        target_y: _start_y,
        direction: original_dir
    };
}

/// @function GetPitAvoidanceDirection(_x, _y, _desired_dir, _speed, _check_distance, _buffer)
/// @param {real} _x Current x
/// @param {real} _y Current y
/// @param {real} _desired_dir Desired movement direction
/// @param {real} _speed Movement speed
/// @param {real} _check_distance Lookahead distance
/// @param {real} _buffer Safety buffer radius (default 8)
/// @returns {struct} {moveX: real, moveY: real, blocked: bool}
function GetPitAvoidanceDirection(_x, _y, _desired_dir, _speed, _check_distance, _buffer = 8) {
    // Get tilemap
    var tile_layer_id = layer_get_id("Tiles_2");
    if (tile_layer_id == -1) {
        return {
            moveX: lengthdir_x(_speed, _desired_dir),
            moveY: lengthdir_y(_speed, _desired_dir),
            blocked: false
        };
    }
    
    var tilemap_id = layer_tilemap_get_id(tile_layer_id);
    if (tilemap_id == -1) {
        return {
            moveX: lengthdir_x(_speed, _desired_dir),
            moveY: lengthdir_y(_speed, _desired_dir),
            blocked: false
        };
    }
    
    // Check ahead with buffer
    var check_x = _x + lengthdir_x(_check_distance, _desired_dir);
    var check_y = _y + lengthdir_y(_check_distance, _desired_dir);
    
    // Safe to move in desired direction
    if (IsSafeTile(tilemap_id, check_x, check_y, _buffer)) {
        return {
            moveX: lengthdir_x(_speed, _desired_dir),
            moveY: lengthdir_y(_speed, _desired_dir),
            blocked: false
        };
    }
    
    // Pit ahead - find alternative
    var try_angles = [45, -45, 90, -90, 135, -135];
    
    for (var i = 0; i < array_length(try_angles); i++) {
        var test_dir = _desired_dir + try_angles[i];
        var test_x = _x + lengthdir_x(_check_distance, test_dir);
        var test_y = _y + lengthdir_y(_check_distance, test_dir);
        
        if (IsSafeTile(tilemap_id, test_x, test_y, _buffer)) {
            return {
                moveX: lengthdir_x(_speed, test_dir),
                moveY: lengthdir_y(_speed, test_dir),
                blocked: false
            };
        }
    }
    
    // No safe path
    return {
        moveX: 0,
        moveY: 0,
        blocked: true
    };
}