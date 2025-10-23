/// @desc Reusable components for player, enemies, and entities

// ==========================================
// KNOCKBACK COMPONENT
// ==========================================
function KnockbackComponent(_friction = 0.85, _threshold = 0.1) constructor {
    x_velocity = 0;
    y_velocity = 0;
    friction = _friction;
    threshold = _threshold;
    cooldown = 0;
    cooldown_max = 10;
    
    /// @func Apply(_direction, _force)
    static Apply = function(_direction, _force) {
        x_velocity = lengthdir_x(_force, _direction);
        y_velocity = lengthdir_y(_force, _direction);
        cooldown = cooldown_max;
    }
    
    /// @func Update(_entity)
    static Update = function(_entity) {
        if (cooldown > 0) {
            cooldown = timer_tick(cooldown);
        }
        
        // Apply knockback movement
        if (abs(x_velocity) > threshold || abs(y_velocity) > threshold) {
            var kb_delta = game_speed_delta();
            
            // Use 'with' to set the instance context
            with (_entity) {
                var nextX = x + other.x_velocity * kb_delta;
                var nextY = y + other.y_velocity * kb_delta;
                
                // Wall collision
                if (place_meeting(nextX, nextY, obj_wall)) {
                    if (place_meeting(nextX, y, obj_wall)) {
                        other.x_velocity = -other.x_velocity * 0.5; // Bounce with dampening
                    }
                    if (place_meeting(x, nextY, obj_wall)) {
                        other.y_velocity = -other.y_velocity * 0.5;
                    }
                } else {
                    x = nextX;
                    y = nextY;
                }
            }
            
            // Apply friction
            x_velocity *= power(friction, kb_delta);
            y_velocity *= power(friction, kb_delta);
            
            // Stop if too slow
            if (abs(x_velocity) < threshold) x_velocity = 0;
            if (abs(y_velocity) < threshold) y_velocity = 0;
        }
    }
    
    /// @func IsActive()
    static IsActive = function() {
        return abs(x_velocity) > threshold || abs(y_velocity) > threshold;
    }
    
    /// @func GetSpeed()
    static GetSpeed = function() {
        return point_distance(0, 0, x_velocity, y_velocity);
    }
}

// ==========================================
// INVINCIBILITY COMPONENT
// ==========================================
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

function DamageComponent(_owner, _max_hp) constructor {
    owner = _owner;   // instance this belongs to
    hp = _max_hp;
    max_hp = _max_hp;
    last_damage = 0;
    last_attacker = noone;
    damage_flash_timer = 0;

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


// ==========================================
// TIMER COMPONENT
// ==========================================
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

