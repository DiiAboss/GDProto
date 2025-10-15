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

// ==========================================
// DAMAGE COMPONENT
// ==========================================
function DamageComponent(_max_hp) constructor {
    hp = _max_hp;
    max_hp = _max_hp;
    last_damage = 0;
    last_attacker = noone;
    damage_flash_timer = 0;
    
    /// @func TakeDamage(_amount, _attacker)
    static TakeDamage = function(_amount, _attacker) {
        hp -= _amount;
        last_damage = _amount;
        last_attacker = _attacker;
        damage_flash_timer = 10;
        return hp;
    }
    
    /// @func Heal(_amount)
    static Heal = function(_amount) {
        hp = min(hp + _amount, max_hp);
    }
    
    /// @func IsDead()
    static IsDead = function() {
        return hp <= 0;
    }
    
    /// @func GetHealthPercent()
    static GetHealthPercent = function() {
        return hp / max_hp;
    }
    
    /// @func Update()
    static Update = function() {
        if (damage_flash_timer > 0) {
            damage_flash_timer = timer_tick(damage_flash_timer);
        }
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

// ==========================================
// STATS COMPONENT
// ==========================================
function StatsComponent(_base_attack, _base_hp, _base_speed, _base_knockback) constructor {
    // Base stats
    base_attack = _base_attack;
    base_hp = _base_hp;
    base_speed = _base_speed;
    base_knockback = _base_knockback;
    
    // Current stats (modified by modifiers/buffs)
    attack = _base_attack;
    hp_max = _base_hp;
    speed = _base_speed;
    knockback = _base_knockback;
    
    // Temporary modifiers
    temp_attack_mult = 1.0;
    temp_speed_mult = 1.0;
    
    /// @func Recalculate(_modifier_func)
    /// @param _modifier_func Optional function to apply game-wide modifiers
    static Recalculate = function(_modifier_func = undefined) {
        // Reset to base
        attack = base_attack;
        hp_max = base_hp;
        speed = base_speed;
        knockback = base_knockback;
        
        // Apply game modifier system if provided
        if (_modifier_func != undefined) {
            var modified = _modifier_func(base_attack, hp_max, base_knockback, base_speed);
            attack = modified[0];
            hp_max = modified[1];
            knockback = modified[2];
            speed = modified[3];
        }
        
        // Apply temp multipliers
        attack *= temp_attack_mult;
        speed *= temp_speed_mult;
    }
}
