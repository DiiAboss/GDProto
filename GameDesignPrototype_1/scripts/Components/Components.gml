/// @desc Reusable components for player, enemies, and entities


// KNOCKBACK COMPONENT - Enhanced version with all features
function KnockbackComponent(_friction = 0.85, _threshold = 0.1) constructor {
    // Core velocities
    x_velocity = 0;
    y_velocity = 0;
    
    // Physics settings
    friction = _friction;
    threshold = _threshold;
    bounce_dampening = 1.1;
    min_bounce_speed = 0;
    
    // Cooldowns
    cooldown = 0;
    cooldown_max = 10;
    wall_bounce_cooldown = 0;
    wall_hit_cooldown = 0;
    
    // Wall impact damage
    min_impact_speed = 3;
    impact_damage_multiplier = 0.1;
    max_impact_damage = 999;
    
    // State tracking
    is_active = false;
    _power = 0;
    has_transferred = false;
    has_hit_wall = false;
    last_bounce_dir = 0;
    
    /// @func Apply(_direction, _force)
    static Apply = function(_direction, _force) {
        x_velocity = lengthdir_x(_force, _direction);
        y_velocity = lengthdir_y(_force, _direction);
        cooldown = cooldown_max;
        is_active = true;
        has_transferred = false;
        has_hit_wall = false;
    }
    
    /// @func AddForce(_x, _y)
    static AddForce = function(_x, _y) {
        x_velocity += _x;
        y_velocity += _y;
        is_active = true;
    }
    
    /// @func Update(_entity, _delta = 1)
    static Update = function(_entity, _delta = 1) {
        // Update cooldowns
        if (cooldown > 0) cooldown = timer_tick(cooldown);
        if (wall_bounce_cooldown > 0) wall_bounce_cooldown = timer_tick(wall_bounce_cooldown);
        if (wall_hit_cooldown > 0) wall_hit_cooldown = timer_tick(wall_hit_cooldown);
        
        // Check if knockback is active
        if (abs(x_velocity) > threshold || abs(y_velocity) > threshold) {
            is_active = true;
            _power = point_distance(0, 0, x_velocity, y_velocity);
            
            with (_entity) {
                var nextX = x + other.x_velocity * _delta;
                var nextY = y + other.y_velocity * _delta;
                
                var hit_wall = false;
                var impact_speed = 0;
                
                // Horizontal collision check
                if (place_meeting(nextX, y, obj_obstacle) && other.wall_bounce_cooldown == 0) {
                    hit_wall = true;
                    impact_speed = abs(other.x_velocity);
                    
                    // Wall damage check
                    if (impact_speed > other.min_impact_speed && other.wall_hit_cooldown == 0) {
                        var impact_damage = clamp(
                            round(impact_speed * other.impact_damage_multiplier), 
                            0, 
                            other.max_impact_damage
                        );
                        
                        // Apply damage if entity has damage system
                        if (variable_instance_exists(id, "damage_sys")) {
                            damage_sys.TakeDamage(impact_damage, obj_wall);
                        }
                        
                        other.wall_hit_cooldown = 30;
                        
                        // Camera shake on hard impacts
                        if (impact_speed > 8 && instance_exists(obj_player)) {
                            with (obj_player) {
                                if (variable_instance_exists(id, "camera")) {
                                    camera.add_shake(impact_speed * 0.3);
                                }
                            }
                        }
                    }
                    
                    // Bounce
                    other.x_velocity = (abs(other.x_velocity) > other.min_bounce_speed) 
                        ? -other.x_velocity * other.bounce_dampening 
                        : 0;
                } else if (!place_meeting(nextX, y, obj_obstacle)) {
                    x = nextX;
                }
                
                // Vertical collision check
                if (place_meeting(x, nextY, obj_obstacle) && other.wall_bounce_cooldown == 0) {
                    hit_wall = true;
                    impact_speed = abs(other.y_velocity);
                    
                    // Wall damage check
                    if (impact_speed > other.min_impact_speed && other.wall_hit_cooldown == 0) {
                        var impact_damage = clamp(
                            round(impact_speed * other.impact_damage_multiplier), 
                            0, 
                            other.max_impact_damage
                        );
                        

                            damage_sys.TakeDamage(impact_damage, obj_wall);
                        
                        
                        other.wall_hit_cooldown = 30;
                        
                        if (impact_speed > 8 && instance_exists(obj_player)) {
                            with (obj_player) {

                                    camera.add_shake(impact_speed * 0.3);
                                
                            }
                        }
                    }
                    
                    // Bounce
                    other.y_velocity = (abs(other.y_velocity) > other.min_bounce_speed) 
                        ? -other.y_velocity * other.bounce_dampening 
                        : 0;
                } else if (!place_meeting(x, nextY, obj_obstacle)) {
                    y = nextY;
                }
                
                // Handle wall hit state
                if (hit_wall) {
                    other.wall_bounce_cooldown = 2;
                    other.last_bounce_dir = point_direction(0, 0, other.x_velocity, other.y_velocity);
                    other.has_hit_wall = true;
                }
            }
            
            // Apply friction
            x_velocity *= power(friction, _delta);
            y_velocity *= power(friction, _delta);
            
            // Stop if below threshold
            if (abs(x_velocity) < threshold) x_velocity = 0;
            if (abs(y_velocity) < threshold) y_velocity = 0;
            
        } else {
            // Reset state when stopped
            x_velocity = 0;
            y_velocity = 0;
            is_active = false;
            _power = 0;
            has_transferred = false;
            has_hit_wall = false;
            if (wall_hit_cooldown > 0) wall_hit_cooldown = 0;
        }
    }
    
    /// @func IsActive()
    static IsActive = function() {
        return is_active;
    }
    
    /// @func GetSpeed()
    static GetSpeed = function() {
        return _power;
    }
    
    /// @func GetVelocity()
    static GetVelocity = function() {
        return { x: x_velocity, y: y_velocity };
    }
    
    /// @func Stop()
    static Stop = function() {
        x_velocity = 0;
        y_velocity = 0;
        is_active = false;
        _power = 0;
    }
    
    /// @func SetFriction(_friction)
    static SetFriction = function(_friction) {
        friction = _friction;
    }
}

