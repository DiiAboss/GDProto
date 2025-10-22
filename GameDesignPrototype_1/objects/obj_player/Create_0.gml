/// @desc Player Create Event - Fully Component-based

// ==========================================
// CHARACTER CLASS SETUP
// ==========================================
character_class = CharacterClass.WARRIOR;
class_stats = GetCharacterStats(character_class);


status = new StatusEffectComponent(self);

// ==========================================
// CORE COMPONENTS
// ==========================================
stats = new StatsComponent(
    class_stats.attack_base,
    class_stats.hp_max,
    class_stats.move_speed,
    5
);

knockback = new KnockbackComponent(0.85, 0.1);
invincibility = new InvincibilityComponent(30, 4);
damage_sys = new DamageComponent(self, stats.hp_max);
timers = new TimerComponent();

// ==========================================
// CHARACTER CLASS COMPONENT
// ==========================================
class_component = CreateCharacterClass(character_class, stats, damage_sys, class_stats);

// Legacy compatibility (remove once fully refactored)
attack		 = stats.attack;
base_attack	 = stats.base_attack;
hp			 = damage_sys.hp;
hp_max		 = damage_sys.max_hp;
maxHp		 = damage_sys.max_hp;
mySpeed		 = stats.speed;
base_speed	 = stats.base_speed;



// ==========================================
// INPUT & MOVEMENT
// ==========================================
mouseDirection = 0;
mouseDistance = 0;
controllerType = CONTROL_TYPE.KBM;

input = noone;//new Input();
movement = new PlayerMovement(self, stats.speed);
spriteHandler = new SpriteHandler(spr_vh_walk_west, spr_vh_walk_east, spr_vh_walk_north, spr_vh_walk_south);
currentSprite = spr_vh_walk_west;
image_speed = 1;


// ==========================================
// WEAPON SYSTEM
// ==========================================
melee_weapon = noone;
weapon_slots = class_stats.weapon_slots;
weapons = array_create(weapon_slots, noone);
current_weapon_index = 0;

// Give starting weapon
//weapons[1] = global.WeaponStruct.Dagger; // Or whatever starting weapon
weapons[1] = undefined;
weapons[0] = global.WeaponStruct.Dagger; // Or whatever starting weapon
weaponCurrent = weapons[0];

previous_weapon_instance = weaponCurrent;


// Charge weapon
charge_amount = 0;
is_charging = false;
isCannonBalling = false;

// ==========================================
// PROGRESSION SYSTEM - INITIALIZATION
// ==========================================
experience_points = 0;
player_level = 1; // Start at level 1, not 0
gold = 999;

// Leveling formula constants (tuned for 15-30 min arcade sessions)
exp_base = 5;         // Base XP required for first level
exp_exponent = 1.05;  // Gentle exponential growth for arcade play
exp_linear = 3;       // Small linear component

// Calculate initial XP requirement
exp_to_next_level = calculate_exp_requirement(player_level);


// ==========================================
// LEVEL UP SYSTEM FUNCTIONS
// ==========================================

/// @function calculate_exp_requirement(level)
/// @description Calculate XP needed for a specific level (Vampire Survivors formula)
/// @param {real} _level The level to calculate for
function calculate_exp_requirement(_level) {
    // Vampire Survivors formula: BaseXP * (Level ^ Exponent) + (Level * Linear)
    // This creates exponential growth that gets steeper over time
    var required_exp = exp_base * power(_level, exp_exponent) + (_level * exp_linear);
    return floor(required_exp);
}

// ==========================================
// MODIFIER SYSTEM
// ==========================================
mod_list = [];
mod_cache = {
    stats: {},
    dirty: true,
    last_update: 0
};
mod_triggers = {};



// ==========================================
// COMBAT TIMING SYSTEM
// ==========================================
perfect_window_start = 0.70;
perfect_window_end = 0.90;
good_window_start = 0.50;
last_timing_quality = "ready";
timing_bonus_multiplier = 1.0;
perfect_flash_timer = 0;
timing_circle_scale = 0;
timing_circle_alpha = 0;
perfect_hits_count = 0;
good_hits_count = 0;
early_hits_count = 0;

// ==========================================
// CAMERA SYSTEM
// ==========================================
camera = new Camera(id);
camera.remove_bounds();

