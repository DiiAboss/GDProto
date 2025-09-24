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
    
    if (canHit) {
        // Calculate impact velocity for bonus damage
        var impactSpeed = point_distance(0, 0, enemy.knockbackX, enemy.knockbackY);
        
        // Calculate damage based on impact speed
        var damage = baseDamage + (impactSpeed * velocityDamageMultiplier);
        damage = min(damage, maxDamage);
        damage = round(damage);
        
        // Deal damage
        enemy.hp -= damage;
        
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
        
        // Spawn damage number with special color for spike damage
        if (instance_exists(obj_damage_number)) {
            spawn_damage_number(enemy.x, enemy.y - 16, damage, c_red, impactSpeed > 10);
        }
        
        // Credit the kill to whoever knocked them in
        if (enemy.hp <= 0 && instance_exists(enemy.lastKnockedBy)) {
            // Give bonus points for spike kill
            // enemy.lastKnockedBy.score += 150; // Spike kill bonus
            
            // Special effect for spike kill
            // effect_create_above(ef_ring, x, y, 1, c_red);
        }
        
        // Sound effect (only once per frame)
        if (!playedSound) {
            // audio_play_sound(snd_spike_impale, 1, false);
            playedSound = true;
        }
        
        // Screenshake for hard impacts
        if (impactSpeed > 15) {
            // with (obj_camera) { shake = 3; }
        }
    }
}