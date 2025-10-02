


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



enum WeaponType
{
	None,
	Melee,
	Range,
}

enum MOD_TAG {
    FIRE = 1 << 0,
    ICE = 1 << 1,
    PROJECTILE = 1 << 2,
    MELEE = 1 << 3,
    DEFENSIVE = 1 << 4,
    OFFENSIVE = 1 << 5,
    MOVEMENT = 1 << 6,
    CRITICAL = 1 << 7,
    // ... up to 32 tags with bit flags
}

// Triggers as enums
enum MOD_TRIGGER {
    ON_ATTACK,
    ON_HIT,
    ON_KILL,
    ON_DAMAGED,
    ON_DODGE,
    ON_ROOM_CLEAR,
    ON_PICKUP,
    PASSIVE, // Always active
    // ...
}

enum MOD_ID
{
	FLAME_SHOT,
	OIL_SLICK,
	WIND_BOOST,
	TRIPLE_RHYTHM_FIRE,
	TRIPLE_RHYTHM_CHAOS,
	LUCKY_SHOT
}

enum PATTERN_TYPE {
    EVERY_N,        // Every Nth action
    CHANCE,         // Random chance
    CONDITIONAL,    // When condition met (low health, etc)
    SEQUENCE,       // Follow a pattern [true, false, true, false]
    CHARGE,         // Build up charge
    COMBO          // Within time window
}

enum EFFECT_TYPE {
    SPAWN_PROJECTILE,
    MODIFY_PROJECTILE,
    APPLY_BUFF,
    CREATE_EXPLOSION,
    RANDOM_EFFECT
}
// Base pattern handler
function CreatePattern(_type, _config) {
    switch (_type) {
        case PATTERN_TYPE.EVERY_N:
            return {
                type: _type,
                counter: 0,
                trigger_on: _config.n ?? 3,
                
                should_trigger: function() {
                    counter++;
                    if (counter >= trigger_on) {
                        counter = 0;
                        return true;
                    }
                    return false;
                }
            };
            
        case PATTERN_TYPE.CHANCE:
            return {
                type: _type,
                chance: _config.chance ?? 0.25,
                
                should_trigger: function() {
                    return random(1) < chance;
                }
            };
            
        case PATTERN_TYPE.SEQUENCE:
            return {
                type: _type,
                pattern: _config.pattern ?? [false, false, true],
                index: 0,
                
                should_trigger: function() {
                    var result = pattern[index];
                    index = (index + 1) % array_length(pattern);
                    return result;
                }
            };
    }
}

// Base effect executor
function CreateEffect(_type, _config) {
    switch (_type) {
        case EFFECT_TYPE.SPAWN_PROJECTILE:
            return {
                type: _type,
                projectile: _config.projectile,
                count: _config.count ?? 1,
                spread: _config.spread ?? 0,
                
                execute: function(_entity, _event) {
                    with (_entity) {
                        for (var i = 0; i < other.count; i++) {
                            var proj = instance_create_depth(x, y, depth, other.projectile);
                            proj.direction = _event.attack_direction + (i - other.count/2) * other.spread;
                            proj.owner = id;
                        }
                    }
                }
            };
            
        case EFFECT_TYPE.MODIFY_PROJECTILE:
            return {
                type: _type,
                modifications: _config.mods,
                
                execute: function(_entity, _event) {
                    // Modify the projectile that was just created
                    if (_event.projectile != noone) {
                        with (_event.projectile) {
                            // Apply modifications
                            var mods = other.modifications;
                            if (variable_struct_exists(mods, "element")) {
                                element = mods.element;
                                
                                // Visual changes based on element
                                switch (element) {
                                    case "fire":
                                        sprite_index = spr_fire_projectile;
                                        image_blend = c_orange;
                                        break;
                                    case "ice":
                                        sprite_index = spr_ice_projectile;
                                        image_blend = c_aqua;
                                        break;
                                }
                            }
                            
                            if (variable_struct_exists(mods, "scale")) {
                                image_xscale *= mods.scale;
                                image_yscale *= mods.scale;
                                damage *= mods.scale;
                            }
                            
                            if (variable_struct_exists(mods, "piercing")) {
                                piercing = mods.piercing;
                            }
                        }
                    }
                }
            };
            
        case EFFECT_TYPE.RANDOM_EFFECT:
            return {
                type: _type,
                pool: _config.pool,
                
                execute: function(_entity, _event) {
                    // Pick random effect from pool
                    var random_effect = pool[irandom(array_length(pool) - 1)];
                    random_effect.execute(_entity, _event);
                }
            };
    }
}
// Player/Entity would have:
mod_list = [];           // Active modifier instances
mod_cache = {           // Cached calculations
    stats: {},          // Combined stat mods
    dirty: true,        // Needs recalculation?
    last_update: 0
};
mod_triggers = {};      // Modifiers sorted by trigger for fast lookup


