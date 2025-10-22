/// @description obj_chain_whip - STEP EVENT
event_inherited(); // Run parent melee logic

// Calculate dynamic range based on swing progress
if (swinging) {
    // Wave pattern: extends to max at swing midpoint
    // 0.0 -> 0.5 = extend from idle to max
    // 0.5 -> 1.0 = retract from max to idle
    var extend_progress = 1 - abs((swingProgress * 2) - 1); // 0->1->0 curve
    current_range = lerp(idle_range, max_extended_range, extend_progress);
} else {
    current_range = idle_range;
}

// Override parent collision detection with tip-based multi-hit
if (swinging && swingProgress > 0.05 && swingProgress < 0.95) {
    var baseAngle = owner.mouseDirection;
    var weaponAngle = baseAngle + currentAngleOffset;
    var tipX = owner.x + lengthdir_x(current_range, weaponAngle);
    var tipY = owner.y + lengthdir_y(current_range, weaponAngle);
    
    // Check all enemies in tip radius
    var hit_radius = 12;
    var hits = ds_list_create();
    collision_circle_list(tipX, tipY, hit_radius, obj_enemy, false, true, hits, false);
    
    for (var i = 0; i < ds_list_size(hits); i++) {
        var enemy = hits[| i];
        
        // Check if already hit this swing
        if (ds_list_find_index(hitList, enemy) == -1) {
            ds_list_add(hitList, enemy);
            enemy.lastKnockedBy = owner;
            
            // Combo tracking
            if (comboTimer > 0) {
                comboCount++;
            } else {
                comboCount = 1;
            }
            
            // Damage with combo bonus
            var baseDamage = attack;
            var finalDamage = baseDamage * (1 + comboCount * 0.25);
            
            //takeDamage(enemy, finalDamage, owner);
            enemy.damage_sys.TakeDamage(finalDamage, owner);
            // Knockback
            var kb_dir = point_direction(owner.x, owner.y, enemy.x, enemy.y);
            enemy.knockback.Apply(kb_dir, knockbackForce);
            
            // Visual effects
            enemy.hitFlashTimer = 5;
            enemy.shake = 3;
            
            // Particles
            repeat(8) {
                var p = instance_create_depth(enemy.x, enemy.y, depth - 1, obj_particle);
                p.direction = kb_dir + random_range(-30, 30);
                p.speed = random_range(2, 6);
            }
        }
    }
    
    ds_list_destroy(hits);
}