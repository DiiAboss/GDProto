var hitEnemy = instance_place(x, y, obj_enemy);
if (hitEnemy != noone) {
    var canHit = true;
    for (var i = 0; i < ds_list_size(hitList); i++) {
        if (hitList[| i][0] == hitEnemy.id) {
            canHit = false;
            break;
        }
    }
    
    if (canHit) {
        // Deal damage (scaled by level)
        //takeDamage(hitEnemy, damage, self);
        hitEnemy.damage_sys.TakeDamage(damage, self);  
        // Apply knockback (scaled by level)
        var kbDir = point_direction(x, y, hitEnemy.x, hitEnemy.y);
        hitEnemy.knockbackX = lengthdir_x(knockbackForce, kbDir);
        hitEnemy.knockbackY = lengthdir_y(knockbackForce, kbDir);
        hitEnemy.knockbackCooldown = 10;
        
        // Bounce off
        myDir = point_direction(hitEnemy.x, hitEnemy.y, x, y);
        
        // MAINTAIN LEVEL - Reset decay timer but don't gain level
        levelDecayTimer = 0;
        
        // Add to hit list
        ds_list_add(hitList, [hitEnemy.id, hitCooldown]);
        
        // Visual feedback
        hitFlashTimer = 5;
        
        // Credit kill to last sword hitter
        if (hitEnemy.hp <= 0 && lastHitBy != noone) {
            AwardStylePoints("ENVIRONMENTAL", 10, 1);
        }
    }
}