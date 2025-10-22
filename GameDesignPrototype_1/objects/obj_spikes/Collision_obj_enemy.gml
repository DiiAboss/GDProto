/// @description
var enemy = instance_place(x, y, obj_enemy);
if (enemy != noone) {
    // Check if this enemy is already in hit list
    var canHit = true;
    for (var i = 0; i < ds_list_size(hitList); i++) {
        if (hitList[| i][0] == enemy) {
            canHit = false;
            break;
        }
    }
    
    if (canHit) && enemy != noone {
        // Calculate impact velocity for bonus damage
        var impactSpeed = point_distance(0, 0, enemy.knockbackX, enemy.knockbackY);
        
        // Calculate damage based on impact speed
        var damage = baseDamage + (impactSpeed * velocityDamageMultiplier);
        damage = min(damage, maxDamage);
        damage = round(damage);
        
        // Deal damage
        //takeDamage(enemy, damage);
        enemy.damage_sys.TakeDamage(damage, self)
        // STOP the enemy completely (key spike behavior)
        enemy.knockbackX = 0;
        enemy.knockbackY = 0;
        enemy.x = xprevious; // Push back slightly
        enemy.y = yprevious;
        
        // Add to hit list
        ds_list_add(hitList, [enemy, hitCooldown]);
        
        // Visual feedback
        bloodTimer = 20;
        shake = min(impactSpeed * 0.5, 5);
        
        
    }
}