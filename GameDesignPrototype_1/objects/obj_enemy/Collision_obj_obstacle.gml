/// @description
var pushDir = point_direction(other.x, other.y, x, y);
    var pushForce = 0.5;
    
    var pushX = lengthdir_x(pushForce, pushDir);
    var pushY = lengthdir_y(pushForce, pushDir);
    
    // Check walls before pushing THIS enemy
    if (!place_meeting(x + pushX, y + pushY, obj_wall)) {
        // No collision, apply full push
        x += pushX;
        y += pushY;
    } else {
        // Check each axis separately for sliding
        if (!place_meeting(x + pushX, y, obj_wall)) {
            x += pushX; // Slide horizontally
        }
        if (!place_meeting(x, y + pushY, obj_wall)) {
            y += pushY; // Slide vertically
        }
    }
    
    // Also push the OTHER enemy away (with wall check)
    var otherPushX = -pushX * 0.5;
    var otherPushY = -pushY * 0.5;
    
    if (!place_meeting(other.x + otherPushX, other.y + otherPushY, obj_wall)) {
        // No collision, apply full push
        other.x += otherPushX;
        other.y += otherPushY;
    } else {
        // Check each axis separately for sliding
        if (!place_meeting(other.x + otherPushX, other.y, obj_wall)) {
            other.x += otherPushX; // Slide horizontally
        }
        if (!place_meeting(other.x, other.y + otherPushY, obj_wall)) {
            other.y += otherPushY; // Slide vertically
        }
    }