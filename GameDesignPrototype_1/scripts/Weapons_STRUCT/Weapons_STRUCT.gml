#region Weapon Structure
global.WeaponStruct =
{
	Bow: {
        name: "Bow",
        id: Weapon.Bow,
        type: WeaponType.Range,
        projectile_struct: global.Projectile_.Arrow,
        
        primary_attack: function(_self, _direction, _range, _projectile_struct) {
            var _attack = Shoot_Projectile(_self, _direction, _self, _range, _projectile_struct, obj_arrow);
            
            var attack_event = CreateAttackEvent(_self, AttackType.RANGED, _direction, _attack);
            TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
            
            return _attack;
        },
        
        secondary_attack: function(_self, _direction, _range, _projectile_struct) {
            var _attack = Lob_Projectile(_self, _direction, _range, projectile_struct.object);
            return _attack;
        }
    },
    
    Sword: {
        name: "Sword",
        id: Weapon.Sword,
        type: WeaponType.Melee,
        projectile_struct: undefined,
        melee_object_type: obj_sword,
        
        combo_count: 0,
        max_combo: 3,
        combo_timer: 0,
        combo_window: 30,
        attack_cooldown: 0,
        
        combo_attacks: [
            {duration: 25, damage_mult: 1.0, knockback_mult: 1.0},
            {duration: 30, damage_mult: 1.2, knockback_mult: 1.1},
            {duration: 40, damage_mult: 1.5, knockback_mult: 1.3}
        ],
        
        primary_attack: function(_self, _direction, _range, _projectile_struct) {
            if (attack_cooldown > 0) return noone;
            if (combo_timer <= 0) combo_count = 0;
            
            var attack_data = combo_attacks[combo_count];
            var melee_attack = _self.attack * attack_data.damage_mult;
            
            if (instance_exists(_self.melee_weapon)) {
                _self.melee_weapon.attack = melee_attack;
                _self.melee_weapon.knockbackForce = 64 * attack_data.knockback_mult;
                _self.melee_weapon.startSwing = true;
                _self.melee_weapon.current_combo_hit = combo_count;
            }
            
            attack_cooldown = attack_data.duration;
            var current_hit = combo_count;
            combo_count = (combo_count + 1) % max_combo;
            combo_timer = combo_window;
            
            var attack_event = CreateAttackEvent(_self, AttackType.MELEE, _direction, noone);
            attack_event.damage = melee_attack;
            attack_event.combo_hit = current_hit;
            
            TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
            
            return _self.melee_weapon;
        },
        
        secondary_attack: function(_self, _direction, _range, _projectile_struct) {},
        
        step: function(_self) {
            if (attack_cooldown > 0) attack_cooldown--;
            if (combo_timer > 0) combo_timer--;
        }
    },
    
    Dagger: {
        name: "Dagger",
        id: Weapon.Dagger,
        type: WeaponType.Melee,
        projectile_struct: global.Projectile_.Knife,
        melee_object_type: obj_dagger,
        
        combo_count: 0,
        max_combo: 3,
        combo_timer: 0,
        combo_window: 25,
        attack_cooldown: 0,
        
        combo_attacks: [
            {duration: 18, damage_mult: 0.8, knockback_mult: 0.7, lunge: false},
            {duration: 20, damage_mult: 0.9, knockback_mult: 0.8, lunge: false},
            {duration: 28, damage_mult: 1.5, knockback_mult: 1.5, lunge: true, lunge_power: 15}
        ],
        
        primary_attack: function(_self, _direction, _range, _projectile_struct) {
            if (attack_cooldown > 0) return noone;
            if (combo_timer <= 0) combo_count = 0;
            
            var attack_data = combo_attacks[combo_count];
            
            if (attack_data.lunge) {
                _self.knockbackX = lengthdir_x(attack_data.lunge_power, _direction);
                _self.knockbackY = lengthdir_y(attack_data.lunge_power, _direction);
            }
            
            var melee_attack = _self.attack * attack_data.damage_mult;
            
            if (instance_exists(_self.melee_weapon)) {
                _self.melee_weapon.attack = melee_attack;
                _self.melee_weapon.knockbackForce = 50 * attack_data.knockback_mult;
                _self.melee_weapon.startSwing = true;
                _self.melee_weapon.current_combo_hit = combo_count;
            }
            
            attack_cooldown = attack_data.duration;
            var current_hit = combo_count;
            combo_count = (combo_count + 1) % max_combo;
            combo_timer = combo_window;
            
            var attack_event = CreateAttackEvent(_self, AttackType.MELEE, _direction, noone);
            attack_event.damage = melee_attack;
            attack_event.combo_hit = current_hit;
            
            TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
            
            return _self.melee_weapon;
        },
        
        secondary_attack: function(_self, _direction, _range, _projectile_struct) {
            if (attack_cooldown > 0) return noone;
            
            var proj = instance_create_depth(_self.x, _self.y, _self.depth - 1, obj_knife);
            proj.direction = _direction;
            proj.speed = 12;
            proj.damage = _self.attack * 0.6;
            proj.owner = _self.id;
            proj.image_angle = _direction;
            
            var attack_event = CreateAttackEvent(_self, AttackType.RANGED, _direction, proj);
            attack_event.projectile_count_bonus = 2; // 3 total knives
            
            TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
            return proj;
        },
        
        step: function(_self) {
            if (attack_cooldown > 0) attack_cooldown--;
            if (combo_timer > 0) combo_timer--;
        }
    },
	BaseballBat: {
    name: "Baseball Bat",
    id: Weapon.BaseballBat,
    type: WeaponType.Melee,
    projectile_struct: undefined,
    melee_object_type: obj_baseball_bat,
    
    combo_count: 0,
    max_combo: 3,
    combo_timer: 0,
    combo_window: 35,
    attack_cooldown: 0,
    
    combo_attacks: [
        {duration: 30, damage_mult: 1.2, knockback_mult: 1.5},  // Slower but harder hits
        {duration: 32, damage_mult: 1.4, knockback_mult: 1.7},
        {duration: 40, damage_mult: 2.0, knockback_mult: 2.5}   // Grand slam finisher
    ],
    
    primary_attack: function(_self, _direction, _range, _projectile_struct) {
        if (attack_cooldown > 0) return noone;
        if (combo_timer <= 0) combo_count = 0;
        
        var attack_data = combo_attacks[combo_count];
        var melee_attack = _self.attack * attack_data.damage_mult;
        
        if (instance_exists(_self.melee_weapon)) {
            _self.melee_weapon.attack = melee_attack;
            _self.melee_weapon.knockbackForce = 80 * attack_data.knockback_mult; // Higher base knockback
            _self.melee_weapon.startSwing = true;
            _self.melee_weapon.current_combo_hit = combo_count;
        }
        
        attack_cooldown = attack_data.duration;
        var current_hit = combo_count;
        combo_count = (combo_count + 1) % max_combo;
        combo_timer = combo_window;
        
        var attack_event = CreateAttackEvent(_self, AttackType.MELEE, _direction, noone);
        attack_event.damage = melee_attack;
        attack_event.combo_hit = current_hit;
        
        TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
        
        return _self.melee_weapon;
    },
    
    secondary_attack: function(_self, _direction, _range, _projectile_struct) {
        // Could add a charged swing or bunt
    },
    
    step: function(_self) {
        if (attack_cooldown > 0) attack_cooldown--;
        if (combo_timer > 0) combo_timer--;
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
            
            var attack_event = CreateAttackEvent(_self, AttackType.RANGED, _direction, _b);
            
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
            
            var attack_event = CreateAttackEvent(_self, AttackType.CANNON, _direction, proj);
		attack_event.damage = proj.damage; // Override with charged damage
		attack_event.charge_amount = charge_mult; // Add charge info for modifiers
            
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