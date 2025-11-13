/// @description
/// @function HandleEnemyHit(_enemy)
function HandleEnemyHit(_enemy) {
    // Check if we've already hit this enemy (for piercing)
    if (piercing && ds_list_find_index(pierced_enemies, _enemy) != -1) {
        return;  // Already hit this enemy
    }
    
    // Apply damage with pierce falloff
    var actual_damage = damage;
    if (piercing) {
        actual_damage *= power(pierce_damage_falloff, ds_list_size(pierced_enemies));
        ds_list_add(pierced_enemies, _enemy);
    }
    
    // Deal damage
    _enemy.damage_sys.TakeDamage(actual_damage, owner);
    _enemy.last_hit_by = owner;
    hits_landed++;
    
    // Apply knockback
    if (_enemy.knockbackCooldown <= 0) {
        var kb_dir = point_direction(x, y, _enemy.x, _enemy.y);
        var kb_force = 5 * (1 + screen_bounces * 0.2);  // Bonus for pinball
        _enemy.knockbackX = lengthdir_x(kb_force, kb_dir);
        _enemy.knockbackY = lengthdir_y(kb_force, kb_dir);
        _enemy.knockbackCooldown = _enemy.knockbackCooldownMax;
    }
    
    // Trigger modifiers
    if (owner != noone && instance_exists(owner) && can_trigger_modifiers) {
        var hit_event = CreateProjectileHitEvent(owner, id, _enemy, actual_damage);
        TriggerModifiers(owner, MOD_TRIGGER.ON_HIT, hit_event);
    }
    
    // Check for special behaviors
    if (explode_on_hit) {
        CreateExplosion();
    }
    
    if (can_split && split_on_hit) {
        CreateSplitProjectiles();
    }
    
    if (causes_slowdown) {
        CreateSlowdownZone();
    }
    
    // Destroy if not piercing
    if (!piercing || pierce_count <= 0) {
        HandleProjectileDeath();
    } else {
        pierce_count--;
    }
}

/// @function HandleProjectileDeath()
function HandleProjectileDeath() {
    // Special death behaviors
    if (explode_on_death) {
        CreateExplosion();
    }
    
    if (can_split && split_on_death) {
        CreateSplitProjectiles();
    }
    
    // Clean up
    if (ds_exists(pierced_enemies, ds_type_list)) {
        ds_list_destroy(pierced_enemies);
    }
    if (ds_exists(chained_enemies, ds_type_list)) {
        ds_list_destroy(chained_enemies);
    }
    
    instance_destroy();
}

/// @function CreateExplosion()
function CreateExplosion() {
    var expl = instance_create_depth(x, y, depth - 10, obj_explosion);
    expl.radius = explosion_radius;
    expl.damage = explosion_damage;
    expl.knockback_force = explosion_knockback;
    expl.owner = owner;
    
    if (create_shrapnel) {
        for (var i = 0; i < shrapnel_count; i++) {
            var shrap = instance_create_depth(x, y, depth, object_index);
            shrap.direction = (360 / shrapnel_count) * i;
            shrap.speed = 8;
            shrap.damage = damage * 0.3;
            shrap.life = 30;
            shrap.can_trigger_modifiers = false;
        }
    }
}

/// @function CreateSplitProjectiles()  
function CreateSplitProjectiles() {
    for (var i = 0; i < split_count; i++) {
        var split = instance_create_depth(x, y, depth, object_index);
        var angle_offset = (i - split_count/2) * split_angle_spread;
        split.direction = direction + angle_offset;
        split.speed = speed * 0.8;
        split.damage = damage * split_damage_mult;
        split.life = life * 0.5;
        split.can_split = false;  // Prevent infinite splitting
        split.can_trigger_modifiers = false;
    }
}