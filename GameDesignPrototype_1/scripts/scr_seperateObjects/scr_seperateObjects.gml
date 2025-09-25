function separate_objects(obj1, obj2, force = 1) {
    var dist = point_distance(obj1.x, obj1.y, obj2.x, obj2.y);
    var minDist = (obj1.sprite_width + obj2.sprite_width) / 2;
    
    if (dist < minDist && dist > 0) {
        var overlap = minDist - dist;
        var pushDir = point_direction(obj1.x, obj1.y, obj2.x, obj2.y);
        
        // Push both objects apart
        var push1X = lengthdir_x(overlap * 0.5 * force, pushDir + 180);
        var push1Y = lengthdir_y(overlap * 0.5 * force, pushDir + 180);
        var push2X = lengthdir_x(overlap * 0.5 * force, pushDir);
        var push2Y = lengthdir_y(overlap * 0.5 * force, pushDir);
        
        // Move obj1 if not blocked
        if (!place_meeting(obj1.x + push1X, obj1.y + push1Y, obj_wall)) {
            obj1.x += push1X;
            obj1.y += push1Y;
        }
        
        // Move obj2 if not blocked
        if (!place_meeting(obj2.x + push2X, obj2.y + push2Y, obj_wall)) {
            obj2.x += push2X;
            obj2.y += push2Y;
        }
        
        return true; // Separated
    }
    return false; // No overlap
}