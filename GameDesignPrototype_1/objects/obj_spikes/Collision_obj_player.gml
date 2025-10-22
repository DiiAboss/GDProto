// Don't hit if player is invincible
if (other.invincibility.active) exit;

// Check if player is in hit list
var canHit = true;
for (var i = 0; i < ds_list_size(hitList); i++) {
    if (hitList[| i][0] == other.id) {
        canHit = false;
        break;
    }
}

if (canHit) {
    // Get impact speed from knockback component
    var impactSpeed = other.knockback.GetSpeed();
    
    // Calculate damage based on velocity
    var damage = baseDamage + (impactSpeed * velocityDamageMultiplier);
    damage = clamp(damage, baseDamage, maxDamage);
    damage = round(damage);
    
    // Apply damage
    //takeDamage(other, damage, id);
    other.damage_sys.TakeDamage(damage, self)
    // Stop knockback and bounce player away
    other.knockback.x_velocity = 0;
    other.knockback.y_velocity = 0;
    
    var bounceDir = point_direction(x, y, other.x, other.y);
    other.x += lengthdir_x(5, bounceDir);
    other.y += lengthdir_y(5, bounceDir);
    
    // Add to spike's hit list
    ds_list_add(hitList, [other.id, hitCooldown * 2]);
    
    // Visual effects
    bloodTimer = 20;
    shake = 3;
    
    // Sound effect
    if (!playedSound) {
        // audio_play_sound(snd_spike_hit, 1, false);
        playedSound = true;
    }
}