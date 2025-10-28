///@function DealDamage(_target, _damage, _source, [_knockback_force])
/// @param {instance} _target The instance taking damage
/// @param {real} _damage Amount of damage
/// @param {instance} _source Who/what caused the damage
/// @param {real} [_knockback_force] Optional knockback multiplier (default 1.0)
function DealDamage(_target, _damage, _source, _knockback_force = 1.0) {
    // Validate target
    if (!instance_exists(_target) || _damage <= 0) return 0;
    
    // Check if target is already dead
    if (variable_instance_exists(_target, "marked_for_death") && _target.marked_for_death) {
        return 0;
    }
    
    // Store damage info BEFORE applying
    if (variable_instance_exists(_target, "last_hit_by")) {
        _target.last_hit_by = _source;
    }
    if (variable_instance_exists(_target, "last_damage_taken")) {
        _target.last_damage_taken = _damage;
    }
    
    // Track total damage for scoring
    if (variable_instance_exists(_target, "total_damage_taken")) {
        _target.total_damage_taken += _damage;
    }
    
    // ==========================================
    // HANDLE PLAYER DAMAGE
    // ==========================================
    if (_target.object_index == obj_player) {
        // Check invincibility
        if (_target.invincibility.active) {
            return _target.hp; // No damage during invincibility
        }
        
        // Apply damage through component
        _target.damage_sys.TakeDamage(_damage, _source);
        _target.hp = _target.damage_sys.hp;
        
        // Activate invincibility
        _target.invincibility.Activate();
        
        // UI feedback
        if (variable_instance_exists(_target, "timers")) {
            _target.timers.Set("hp_bar", 120);
        }
        
        // Visual feedback
        _target.hitFlashTimer = 10;
        
        // Damage number
        spawn_damage_number(_target.x, _target.y - 32, _damage, c_red, false);
        
        return _target.hp;
    }
    
    // ==========================================
    // HANDLE ENEMY DAMAGE
    // ==========================================
    else if (object_is_ancestor(_target.object_index, obj_enemy) || 
             _target.object_index == obj_enemy ||
             object_is_ancestor(_target.object_index, obj_miniboss_parent)) {
        
        // Apply damage through component if exists, otherwise legacy
        if (variable_instance_exists(_target, "damage_sys")) {
            _target.damage_sys.TakeDamage(_damage, _source);
            _target.hp = _target.damage_sys.hp;
        } else {
            _target.hp -= _damage;
        }
        
        // Visual feedback
        _target.hitFlashTimer = 10;
        
        // Apply knockback
        if (instance_exists(_source) && _knockback_force > 0) {
            var kb_dir = point_direction(_source.x, _source.y, _target.x, _target.y);
            var kb_power = 8 * _knockback_force;
            
            if (variable_instance_exists(_target, "knockbackX")) {
                _target.knockbackX = lengthdir_x(kb_power, kb_dir);
                _target.knockbackY = lengthdir_y(kb_power, kb_dir);
                _target.knockbackCooldown = 10;
            }
        }
        
        // Damage number
        spawn_damage_number(_target.x, _target.y - 32, _damage, c_white, false);
        var _ret = _target.damage_sys.hp;
				
        // Check death
        if (_target.damage_sys.hp <= 0 && !_target.marked_for_death) {
            _target.marked_for_death = true;
            
            // Score the kill
            if (instance_exists(obj_game_manager) && !_target.scored_this_death) {
                _target.scored_this_death = true;
                obj_game_manager.score_manager.RegisterKill(
                    _target, 
                    _target.total_damage_taken,
                    _source
                );
            }
            
            // Death effects
            HandleEnemyDeath(_target, _source);
        }
        
        return _ret;
    }
    
    // ==========================================
    // HANDLE OTHER OBJECTS
    // ==========================================
    else {
        // Generic damage for destructibles, etc
        if (variable_instance_exists(_target, "hp")) {
            _target.hp -= _damage;
            
            // Visual feedback if supported
            if (variable_instance_exists(_target, "hitFlashTimer")) {
                _target.hitFlashTimer = 10;
            }
            
            // Check destruction
            if (_target.hp <= 0) {
                instance_destroy(_target);
            }
            
            return _target.hp;
        }
    }
    
    return 0;
}

// ==========================================
// HEALING FUNCTION
// ==========================================
/// @function HealTarget(_target, _amount, _show_number)
function HealTarget(_target, _amount, _show_number = true) {
    if (!instance_exists(_target)) return;
    
    var actual_heal = 0;
    
    // Use component system if available
    if (variable_instance_exists(_target, "damage_sys")) {
        var old_hp = _target.damage_sys.hp;
        _target.damage_sys.Heal(_amount);
        actual_heal = _target.damage_sys.hp - old_hp;
        _target.hp = _target.damage_sys.hp;
    }
    // Legacy healing
    else if (variable_instance_exists(_target, "hp") && variable_instance_exists(_target, "maxHp")) {
        var old_hp = _target.hp;
        _target.hp = min(_target.hp + _amount, _target.maxHp);
        actual_heal = _target.hp - old_hp;
    }
    
    // Visual feedback
    if (_show_number && actual_heal > 0) {
        spawn_damage_number(_target.x, _target.y - 32, actual_heal, c_lime, false);
    }
    
    return actual_heal;
}

