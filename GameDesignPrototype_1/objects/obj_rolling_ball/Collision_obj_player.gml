var hitPlayer = instance_place(x, y, obj_player);
if (hitPlayer != noone) {
    var canHit = true;
    for (var i = 0; i < ds_list_size(hitList); i++) {
        if (hitList[| i][0] == hitPlayer.id) {
            canHit = false;
            break;
        }
    }
    
    if (canHit) {
        // Deal damage (scaled by level)
        hitPlayer.hp -= damage;
        		// Visual feedback - spawn damage number
        spawn_damage_number(x, y - 16, damage, currentColor, false);
        // Apply knockback (scaled by level)
        var kbDir = point_direction(x, y, hitPlayer.x, hitPlayer.y);
        hitPlayer.knockbackX = lengthdir_x(knockbackForce, kbDir);
        hitPlayer.knockbackY = lengthdir_y(knockbackForce, kbDir);
        
        // Bounce off
        myDir = point_direction(hitPlayer.x, hitPlayer.y, x, y);
        
        // MAINTAIN LEVEL - Reset decay timer but don't gain level
        levelDecayTimer = 0;
        
        // Add to hit list
        ds_list_add(hitList, [hitPlayer.id, hitCooldown]);
        
        // Visual feedback
        hitFlashTimer = 5;
    }
}
