/// @description Event Helper Functions - FIXED VERSION

/// @function CreateAttackEvent(_entity, _attack_type, _direction, _projectile)
function CreateAttackEvent(_entity, _attack_type, _direction, _projectile = noone) {
    // SAFETY: Ensure attack_type exists with fallback
    if (_attack_type == undefined || _attack_type == noone) {
        _attack_type = AttackType.UNKNOWN;
    }
    
    // SAFETY: Ensure entity has required fields
    var entity_attack = 0;
    if (variable_instance_exists(_entity, "attack")) {
        entity_attack = _entity.attack;
    }
    
    var entity_weapon = noone;
    if (variable_instance_exists(_entity, "weaponCurrent")) {
        entity_weapon = _entity.weaponCurrent;
    }
    
    return {
        trigger: MOD_TRIGGER.ON_ATTACK,
        trigger_type: MOD_TRIGGER.ON_ATTACK,
        
        attack_type: _attack_type,                 // GUARANTEED to exist
        attack_direction: _direction,
        
        // Position (multiple field names for compatibility)
        attack_position_x: _entity.x,
        attack_position_y: _entity.y,
        x: _entity.x,
        y: _entity.y,
        
		element: ELEMENT.PHYSICAL,
        damage: entity_attack,
        projectile: _projectile,
        weapon: entity_weapon,
        projectile_count_bonus: 0,
        combo_hit: 0,
        attack_success: true
    };
}

/// @function CreateHitEvent(_entity, _target, _damage, _attack_type)
function CreateHitEvent(_entity, _target, _damage, _attack_type = AttackType.MELEE) {
    return {
        trigger: MOD_TRIGGER.ON_HIT,              // FIXED: was trigger_type
        trigger_type: MOD_TRIGGER.ON_HIT,         // Keep for backwards compatibility
        hit_success: true,                         // ADDED - critical for modifiers
        
        // Target info
        target: _target,
        target_x: _target.x,
        target_y: _target.y,
        
        // Damage
        damage: _damage,
        
        // Position (multiple field names for compatibility)
        attack_position_x: _entity.x,
        attack_position_y: _entity.y,
        hit_x: _entity.x,                         // ADDED
        hit_y: _entity.y,                         // ADDED
        x: _entity.x,                             // ADDED
        y: _entity.y,                             // ADDED
        
        // Attack info
        attack_type: _attack_type,
        attack_direction: point_direction(_entity.x, _entity.y, _target.x, _target.y),
        
        // Weapon info
        projectile: noone,
        weapon: _entity.weaponCurrent,
        projectile_count_bonus: 0,
        
        // Owner
        owner: _entity                            // ADDED
    };
}

/// @function CreateKillEvent(_entity, _enemy_x, _enemy_y, _damage, _kill_source, _enemy_type)
function CreateKillEvent(_entity, _enemy_x, _enemy_y, _damage, _kill_source = "direct", _enemy_type = obj_enemy) {
    return {
        trigger: MOD_TRIGGER.ON_KILL,             // FIXED: was trigger_type
        trigger_type: MOD_TRIGGER.ON_KILL,        // Keep for backwards compatibility
        
        // Enemy position
        enemy_x: _enemy_x,
        enemy_y: _enemy_y,
        x: _enemy_x,                              // ADDED
        y: _enemy_y,                              // ADDED
        
        // Kill info
        damage: _damage,
        kill_source: _kill_source,                // Now accepts parameter
        enemy_type: _enemy_type,                  // Now accepts parameter (was using undefined object_index)
        
        // Attack info
        attack_type: AttackType.UNKNOWN,
        projectile_count_bonus: 0,
        
        // Owner
        owner: _entity                            // ADDED
    };
}

/// @function CreateProjectileHitEvent(_owner, _projectile, _target, _damage)
/// @description Special helper for projectile hits with ALL required fields
function CreateProjectileHitEvent(_owner, _projectile, _target, _damage) {
    return {
        trigger: MOD_TRIGGER.ON_HIT,
        trigger_type: MOD_TRIGGER.ON_HIT,
        hit_success: true,
        
        // Target
        target: _target,
        target_x: _target.x,
        target_y: _target.y,
        
        // Damage
        damage: _damage,
        
        // Position (ALL variations for maximum compatibility)
        attack_position_x: _projectile.x,
        attack_position_y: _projectile.y,
        hit_x: _projectile.x,
        hit_y: _projectile.y,
        x: _projectile.x,
        y: _projectile.y,
        
        // Projectile
        projectile: _projectile,
        projectile_type: _projectile.object_index,
        
        // Owner
        owner: _owner,
        
        // Weapon
        weapon: variable_instance_exists(_owner, "weaponCurrent") ? _owner.weaponCurrent : noone,
        
        // Direction
        attack_direction: point_direction(_projectile.x, _projectile.y, _target.x, _target.y),
        attack_type: AttackType.RANGED
    };
}