// ==========================================
// MISC
// ==========================================
depth = -y;
global.pause_game = false;

// Attack counter for modifier triggers
attack_counter = 0;
projectile_count_bonus = 0;


// ==========================================
// CARRYING SYSTEM
// ==========================================
is_carrying = false;
carried_object = noone;
carry_speed_multiplier = 0.8; // Slower when carrying


var test_synergy = GetWeaponSynergy(CharacterClass.HOLY_MAGE, Weapon.BaseballBat);
show_debug_message("Test synergy type: " + string(test_synergy.type));
show_debug_message("Damage mult: " + string(test_synergy.damage_mult));













// Pit system
is_falling_in_pit = false;
pit_fall_timer = 0;
pit_fall_duration = 45;
last_safe_x = x;
last_safe_y = y;
pit_respawn_invincibility = 90;
pit_grace_timer = 0; // Grace period after dash ends
pit_grace_duration = 5; // 5 frames after dash to land safely

tile_layer = "Tiles_2";
tile_layer_id = layer_get_id(tile_layer);
tilemap_id = layer_tilemap_get_id(tile_layer_id);

/// @function UpdateLastSafePosition()
UpdateLastSafePosition = function() {
    if (is_falling_in_pit) return;
    
    var tile = tilemap_get_at_pixel(tilemap_id, x, y);
    if (tile <= 446 && tile != 0) {
        last_safe_x = x;
        last_safe_y = y;
    }
}

/// @function CheckPitFall()
CheckPitFall = function() {
    if (is_falling_in_pit) return;
    
    // IMMUNITY: Don't check pit during dash or grace period
    var is_dashing = (movement.dashTimer > 0);
    
    if (is_dashing) {
        pit_grace_timer = pit_grace_duration; // Reset grace timer during dash
        return; // Immune during dash
    }
    
    // Grace period after dash
    if (pit_grace_timer > 0) {
        pit_grace_timer--;
        return; // Still immune
    }
    
    var tile = tilemap_get_at_pixel(tilemap_id, x, y);
    
    if (tile > 446 || tile == 0) {
        // In pit!
        is_falling_in_pit = true;
        pit_fall_timer = 0;
        
        if (instance_exists(camera)) {
            camera.add_shake(4);
        }
        
        show_debug_message("PLAYER FELL IN PIT!");
    }
}

/// @function ProcessPitFall()
ProcessPitFall = function() {
    if (!is_falling_in_pit) return;
    
    pit_fall_timer++;
    var fall_progress = pit_fall_timer / pit_fall_duration;
    
    // Smooth fall animation
    image_xscale = lerp(1.0, 0.1, fall_progress);
    image_yscale = lerp(1.0, 0.1, fall_progress);
    image_angle += 20 * game_speed_delta();
    image_alpha = lerp(1.0, 0.0, fall_progress);
    
    // Push depth behind tiles
    depth = lerp(-y, 300, fall_progress);
    
    // Respawn when fall complete
    if (pit_fall_timer >= pit_fall_duration) {
        RespawnFromPit();
    }
}

/// @function RespawnFromPit()
RespawnFromPit = function() {
    // Reset position
    x = last_safe_x;
    y = last_safe_y;
    
    // Reset visuals
    image_xscale = 1.0;
    image_yscale = 1.0;
    image_angle = 0;
    image_alpha = 1.0;
    depth = -y;
    
    // Reset state
    is_falling_in_pit = false;
    pit_fall_timer = 0;
    pit_grace_timer = 0;
    
    // Apply invincibility
    invincibility.Activate(pit_respawn_invincibility);
    
    // Take damage
    damage_sys.TakeDamage(20, noone);
    
    // Visual effects
    if (instance_exists(camera)) {
        camera.add_shake(6);
    }
    
    // Spawn respawn particles
    repeat(20) {
        var p = instance_create_depth(x, y, depth - 1, obj_particle);
        p.direction = random(360);
        p.speed = random_range(2, 6);
        p.image_blend = c_aqua;
    }
    
    show_debug_message("PLAYER RESPAWNED at " + string(x) + ", " + string(y));
}

SpawnWeaponPickup(x, y - 64, global.WeaponStruct.Dagger);


is_dead = false;