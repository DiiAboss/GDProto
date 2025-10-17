/// @desc Player Create Event - Fully Component-based

// ==========================================
// CHARACTER CLASS SETUP
// ==========================================
character_class = CharacterClass.WARRIOR;
class_stats = GetCharacterStats(character_class);

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
damage_sys = new DamageComponent(stats.hp_max);
timers = new TimerComponent();

// ==========================================
// CHARACTER CLASS COMPONENT
// ==========================================
class_component = CreateCharacterClass(character_class, stats, damage_sys, class_stats);

// Legacy compatibility (remove once fully refactored)
attack = stats.attack;
base_attack = stats.base_attack;
hp = damage_sys.hp;
hp_max = damage_sys.max_hp;
maxHp = damage_sys.max_hp;
mySpeed = stats.speed;
base_speed = stats.base_speed;

mySprite = spr_char_right; // ADD THIS LINE - needed for after images

// ==========================================
// INPUT & MOVEMENT
// ==========================================
mouseDirection = 0;
mouseDistance = 0;
controllerType = CONTROL_TYPE.KBM;

input = new Input();
movement = new PlayerMovement(self, stats.speed);
spriteHandler = new SpriteHandler(spr_char_left, spr_char_right, spr_char_up, spr_char_left);
currentSprite = spr_char_left;
image_speed = 0.2;

// ==========================================
// WEAPON SYSTEM
// ==========================================
weapon_slots = class_stats.weapon_slots;
weapons = array_create(weapon_slots, noone);
current_weapon_index = 0;
weaponCurrent = global.WeaponStruct.HolyWater;
melee_weapon = noone;
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
gold = 0;

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

// Test modifiers
AddModifier(id, "TripleRhythmFire");
AddModifier(id, "SpreadFire");

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