global.Modifiers = {
    // Fire shot every third attack
    TripleRhythmFire: {
        id: MOD_ID.TRIPLE_RHYTHM_FIRE,
        name: "Rhythmic Flames",
        
        pattern: CreatePattern(PATTERN_TYPE.EVERY_N, {n: 3}),
        effect: CreateEffect(EFFECT_TYPE.SPAWN_PROJECTILE, {
            projectile: obj_fireball,
            count: 1
        }),
        
        triggers: [MOD_TRIGGER.ON_ATTACK],
        
        action: function(_entity, _event) {
            var mod_instance = _event.mod_instance;
            
            if (mod_instance.pattern.should_trigger()) {
                mod_instance.effect.execute(_entity, _event);
            }
        }
    },
    
    // Random element every third shot
    TripleRhythmChaos: {
        id: MOD_ID.TRIPLE_RHYTHM_CHAOS,
        name: "Chaotic Rhythm",
        
        pattern: CreatePattern(PATTERN_TYPE.EVERY_N, {n: 3}),
        effect: CreateEffect(EFFECT_TYPE.RANDOM_EFFECT, {
            pool: [
                CreateEffect(EFFECT_TYPE.MODIFY_PROJECTILE, {
                    mods: {element: "fire", scale: 1.5}
                }),
                CreateEffect(EFFECT_TYPE.MODIFY_PROJECTILE, {
                    mods: {element: "ice", scale: 0.8, piercing: true}
                }),
                CreateEffect(EFFECT_TYPE.MODIFY_PROJECTILE, {
                    mods: {element: "lightning", scale: 1.0}
                })
            ]
        }),
        
        triggers: [MOD_TRIGGER.ON_ATTACK],
        
        action: function(_entity, _event) {
            var mod_instance = _event.mod_instance;
            
            if (mod_instance.pattern.should_trigger()) {
                mod_instance.effect.execute(_entity, _event);
            }
        }
    },
    
    // 25% chance to double shot
    LuckyShot: {
        id: MOD_ID.LUCKY_SHOT,
        name: "Lucky Shot",
        
        pattern: CreatePattern(PATTERN_TYPE.CHANCE, {chance: 0.25}),
        effect: CreateEffect(EFFECT_TYPE.SPAWN_PROJECTILE, {
            projectile: obj_arrow,  // Same as original
            count: 1
        }),
        
        triggers: [MOD_TRIGGER.ON_ATTACK],
        action: function(_entity, _event) {
            var mod_instance = _event.mod_instance;
            
            if (mod_instance.pattern.should_trigger()) {
                mod_instance.effect.execute(_entity, _event);
            }
        }
    }
};


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
			
			primary_attack: function(_self, _direction, _range, _projectile_struct)
			{
				var _attack = Shoot_Projectile(_self, _direction, _self, _range, _projectile_struct, obj_arrow);
				var _angle_rad = degtorad(_direction);
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


function ApplyStatModifiers(_self, _mods)
{
	var mod_hp_total = 0;
	var mod_attack_total = 0;
	var mod_knockback_total = 0;
	var mod_speed_total = 0;
	
	
	
	for (var i = 0; i < array_length(_mods) - 1; i++)
	{
		var _current_mod = _mods[i];
		
		if (variable_struct_exists(_current_mod, "hp_mod")) mod_hp_total += _current_mod.hp_mod;
		
		if (variable_struct_exists(_current_mod, "attack_mod")) mod_attack_total += _current_mod.attack_mod;
		
		if (variable_struct_exists(_current_mod, "knockback_mod")) mod_knockback_total += _current_mod.knockback_mod;
		
		if (variable_struct_exists(_current_mod, "speed_mod")) mod_speed_total += _current_mod.speed_mod;
	}
	
	
	
	var _ret = 
	{
		hp_mod:			0,
		attack_mod:   	0,
		knockback_mod: 	0,
		speed_mod:		0,
	}
}

function RunActiveModifiers(_self, _mods)
{
	for (var i = 0; i < array_length(_mods) - 1; i++)
	{
		var _current_mod = _mods[i];
		
		if (variable_struct_exists(_current_mod, "action")) _current_mod.action(_self);
	}
}

mods = [];







weaponCurrent = Weapon_.Bow;