// ==========================================
// DAMAGE WITH SPECIAL EFFECTS
// ==========================================
/// @function DealElementalDamage(_target, _damage, _source, _element)
function DealElementalDamage(_target, _damage, _source, _element) {
    // Deal base damage first
    var remaining_hp = DealDamage(_target, _damage, _source);
    
    // Apply elemental effect
    if (instance_exists(_target) && remaining_hp > 0) {
        switch(_element) {
            case ELEMENT.FIRE:
                // Apply burn DOT
                if (variable_instance_exists(_target, "status")) {
                    _target.status.ApplyBurn(3, _damage * 0.2); // 3 seconds, 20% damage/sec
                }
                break;
                
            case ELEMENT.ICE:
                // Apply slow
                if (variable_instance_exists(_target, "moveSpeed")) {
                    _target.moveSpeed *= 0.5;
                    // Set timer to restore speed
                    if (variable_instance_exists(_target, "slowTimer")) {
                        _target.slowTimer = 120; // 2 seconds
                    }
                }
                break;
                
            case ELEMENT.LIGHTNING:
                // Chain to nearby enemies
                var chain_range = 128;
                var chain_damage = _damage * 0.5;
                with (obj_enemy) {
                    if (id != _target && distance_to_object(_target) < chain_range) {
                        DealDamage(id, chain_damage, _source, 0.5);
                        // Lightning effect
                        var bolt = instance_create_depth(
                            _target.x, _target.y, -1000, obj_lightning
                        );
                        bolt.target_x = x;
                        bolt.target_y = y;
                        break; // Only chain once
                    }
                }
                break;
                
            case ELEMENT.POISON:
                // Apply poison DOT
                if (variable_instance_exists(_target, "status")) {
                    _target.status.ApplyPoison(5, _damage * 0.15); // 5 seconds, 15% damage/sec
                }
                break;
        }
    }
    
    return remaining_hp;
}

// ==========================================
// SPECIAL DAMAGE TYPES
// ==========================================
/// @function DealExplosiveDamage(_x, _y, _radius, _damage, _source)
function DealExplosiveDamage(_x, _y, _radius, _damage, _source) {
    var hits = 0;
    
    // Damage all enemies in radius
    with (obj_enemy) {
        var dist = point_distance(x, y, _x, _y);
        if (dist <= _radius) {
            // Damage falloff based on distance
            var falloff = 1 - (dist / _radius) * 0.5; // 50% falloff at edge
            var final_damage = round(_damage * falloff);
            
            DealDamage(id, final_damage, _source, 1.5); // Extra knockback
            hits++;
        }
    }
    
    // Also check player
    if (instance_exists(obj_player)) {
        var dist = point_distance(obj_player.x, obj_player.y, _x, _y);
        if (dist <= _radius * 0.75) { // Player takes less radius
            var falloff = 1 - (dist / (_radius * 0.75)) * 0.5;
            var final_damage = round(_damage * falloff * 0.5); // Player takes half
            
            DealDamage(obj_player, final_damage, _source, 1.0);
        }
    }
    
    return hits;
}

// ==========================================
// DEATH HANDLING
// ==========================================
/// @function HandleEnemyDeath(_enemy, _killer)
function HandleEnemyDeath(_enemy, _killer) {
    // Spawn pickups
    if (random(1) < 0.3) { // 30% chance
        instance_create_depth(_enemy.x, _enemy.y, 0, obj_exp);
    }
    if (random(1) < 0.1) { // 10% chance
        instance_create_depth(_enemy.x, _enemy.y, 0, obj_coin);
    }
    
    // Death particles
    repeat(10) {
        var p = instance_create_depth(_enemy.x, _enemy.y, -100, obj_particle);
        p.direction = random(360);
        p.speed = random_range(2, 5);
        p.image_blend = c_red;
    }
    
    // Trigger any on-kill modifiers
    if (instance_exists(_killer) && _killer == obj_player) {
        var kill_event = {
            victim: _enemy,
            damage: _enemy.total_damage_taken,
            overkill: (_enemy.total_damage_taken > _enemy.maxHp * 2)
        };
        
        TriggerModifiers(_killer, MOD_TRIGGER.ON_KILL, kill_event);
    }
    
    // Destroy the enemy
    instance_destroy(_enemy);
}