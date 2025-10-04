


mySpeed = 4;
myDir = 0;
aimDirection = 0;

hp			   = 100;
maxHp	       = 100;
attack		   = 5;
knockbackPower = 5;
attackSpeed    = 1;


base_attack    = 5;
base_maxHp     = 100;
base_knockback = 5;
base_speed     = 4;

hp             = base_maxHp;
attack         = base_attack;
knockbackPower = base_knockback;
mySpeed        = base_speed;

attack_counter = 0;



mouseDirection = 0;
mouseDistance = 0;

mySprite = spr_char_right;

img_xscale = 1;

button_combo_array = [];
button_combo_timer = 30;

enum AttackType {
    LIGHT = 0,
    HEAVY = 1,
    DASH = 2
}

enum ComboState {
    IDLE = 0,
    LIGHT_1 = 1,
    LIGHT_2 = 2,
    LIGHT_3 = 3,
    HEAVY_1 = 4,
    HEAVY_FINISHER = 5
}

// ===========================================
// PLAYER CREATE EVENT
// ===========================================

// Attack Buffer System (using arrays instead of ds_list)
attack_buffer = [];
attack_buffer_max = 3;
attack_buffer_timeout = 40;

// Combo System
combo_state = ComboState.IDLE;
combo_window = 0;
combo_window_max = 45;
attack_cooldown = 0;
can_cancel = false;

// Attack Properties - using array indexed by ComboState
combo_data = array_create(6); // 6 combo states

// Light attacks
combo_data[ComboState.LIGHT_1] = {
    duration: 30,
    cancel_start: 10,
    cancel_end: 25,
    damage_mult: 1.0,
    knockback_mult: 1.0
};

combo_data[ComboState.LIGHT_2] = {
    duration: 35,
    cancel_start: 12,
    cancel_end: 28,
    damage_mult: 1.2,
    knockback_mult: 1.1
};

combo_data[ComboState.LIGHT_3] = {
    duration: 45,
    cancel_start: 15,
    cancel_end: 35,
    damage_mult: 1.5,
    knockback_mult: 1.3
};

// Heavy attacks
combo_data[ComboState.HEAVY_1] = {
    duration: 60,
    cancel_start: 20,
    cancel_end: 45,
    damage_mult: 2.0,
    knockback_mult: 2.0
};

combo_data[ComboState.HEAVY_FINISHER] = {
    duration: 80,
    cancel_start: -1, // No cancel window
    cancel_end: -1,
    damage_mult: 3.0,
    knockback_mult: 2.5
};

// Combo transition table - [current_state][input_type] = next_state or -1 if invalid
combo_transitions = [
    // IDLE state
    [ComboState.LIGHT_1, ComboState.HEAVY_1, -1], // L->Light1, H->Heavy1, D->invalid
    
    // LIGHT_1 state  
    [ComboState.LIGHT_2, ComboState.HEAVY_FINISHER, ComboState.IDLE], // L->Light2, H->HeavyFinisher, D->Idle
    
    // LIGHT_2 state
    [ComboState.LIGHT_3, ComboState.HEAVY_FINISHER, ComboState.IDLE], // L->Light3, H->HeavyFinisher, D->Idle
    
    // LIGHT_3 state (finisher)
    [-1, -1, ComboState.IDLE], // Only dash can interrupt
    
    // HEAVY_1 state
    [-1, -1, ComboState.IDLE], // Only dash can interrupt
    
    // HEAVY_FINISHER state
    [-1, -1, ComboState.IDLE]  // Only dash can interrupt
];



depth = -y;

image_speed = 0.2;
spriteHandler = new SpriteHandler(spr_char_left, spr_char_right, spr_char_up, spr_char_left);
dashSpeed = 6;


input = new Input();
movement = new PlayerMovement(self, 4);


isDashing = false;

currentSprite = spr_char_left;



//orb = instance_create_depth(x, y, depth - 1, obj_player_orb);
//orb.owner = self;

sword = instance_create_depth(x, y, depth-1, obj_sword);
sword.owner = self;

shotSpeed = 12;

controllerType = CONTROL_TYPE.KBM;

canDash = true;
dashTimer = 0;
maxDashTimer = 8;

currentWeapon = Weapon.Sword;

// Knockback variables
knockbackX = 0;
knockbackY = 0;
knockbackFriction = 0.85; // How quickly knockback slows down (0.8-0.95 range works well)
knockbackThreshold = 0.1; // Minimum speed before knockback stops completely
knockbackPower = 0;

knockbackCooldown = 0;
knockbackCooldownMax = 10; // Frames of immunity after being hit

cannonCooldown = 0;
cannonCooldownMax = 30; // Half second between cannon uses
isCannonBalling = false; // Track if we're in cannon ball state
cannonDamage = 20; // Damage dealt when ramming enemies




mod_triggers = {};      // Modifiers sorted by trigger for fast lookup




Weapon_ =
{
	Bow: 
		{
			name: "",
			description: "",
			type: WeaponType.Range,
			projectile_struct: global.Projectile_.Arrow,
			range: 32,
			lob_shot: false,
			
			primary_cooldown: 30,
			secondar_cooldown: 30,
			
			primary_attack: function(_self, _direction, _range, _projectile_struct) {
            // Create the arrow
            var _attack = Shoot_Projectile(_self, _direction, _self, _range, _projectile_struct, obj_arrow);
            
            // Trigger modifiers with projectile reference
            var attack_event = {
                attack_type: "ranged",
                attack_direction: _direction,
                attack_position_x: _self.x,
                attack_position_y: _self.y,
                projectile: _attack,  // The created arrow
                weapon: self,
                damage: _self.attack
            };
            
            TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
            
            return _attack;
        	},
			secondary_attack: function(_self, _direction, _range, _projectile_struct)
			{
				var _attack = Lob_Projectile(_self, _direction, _range, projectile_struct.object);
				return _attack;
			},
		},
	
	Sword:
		{
			name: "",
			description: "",
			type: WeaponType.Melee,
			
			primary_attack_type: "swing",
			secondary_attack_type: "lunge",

			object: obj_sword,
			primary_attack: function(){},
			secondary_attack: function(){}
		}
}



Modifiers =
{
	KnockbackPotion:
	{
		name: "Knockback Potion",
		description: "",
		sprite: noone,
		image: noone,
		hp_mod: 0,
		attack_mod: 0,
		knockback_mod: 0,
		speed_mod: 0, 
	},
	
	DoubleShot:
	{ 
	counter: 3, 
	action: function(_self)
		{
			with (_self)
			{
				
			}
		}
	}
}



mods = [];



weaponCurrent = Weapon_.Bow;

// In your Player CREATE event:
mod_list = [];
mod_cache = {
    stats: {},
    dirty: true,
    last_update: 0
};

// TEST: Add some modifiers for testing
AddModifier(id, "TripleRhythmFire");  // Every 3rd attack spawns fireball
AddModifier(id, "DoubleLightning");    // Every 2nd attack adds lightning
AddModifier(id, "SpreadFire");