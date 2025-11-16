if (is_falling) {
    exit;
}

/// obj_enemy - Collision with obj_player (SIMPLIFIED)
var hitPlayer = instance_place(x, y, obj_player);
if (hitPlayer == noone) exit;

// Only handle physical separation and cannon momentum transfer
var pushDir = point_direction(hitPlayer.x, hitPlayer.y, x, y);
var overlap = (sprite_width/2 + hitPlayer.sprite_width/2) - point_distance(x, y, hitPlayer.x, hitPlayer.y);

if (overlap > 0) {
    var separateX = lengthdir_x(overlap * 0.5, pushDir);
    var separateY = lengthdir_y(overlap * 0.5, pushDir);
    
    if (!place_meeting(x + separateX, y + separateY, obj_wall)) {
        x += separateX;
        y += separateY;
    }
}

if (hitPlayer.isCannonBalling) {
    var playerSpeed = knockback.GetSpeed();
    if (playerSpeed > 10) {
        var transferDir = point_direction(hitPlayer.x, hitPlayer.y, x, y);
        var transferForce = playerSpeed * 0.75;
        
        knockback.Apply(transferDir, transferForce);
        
        var impactDamage = round(playerSpeed * 2);
        DealDamage(self, impactDamage, hitPlayer);
        
        hitPlayer.knockback.AddForce(hitPlayer.knockback.x *0.5, hitPlayer.knockback.y *0.5);
    }
}