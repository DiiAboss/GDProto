/// @description Bomb Object - Create Event
event_inherited(); // Get obj_can_carry properties

// Override carry properties
sprite_index = spr_bomb;
can_be_carried = true;
weight = 1.2; // Slightly heavy

// Bomb-specific properties
is_armed = false;
timer = 0;
timer_max = 4.0 * 60; // 4 seconds at 60 FPS
timer_warning_threshold = 2.0 * 60; // Warning at 2 seconds
timer_critical_threshold = 1.0 * 60; // Critical at 1 second

// Visual feedback
pulse_scale = 1.0;
pulse_speed = 0;
flash_timer = 0;
flash_speed = 0;
bomb_color = c_white;

// Explosion properties
explosion_radius = 80;
explosion_damage = 150;
explosion_knockback = 12;
explosion_damage_falloff = 0.25; // Damage at edge = 25% of center

// Indestructible flag
can_be_knocked = false; // Override parent - can't be hit by melee UNTIL armed

// Armed by thrower (for tracking who threw it)
armed_by = noone;

/// @method ArmBomb(_activator)
/// @desc Start the countdown timer
ArmBomb = function(_activator) {
    if (is_armed) return; // Already armed
    
    is_armed = true;
    timer = timer_max;
    armed_by = _activator;
    can_be_knocked = true; // NOW it can be hit by melee
    
    // Visual feedback
    shake = 2;
    
    // Particles on activation
    repeat(8) {
        var p = instance_create_depth(x, y, depth - 1, obj_particle);
        p.direction = random(360);
        p.speed = random_range(1, 3);
        p.image_blend = c_red;
    }
    
    show_debug_message("BOMB ARMED by " + (armed_by != noone ? object_get_name(armed_by.object_index) : "unknown"));
}

/// @method Explode()
/// @desc Trigger the explosion
Explode = function() {
    // Camera shake
    if (instance_exists(obj_player)) {
        obj_player.camera.add_shake(8);
    }
    
    // Explosion particles
    repeat(30) {
        var p = instance_create_depth(x, y, depth - 1, obj_particle);
        p.direction = random(360);
        p.speed = random_range(4, 12);
        p.image_blend = choose(c_red, c_orange, c_yellow);
        p.image_alpha = random_range(0.7, 1.0);
    }
    
    // Damage all entities in radius
    DamageInRadius();
    
    // Create explosion visual effect (optional smoke/flash)
    var explosion = instance_create_depth(x, y, depth - 10, obj_particle);
    explosion.sprite_index = spr_bomb; // Could be explosion sprite
    explosion.image_xscale = 3;
    explosion.image_yscale = 3;
    explosion.image_blend = c_red;
    explosion.image_alpha = 0.8;
    
    show_debug_message("BOMB EXPLODED at " + string(x) + ", " + string(y));
    
    // Destroy bomb
    instance_destroy();
}

/// @method DamageInRadius()
/// @desc Apply damage to all entities within explosion radius
DamageInRadius = function() {
    // Damage enemies
    with (obj_enemy) {
        var dist = point_distance(x, y, other.x, other.y);
        
        if (dist <= other.explosion_radius) {
            // Calculate falloff
            var falloff = 1.0 - (dist / other.explosion_radius);
            falloff = max(falloff, other.explosion_damage_falloff);
            
            var final_damage = other.explosion_damage * falloff;
            var final_kb = other.explosion_knockback * falloff;
            
            // Apply damage using takeDamage system
            takeDamage(self, final_damage, other);
            
            // Apply knockback
            var kb_dir = point_direction(other.x, other.y, x, y);
            knockback.Apply(kb_dir, final_kb);
            
            // Visual feedback
            hitFlashTimer = 10;
            shake = 5 * falloff;
            
            show_debug_message("Enemy hit by explosion for " + string(final_damage) + " damage");
        }
    }
    
    // Damage player
    if (instance_exists(obj_player)) {
        var dist = point_distance(obj_player.x, obj_player.y, x, y);
        
        if (dist <= explosion_radius) {
            var falloff = 1.0 - (dist / explosion_radius);
            falloff = max(falloff, explosion_damage_falloff);
            
            var final_damage = explosion_damage * falloff;
            var final_kb = explosion_knockback * falloff;
            
            // Apply damage
            obj_player.damage_sys.TakeDamage(final_damage, self);
            
            // Apply knockback
            var kb_dir = point_direction(x, y, obj_player.x, obj_player.y);
            obj_player.knockback.Apply(kb_dir, final_kb);
            
            show_debug_message("Player hit by explosion for " + string(final_damage) + " damage");
        }
    }
    
    // Optionally damage other carriable objects
    with (obj_can_carry) {
        if (id == other.id) continue; // Skip self
        
        var dist = point_distance(x, y, other.x, other.y);
        
        if (dist <= other.explosion_radius) {
            var kb_dir = point_direction(other.x, other.y, x, y);
            var falloff = 1.0 - (dist / other.explosion_radius);
            var final_kb = other.explosion_knockback * falloff;
            
            knockback.Apply(kb_dir, final_kb);
            
            // Arm other bombs in radius (chain reaction!)
            if (object_index == obj_bomb && !is_armed) {
                ArmBomb(other.armed_by);
            }
        }
    }
}

/// @method OnChargedThrow(_thrower, _direction, _charge)
/// @desc Called when thrown with primary attack
OnChargedThrow = function(_thrower, _direction, _charge) {
    ArmBomb(_thrower);
}

/// @method OnLobThrow(_thrower, _direction)
/// @desc Called when lobbed with secondary attack - arm on landing
OnLobThrow = function(_thrower, _direction) {
    // Store who threw it, but don't arm yet
    armed_by = _thrower;
}

/// @method OnMeleeHit(_attacker, _weapon, _direction)
/// @desc Called when hit by melee weapon (from obj_can_carry collision)
OnMeleeHit = function(_attacker, _weapon, _direction) {
    if (!is_armed) {
        ArmBomb(_attacker);
    }
}