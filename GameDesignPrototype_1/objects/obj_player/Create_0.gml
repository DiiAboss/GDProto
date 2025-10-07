
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

projectile_count_bonus = 0;

mouseDirection = 0;
mouseDistance = 0;

mySprite = spr_char_right;

img_xscale = 1;


// Charge weapon system
charge_amount = 0;        // 0 to 1
charge_rate = 0.02;       // How fast it charges per frame
max_charge_time = 100;    // Frames to full charge
is_charging = false;


#region Combo and Attack System (Might need rework)


button_combo_array = [];
button_combo_timer = 30;

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
#endregion


depth = -y;

image_speed = 0.2;
spriteHandler = new SpriteHandler(spr_char_left, spr_char_right, spr_char_up, spr_char_left);
dashSpeed = 6;


input = new Input();
movement = new PlayerMovement(self, 4);


isDashing = false;

currentSprite = spr_char_left;
controllerType = CONTROL_TYPE.KBM;


//orb = instance_create_depth(x, y, depth - 1, obj_player_orb);
//orb.owner = self;

sword = instance_create_depth(x, y, depth-1, obj_sword);
sword.owner = self;

shotSpeed = 12;



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


/// ----------- Needs to be contained---------------------------------------------
cannonCooldown = 0;
cannonCooldownMax = 30; // Half second between cannon uses
isCannonBalling = false; // Track if we're in cannon ball state
cannonDamage = 20; // Damage dealt when ramming enemies
/// ----------- Needs to be contained--------------------------------------------


#region Weapon Structure
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
	
	Sword: {
        name: "Sword",
        type: WeaponType.Melee,
        projectile_struct: undefined,  // Add this - swords don't use projectiles
        
        primary_attack: function(_self, _direction, _range, _projectile_struct) {
            // _projectile_struct is ignored for melee
            if (!instance_exists(_self.sword)) return noone;
            
            _self.sword.attack = _self.attack;
            _self.sword.startSwing = true;
            
            var attack_event = {
                attack_type: "melee",
                attack_direction: _direction,
                attack_position_x: _self.x,
                attack_position_y: _self.y,
                damage: _self.attack,
                weapon: self
            };
            
            TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
            
            return _self.sword;
        },
        
        secondary_attack: function(_self, _direction, _range, _projectile_struct) {
            // Heavy attack or block
        }
    },
    
    Boomerang: {
        name: "Boomerang",
        type: WeaponType.Range,
        projectile_struct: global.Projectile_.Boomerang,  // Add this
        cooldown: 0,
        cooldown_max: 60,
        
        primary_attack: function(_self, _direction, _range, _projectile_struct) {
            if (cooldown > 0) return noone;
            
            var _b = instance_create_layer(_self.x, _self.y, "Instances", obj_boomerang);
            _b.owner = _self.id;
            _b.direction = _direction;
            _b.image_angle = _direction;
            
            cooldown = cooldown_max;
            
            var attack_event = {
			    attack_type: "ranged",  // Changed from "boomerang"
			    attack_direction: _direction,
			    attack_position_x: _self.x,
			    attack_position_y: _self.y,
			    damage: _b.damage,
			    projectile: _b,
			    weapon: self
			};
            
            TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
            return _b;
        },
        
        secondary_attack: function(_self, _direction, _range, _projectile_struct) {
            // No secondary for now
        },
        
        step: function(_self) {
            if (cooldown > 0) cooldown--;
        }
    },
	ChargeCannon: {
        name: "Charge Cannon",
        description: "Hold right-click to charge, left-click to fire",
        type: WeaponType.Range,
        projectile_struct: global.Projectile_.Cannonball,
        
        // Charge properties
        min_charge: 0.2,
        charge_rate: 0.015,
        
        // Knockback to player on fire
        self_knockback: true,
        self_knockback_force: 25,
        
        primary_attack: function(_self, _direction, _range, _projectile_struct) {
            // Only fire if charged enough
            if (_self.charge_amount < min_charge) return noone;
            
            var charge_mult = _self.charge_amount;
            
            // Create cannonball
            var proj = instance_create_depth(
                _self.x, 
                _self.y, 
                _self.depth - 1, 
                obj_projectile
            );
            
            // Scale by charge
            proj.direction = _direction;
            proj.speed = lerp(10, 20, charge_mult);
            proj.damage = _self.attack * lerp(1, 3, charge_mult);
            proj.owner = _self.id;
            proj.image_angle = _direction;
            
            // Visual scaling
            proj.image_xscale = lerp(1, 2.5, charge_mult);
            proj.image_yscale = lerp(1, 2.5, charge_mult);
            
            // Knockback power for projectile
            if (variable_instance_exists(proj, "knockback_power")) {
                proj.knockback_power = lerp(10, 50, charge_mult);
            }
            
            // Launch player backwards
            if (self_knockback) {
                var recoil = self_knockback_force * charge_mult;
                _self.knockbackX = lengthdir_x(-recoil, _direction);
                _self.knockbackY = lengthdir_y(-recoil, _direction);
                _self.knockbackPower = recoil;
                _self.isCannonBalling = true;
            }
            
            // Trigger modifiers
            var attack_event = {
                attack_type: "cannon",
                attack_direction: _direction,
                attack_position_x: _self.x,
                attack_position_y: _self.y,
                projectile: proj,
                weapon: self,
                damage: proj.damage,
                charge_amount: charge_mult
            };
            
            TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
            
            // Reset charge
            _self.charge_amount = 0;
            _self.is_charging = false;
            
            return proj;
        },
        
        secondary_attack: function(_self, _direction, _range, _projectile_struct) {
            // Secondary is just the charging mechanic (handled in step)
            // Could add alternate fire mode here if desired
        },
        
        step: function(_self) {
            // Update cannonball state
            if (_self.isCannonBalling) {
                // Check if we've slowed down enough
                if (abs(_self.knockbackX) < 2 && abs(_self.knockbackY) < 2) {
                    _self.isCannonBalling = false;
                }
                
                // Trail effect while cannonballing
                if (current_time % 2 == 0) {
                    // Create afterimage or particle
                }
            }
        }
    },
}
#endregion






weaponCurrent = Weapon_.Bow;


mod_list = [];
mod_cache = {
    stats: {},
    dirty: true,
    last_update: 0
};




// TEST: Add some modifiers for testing
AddModifier(id, "TripleRhythmFire");  // Every 3rd attack spawns fireball
AddModifier(id, "DoubleLightning");    // Every 2nd attack adds lightning

AddModifier(id, "MultiShot");  

AddModifier(id, "SpreadFire"); 
AddModifier(id, "ChainLightning");  // 25% chance on every attack
// or
AddModifier(id, "StaticCharge");    // Builds up then releases
// or  
AddModifier(id, "ThunderStrike");   // Melee-only lightning
AddModifier(id, "ChainLightning");  // Lightning on hit
AddModifier(id, "DeathFireworks");  // Explosion on kill
AddModifier(id, "ChainReaction");   // Explosion kills cause more explosions