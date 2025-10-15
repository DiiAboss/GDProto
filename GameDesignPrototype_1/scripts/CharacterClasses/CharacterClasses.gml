/// @desc Character class behaviors and updates

// ==========================================
// WARRIOR CLASS
// ==========================================
function WarriorClass(_stats_component, _damage_component) constructor {
    stats = _stats_component;
    damage = _damage_component;
    rage_damage_bonus = 0;
    armor = 0;
    
    static Update = function() {
        var health_percent = damage.GetHealthPercent();
        rage_damage_bonus = (health_percent < 0.5) ? (0.5 - health_percent) * 2 : 0;
    }
    
    static ApplyModifiers = function(_base_attack) {
        return _base_attack * (1 + rage_damage_bonus);
    }
    
    static Draw = function(_x, _y) {
        // Draw rage indicator when active
        if (rage_damage_bonus > 0) {
            draw_set_color(c_red);
            draw_set_alpha(0.3 + rage_damage_bonus * 0.3);
            draw_circle(_x, _y, 20, false);
            draw_set_alpha(1);
        }
    }
    
    static GetDisplayInfo = function() {
        return {
            name: "Warrior",
            special: "Rage: +" + string(floor(rage_damage_bonus * 100)) + "% DMG",
            armor: armor
        };
    }
}

// ==========================================
// HOLY MAGE CLASS
// ==========================================
function HolyMageClass(_stats_component, _damage_component, _class_stats) constructor {
    stats = _stats_component;
    damage = _damage_component;
    class_stats = _class_stats;
    
    mana = _class_stats.mana_max;
    mana_max = _class_stats.mana_max;
    on_blessed_ground = false;
    last_heal_time = 0;
    
    static Update = function() {
        // Mana regeneration
        if (mana < mana_max) {
            mana += class_stats.mana_regen * game_speed_delta();
            mana = min(mana, mana_max);
        }
        
        // Blessed ground healing
        if (on_blessed_ground) {
            var heal_amount = (class_stats.blessed_heal / room_speed) * game_speed_delta();
            damage.Heal(heal_amount);
            last_heal_time = current_time;
        }
    }
    
    static ApplyModifiers = function(_base_attack) {
        // Mana-scaled damage bonus
        var mana_percent = mana / mana_max;
        return _base_attack * (1 + mana_percent * 0.2); // Up to 20% bonus at full mana
    }
    
    static Draw = function(_x, _y) {
        // Draw mana bar above HP
        var bar_w = 30;
        var bar_h = 3;
        var bar_x = _x - bar_w / 2;
        var bar_y = _y - 35;
        
        // Background
        draw_set_color(c_dkgray);
        draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, false);
        
        // Mana fill
        var mana_width = (mana / mana_max) * bar_w;
        draw_set_color(c_aqua);
        draw_rectangle(bar_x, bar_y, bar_x + mana_width, bar_y + bar_h, false);
        
        // Blessed ground indicator
        if (on_blessed_ground) {
            draw_set_color(c_yellow);
            draw_set_alpha(0.3 + sin(current_time * 0.01) * 0.2);
            draw_circle(_x, _y, 25, false);
            draw_set_alpha(1);
        }
    }
    
    static GetDisplayInfo = function() {
        return {
            name: "Holy Mage",
            special: "Mana: " + string(floor(mana)) + "/" + string(mana_max),
            blessed: on_blessed_ground
        };
    }
    
    static CastSpell = function(_cost) {
        if (mana >= _cost) {
            mana -= _cost;
            return true;
        }
        return false;
    }
}

// ==========================================
// VAMPIRE CLASS
// ==========================================
function VampireClass(_stats_component, _damage_component, _class_stats) constructor {
    stats = _stats_component;
    damage = _damage_component;
    class_stats = _class_stats;
    
    lifesteal = _class_stats.lifesteal;
    blood_frenzy_timer = 0;
    blood_frenzy_duration = 180; // 3 seconds
    is_burning = false;
    burn_timer = 0;
    burn_damage_tick = 0;
    
    static Update = function() {
        // Blood frenzy speed boost
        if (blood_frenzy_timer > 0) {
            blood_frenzy_timer = timer_tick(blood_frenzy_timer);
            stats.temp_speed_mult = class_stats.blood_frenzy_bonus;
        } else {
            stats.temp_speed_mult = 1.0;
        }
        
        // Burning effect
        if (is_burning && burn_timer > 0) {
            burn_timer = timer_tick(burn_timer);
            
            // Damage tick every 30 frames (0.5 sec)
            burn_damage_tick += game_speed_delta();
            if (burn_damage_tick >= 30) {
                burn_damage_tick = 0;
                damage.TakeDamage(2, noone);
            }
            
            // Set nearby enemies on fire
            with (obj_enemy) {
                if (point_distance(x, y, other.x, other.y) < 50) {
                    on_fire = true;
                    fire_timer = 120;
                }
            }
            
            // Burning ends
            if (burn_timer <= 0) {
                is_burning = false;
                burn_damage_tick = 0;
            }
        }
    }
    
    static ApplyModifiers = function(_base_attack) {
        // Bonus damage during blood frenzy
        if (blood_frenzy_timer > 0) {
            return _base_attack * 1.3;
        }
        return _base_attack;
    }
    
    static OnKill = function() {
        // Heal on kill via lifesteal
        var heal_amount = damage.max_hp * lifesteal;
        damage.Heal(heal_amount);
        
        // Trigger blood frenzy
        blood_frenzy_timer = blood_frenzy_duration;
    }
    
    static Draw = function(_x, _y) {
        // Blood frenzy indicator
        if (blood_frenzy_timer > 0) {
            var frenzy_alpha = 0.3 + (blood_frenzy_timer / blood_frenzy_duration) * 0.4;
            draw_set_color(c_red);
            draw_set_alpha(frenzy_alpha);
            draw_circle(_x, _y, 30, false);
            draw_set_alpha(1);
        }
        
        // Burning effect
        if (is_burning) {
            var flame_offset = sin(current_time * 0.02) * 5;
            draw_set_color(c_orange);
            draw_set_alpha(0.6);
            draw_circle(_x, _y - flame_offset, 10, false);
            draw_set_color(c_yellow);
            draw_circle(_x, _y - flame_offset - 5, 5, false);
            draw_set_alpha(1);
        }
    }
    
    static GetDisplayInfo = function() {
        return {
            name: "Vampire",
            special: blood_frenzy_timer > 0 ? "Blood Frenzy!" : "Lifesteal: " + string(floor(lifesteal * 100)) + "%",
            burning: is_burning
        };
    }
}

// ==========================================
// FACTORY FUNCTION
// ==========================================
/// @func CreateCharacterClass(_type, _stats, _damage, _class_stats)
function CreateCharacterClass(_type, _stats, _damage, _class_stats) {
    switch (_type) {
        case CharacterClass.WARRIOR:
            return new WarriorClass(_stats, _damage);
            
        case CharacterClass.HOLY_MAGE:
            return new HolyMageClass(_stats, _damage, _class_stats);
            
        case CharacterClass.VAMPIRE:
            return new VampireClass(_stats, _damage, _class_stats);
            
        default:
            return new WarriorClass(_stats, _damage); // Default fallback
    }
}