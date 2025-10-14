// obj_player Create Event - PRESERVING ALL FUNCTIONALITY

#region Character Class Setup
character_class = CharacterClass.WARRIOR;  
class_stats = GetCharacterStats(character_class);





// Apply class stats WITHOUT breaking existing systems
hp_max = class_stats.hp_max;
hp = hp_max;
maxHp = hp_max;  // Keep for compatibility

// Use mySpeed instead of speed to avoid conflicts
mySpeed = class_stats.move_speed;
base_speed = class_stats.move_speed;

attack_base = class_stats.attack_base;
attack = attack_base;
base_attack = attack_base;  // Keep for compatibility

magic_power = class_stats.magic_power;

// Class-specific variables
switch (character_class) {
    case CharacterClass.WARRIOR:
        rage_damage_bonus = 0;
        armor = class_stats.armor;
        break;
        
    case CharacterClass.HOLY_MAGE:
        mana = class_stats.mana_max;
        mana_max = class_stats.mana_max;
        on_blessed_ground = false;
        break;
        
    case CharacterClass.VAMPIRE:
        lifesteal = class_stats.lifesteal;
        blood_frenzy_timer = 0;
        is_burning = false;
        burn_timer = 0;
        break;
}
#endregion

#region Existing Systems (UNCHANGED)
// All your existing variables
myDir = 0;
aimDirection = 0;
knockbackPower = 5;
base_knockback = 5;
attackSpeed = 1;
attack_counter = 0;
projectile_count_bonus = 0;

// Input
mouseDirection = 0;
mouseDistance = 0;
controllerType = CONTROL_TYPE.KBM;

// Movement
input = new Input();
movement = new PlayerMovement(self, mySpeed);
spriteHandler = new SpriteHandler(spr_char_left, spr_char_right, spr_char_up, spr_char_left);
currentSprite = spr_char_left;
mySprite = spr_char_right;
img_xscale = 1;
image_speed = 0.2;

// Dash system
isDashing = false;
canDash = true;
dashTimer = 0;
maxDashTimer = 8;
dashSpeed = 6;

// Knockback system
knockbackX = 0;
knockbackY = 0;
knockbackFriction = 0.85;
knockbackThreshold = 0.1;
knockbackPower = 0;
knockbackCooldown = 0;
knockbackCooldownMax = 10;

// Charge weapon system (KEPT)
charge_amount = 0;
charge_rate = 0.02;
max_charge_time = 100;
is_charging = false;

// Combo system (KEPT)
button_combo_array = [];
button_combo_timer = 30;
attack_buffer = [];
attack_buffer_max = 3;
attack_buffer_timeout = 40;
combo_state = ComboState.IDLE;
combo_window = 0;
combo_window_max = 45;
attack_cooldown = 0;
can_cancel = false;

// Initialize combo data
combo_data = array_create(6);
// [Keep all your existing combo_data initialization]

// Weapon system
weapon_slots = class_stats.weapon_slots;
weapons = array_create(weapon_slots, noone);
current_weapon_index = 0;
weaponCurrent = global.WeaponStruct.Sword;
melee_weapon = noone;

// Cannon system (KEPT)
cannonCooldown = 0;
cannonCooldownMax = 30;
isCannonBalling = false;
cannonDamage = 20;
#endregion

#region Modifier System
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
#endregion

depth = -y;


experience_points = 0;
exp_to_next_level = 10;

gold = 0;
player_level = 0;

global.pause_game = false;

// Camera system
camera = new Camera(id);
camera.set_bounds(280, 88, 1064, 648); // Your play area bounds

// Mini HP bar
hp_bar_visible_timer = 0;
hp_bar_show_duration = 120; // 2 seconds at 60fps