/// @description
var canHit = false;   
var hitPlayer = instance_place(x, y, obj_player);
if (hitPlayer != noone) {
    canHit = true;   
    }
    
    if (canHit) {
        // Deal damage (scaled by level)
        hitPlayer.hp -= damage;
        
        // Apply knockback (scaled by level)
        var kbDir = point_direction(x, y, hitPlayer.x, hitPlayer.y);
        hitPlayer.knockbackX = lengthdir_x(knockbackForce, kbDir);
        hitPlayer.knockbackY = lengthdir_y(knockbackForce, kbDir);
        
        // Bounce off
        myDir = point_direction(hitPlayer.x, hitPlayer.y, x, y);
        
        // MAINTAIN LEVEL - Reset decay timer but don't gain level
        levelDecayTimer = 0;
        
        
        // Visual feedback
        hitFlashTimer = 5;
}