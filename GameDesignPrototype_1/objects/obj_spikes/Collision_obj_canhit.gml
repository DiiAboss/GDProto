/// @description
// For physics objects that can be knocked into spikes
var hitObject = instance_place(x, y, obj_canhit);
if (hitObject != noone && hitObject.isMoving) {
    var impactSpeed = point_distance(0, 0, hitObject.velocityX, hitObject.velocityY);
    
    if (impactSpeed > 2) {
        // Stop the object
        hitObject.velocityX = 0;
        hitObject.velocityY = 0;
        
        // Destroy if it's destructible (like crates)
        if (hitObject.weight < 30) {
            // instance_create_depth(hitObject.x, hitObject.y, hitObject.depth, obj_crate_break);
            instance_destroy(hitObject);
            
            // Effect
            shake = 2;
            // audio_play_sound(snd_crate_break, 1, false);
        } else {
            // Heavy objects just stop
            hitObject.x = hitObject.xprevious;
            hitObject.y = hitObject.yprevious;
        }
    }
}