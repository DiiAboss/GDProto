/// @desc obj_projectile Step Event - Fixed

//direction = myDir;
if (projectileType == PROJECTILE_TYPE.NORMAL)
{
    if (life > 0)
    {
        life -= 1;
    }
    else
    {
        instance_destroy();
    }
    
    
    if (active)
    {
        if (place_meeting(x, y, obj_enemy))
        {
            var enemy = instance_nearest(x, y, obj_enemy);
            
            // Skip dead enemies
            if (variable_instance_exists(enemy, "marked_for_death") && enemy.marked_for_death) {
                active = false;
                instance_destroy();
                exit;
            }
            
            // Apply knockback using custom knockback variables
            if (enemy.knockbackCooldown <= 0) {
                var knockbackDir = point_direction(x, y, enemy.x, enemy.y);
                var knockbackForce = 5; // Stronger knockback with combo
            
                // Set the enemy's knockback velocity
                enemy.knockbackX = lengthdir_x(knockbackForce, knockbackDir);
                enemy.knockbackY = lengthdir_y(knockbackForce, knockbackDir);
            
                // Set cooldown to prevent knockback stacking
                enemy.knockbackCooldown = enemy.knockbackCooldownMax;
            }
            
            active = false;
        }
    }
    else
    {
        instance_destroy();
    }        
} 

if (projectileType == PROJECTILE_TYPE.LOB) {
    lobStep = lobShot(self, 0.02, direction, xStart, yStart, targetDistance);
    
    if (lobStep >= 1) {
        instance_create_depth(x, y, depth, obj_knockback);
        instance_destroy();
    }
    
    // Use lengthdir functions which handle degrees and GML's coordinate system correctly
    targetX = xStart + lengthdir_x(targetDistance, direction);
    targetY = yStart + lengthdir_y(targetDistance, direction);
    groundShadowY = yStart;
    
    // Calculate arc for next frame (for rotation)
    var arcHeight = targetDistance * 0.25;
    var next_progress = min(1, lobStep + 0.02);
    
    var nextX = lerp(xStart, targetX, next_progress);
    var nextY = lerp(yStart, targetY, next_progress) - sin(pi * next_progress) * arcHeight * 2;
    
    drawDir = point_direction(x, y, nextX, nextY);
    depth = -(bbox_bottom + 32 + (point_distance(x, y, x, yStart)));
}

// ==========================================
// COLLISION DETECTION & DAMAGE
// ==========================================
if (place_meeting(x, y, obj_enemy)) {
    var enemy = instance_place(x, y, obj_enemy);
    
    if (enemy != noone) {
        // IMPORTANT: Skip if enemy is already dead
        if (variable_instance_exists(enemy, "marked_for_death") && enemy.marked_for_death) {
            // Don't hit dead enemies, but don't destroy projectile yet (might pierce)
            if (!piercing) {
                instance_destroy();
            }
            exit;
        }
        
        // Track who hit the enemy
        enemy.last_hit_by = owner;
        enemy.last_damage_taken = damage;
        
        // Deal damage
        takeDamage(enemy, damage, owner);
        
        // Mark if from corpse explosion (prevents chain reactions)
        if (variable_instance_exists(id, "from_corpse_explosion") && from_corpse_explosion) {
            enemy.killed_by_modifier = "corpse_explosion";
        }
        
        // ==========================================
        // TRIGGER ON_HIT MODIFIERS - Use Helper
        // ==========================================
        var should_trigger = variable_instance_exists(id, "can_trigger_modifiers") ? can_trigger_modifiers : true;
        
        if (owner != noone && instance_exists(owner) && should_trigger) {
            // Use the projectile hit event helper
            var hit_event = CreateProjectileHitEvent(owner, id, enemy, damage);
            
            TriggerModifiers(owner, MOD_TRIGGER.ON_HIT, hit_event);
        }
        
        // ==========================================
        // CHECK FOR KILL - But don't manually trigger
        // Let the enemy's death system handle it properly
        // ==========================================
        if (enemy.hp <= 0 && !enemy.marked_for_death) {
            // The enemy will die in its next step
            // The controller will handle death and trigger ON_KILL modifiers
            // with the proper kill_source from killed_by_modifier flag
        }
        
        // Destroy projectile if not piercing
        if (!piercing) {
            instance_destroy();
        }
    }
}

if (destroy)
{
    instance_destroy();
}