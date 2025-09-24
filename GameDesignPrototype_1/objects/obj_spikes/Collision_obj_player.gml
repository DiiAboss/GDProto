/// @description
var player = instance_place(x, y, obj_player);
if (player != noone) {
    var canHit = true;
    for (var i = 0; i < ds_list_size(hitList); i++) {
        if (hitList[| i][0] == player) {
            canHit = false;
            break;
        }
    }
    
    if (canHit) {
        var impactSpeed = point_distance(0, 0, player.knockbackX, player.knockbackY);
        var damage = baseDamage + (impactSpeed * velocityDamageMultiplier);
        damage = min(damage, maxDamage);
        damage = round(damage);
        
        // Deal damage to player
        player.hp -= damage;
        
        // Stop player knockback
        player.knockbackX = 0;
        player.knockbackY = 0;
        
        // Slight bounce back
        var bounceDir = point_direction(x, y, player.x, player.y);
        player.x += lengthdir_x(5, bounceDir);
        player.y += lengthdir_y(5, bounceDir);
        
        // Add to hit list
        ds_list_add(hitList, [player, hitCooldown * 2]); // Longer cooldown for player
        
        // Effects
        bloodTimer = 20;
        shake = 3;
        
        // Damage feedback
        if (instance_exists(obj_damage_number)) {
            spawn_damage_number(player.x, player.y - 16, damage, c_red, false);
        }
        
        // Sound
        if (!playedSound) {
            // audio_play_sound(snd_spike_impale, 1, false);
            playedSound = true;
        }
    }
}

