/// separate_objects.gml
/// ------------------------------------------------------------
/// Purpose: Minimalistic push-apart solver for two dynamic instances using a
///          circular-ish radius derived from sprite widths. Intended for soft
///          separation (no tunneling fix), e.g., crowding units.
/// How it fits:
///  - Call when two actors overlap to nudge them apart symmetrically.
///  - Uses `obj_wall` as a static blocker; respects walls per instance.
///  - Keeps math cheap: one distance check, one direction, and two half-pushes.
/// Behavior notes:
///  - Overlap test uses `sprite_width`; if sprites are non-uniform or scaled,
///    consider using collision masks or `image_xscale` adjustments upstream.
///  - If one side is blocked by a wall, only the other moves (asymmetrical push).
///  - `force` scales displacement; it is not a physics force—just a multiplier.
///  - Skips when `dist == 0` to avoid undefined direction; consider jitter
///    prevention or a random small nudge at call site if perfectly stacked.
/// ------------------------------------------------------------
function separate_objects(obj1, obj2, force = 1) {
    var dist = point_distance(obj1.x, obj1.y, obj2.x, obj2.y);
    var minDist = (obj1.sprite_width + obj2.sprite_width) / 2;
    
    if (dist < minDist && dist > 0) {
        var overlap = minDist - dist;
        var pushDir = point_direction(obj1.x, obj1.y, obj2.x, obj2.y);
        
        // Push both objects apart (split displacement equally)
        var push1X = lengthdir_x(overlap * 0.5 * force, pushDir + 180);
        var push1Y = lengthdir_y(overlap * 0.5 * force, pushDir + 180);
        var push2X = lengthdir_x(overlap * 0.5 * force, pushDir);
        var push2Y = lengthdir_y(overlap * 0.5 * force, pushDir);
        
        // Move obj1 if not blocked by walls (keeps world solidity)
        if (!place_meeting(obj1.x + push1X, obj1.y + push1Y, obj_wall)) {
            obj1.x += push1X;
            obj1.y += push1Y;
        }
        
        // Move obj2 if not blocked
        if (!place_meeting(obj2.x + push2X, obj2.y + push2Y, obj_wall)) {
            obj2.x += push2X;
            obj2.y += push2Y;
        }
        
        return true; // Separated (at least one moved)
    }
    return false; // No overlap or zero-distance case
}