// INVINCIBILITY COMPONENT
function InvincibilityComponent(_duration = 60, _flash_speed = 4) constructor {
    active = false;
    timer = 0;
    duration = _duration;
    flash_speed = _flash_speed;
    
    /// @func Activate()
    static Activate = function() {
        active = true;
        timer = duration;
    }
    
    /// @func Update()
    static Update = function() {
        if (timer > 0) {
            timer = timer_tick(timer);
            if (timer <= 0) {
                active = false;
            }
        }
    }
    
    /// @func ShouldFlash()
    static ShouldFlash = function() {
        return active && (timer div flash_speed) mod 2 == 0;
    }
}

// DAMAGE COMPONENT
function DamageComponent(_owner, _max_hp) constructor {
    owner = _owner;   // instance this belongs to
    hp = _max_hp;
    max_hp = _max_hp;
    last_damage = 0;
    last_attacker = noone;
    damage_flash_timer = 0;
	hp_regen = 0;

    /// @func TakeDamage(_amount, _attacker, _element)
    static TakeDamage = function(_amount, _attacker, _element = ELEMENT.PHYSICAL) {
        var final_dmg = _amount;
		
	    with (self) {
	        // Fast: check object type once
	        var is_player = (self == obj_player);
	        
	        // Players have invincibility
	        if (is_player && invincibility.active) {
	            return hp; // Still invincible
	        }
	        	
	
	        // Apply damage
			//self.total_damage_taken += _attacker;
	        
	        // Player-specific
	        if (is_player) {
	            invincibility.Activate();
	            timers.Set("hp_bar", 120);
	        }
	        
	        // Everyone can flash
	        hitFlashTimer = 10;
	        
	        // Track damage
	        last_hit_by = _attacker;
	        took_damage = _attacker;
	    }
		
		
        // Apply elemental resistance if the owner has stats
        if (variable_instance_exists(owner, "stats")) {
            var resist_mult = 1.0;

            switch(_element) {
                case ELEMENT.FIRE:      resist_mult -= owner.stats.resist_fire; break;
                case ELEMENT.ICE:       resist_mult -= owner.stats.resist_ice; break;
                case ELEMENT.LIGHTNING: resist_mult -= owner.stats.resist_lightning; break;
                case ELEMENT.POISON:    resist_mult -= owner.stats.resist_poison; break;
            }

            resist_mult = clamp(resist_mult, 0.1, 2.0);
            final_dmg *= resist_mult;
        }
		
		spawn_damage_number(owner.x, owner.y, final_dmg);
        hp -= final_dmg;
        last_damage = final_dmg;
        last_attacker = _attacker;
        damage_flash_timer = 10;
		

        return hp;
    }

    /// @func Heal(_amount)
    static Heal = function(_amount) {
        hp = min(hp + _amount, max_hp);
    }

    static IsDead = function() {
        return hp <= 0;
    }

    static GetHealthPercent = function() {
        return hp / max_hp;
    }

    static Update = function() {
        if (damage_flash_timer > 0)
            damage_flash_timer = timer_tick(damage_flash_timer);
    }
}

// TIMER COMPONENT
function TimerComponent() constructor {
    timers = {}; // Struct to hold named timers
    
    /// @func Set(_name, _duration)
    static Set = function(_name, _duration) {
        timers[$ _name] = _duration;
    }
    
    /// @func Get(_name)
    static Get = function(_name) {
        return timers[$ _name] ?? 0;
    }
    
    /// @func Update()
    static Update = function() {
        var names = variable_struct_get_names(timers);
        for (var i = 0; i < array_length(names); i++) {
            var name = names[i];
            var value = timers[$ name];
            if (value > 0) {
                timers[$ name] = timer_tick(value);
            }
        }
    }
    
    /// @func IsActive(_name)
    static IsActive = function(_name) {
        return (timers[$ _name] ?? 0) > 0;
    }
    
    /// @func IsFinished(_name)
    static IsFinished = function(_name) {
        return (timers[$ _name] ?? 0) <= 0;
    }
}

