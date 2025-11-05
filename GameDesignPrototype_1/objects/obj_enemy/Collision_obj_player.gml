/// obj_enemy - Collision with obj_player (SIMPLIFIED)
if (global.gameSpeed <= 0) exit;
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

// Handle cannonball momentum transfer
if (hitPlayer.isCannonBalling) {
    var playerSpeed = point_distance(0, 0, hitPlayer.knockbackX, hitPlayer.knockbackY);
    if (playerSpeed > 10) {
        var transferDir = point_direction(hitPlayer.x, hitPlayer.y, x, y);
        var transferForce = playerSpeed * 0.75;
        
        knockbackX = lengthdir_x(transferForce, transferDir);
        knockbackY = lengthdir_y(transferForce, transferDir);
        knockbackCooldown = 10;
        
        var impactDamage = round(playerSpeed * 2);
        //takeDamage(self, impactDamage, hitPlayer);
		hitPlayer.damage_sys.TakeDamage(impactDamage, self)
        
        hitPlayer.knockbackX *= 0.5;
        hitPlayer.knockbackY *= 0.5;
    }
}