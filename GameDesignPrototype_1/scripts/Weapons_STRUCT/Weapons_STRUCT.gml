#region Weapon Structure
global.WeaponStruct =
{
	Bow: {
        name: "Bow",
        id: Weapon.Bow,
        type: WeaponType.Range,
        projectile_struct: global.Projectile_.Arrow,
        default_element: ELEMENT.PHYSICAL,
		synergy_tags: InitializeWeaponTags(Weapon.Bow),
		sprite: spr_crossbow,
        primary_attack: function(_self, _direction, _range, _projectile_struct) {
            var _attack = Shoot_Projectile(_self, _direction, _self, _range, _projectile_struct, obj_arrow);
            _attack.speed = 6;
			
			// NEW: Apply synergy behaviors to projectile
		    if (variable_instance_exists(_self, "active_combined_tags")) {
		        ApplySynergyBehavior(_attack, _self.active_combined_tags, _self.active_synergies, _self);
		    }

			
            var attack_event = CreateAttackEvent(_self, AttackType.RANGED, _direction, _attack);
            TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
            
            return _attack;
        },
        
        secondary_attack: function(_self, _direction, _range, _projectile_struct) {
           
			
			 var _attack = Lob_Projectile(_self, _direction, _range, _projectile_struct.object);
			
						// NEW: Apply synergy behaviors to projectile
		    if (variable_instance_exists(_self, "active_combined_tags")) {
		        ApplySynergyBehavior(_attack, _self.active_combined_tags, _self.active_synergies, _self);
		    }

			
            return _attack;
        }
    },
	BBallGun: {
        name: "Bball Gun",
        id: Weapon.BBallGun,
        type: WeaponType.Range,
        projectile_struct: global.Projectile_.Arrow,
        default_element: ELEMENT.PHYSICAL,
		synergy_tags: InitializeWeaponTags(Weapon.BBallGun),
		sprite: spr_bball_gun,
        primary_attack: function(_self, _direction, _range, _projectile_struct) {
            var _attack = Shoot_Projectile(_self, _direction, _self, _range, _projectile_struct,53, 53);
            _attack.speed = 6;
			
			// NEW: Apply synergy behaviors to projectile
		    if (variable_instance_exists(_self, "active_combined_tags")) {
		        ApplySynergyBehavior(_attack, _self.active_combined_tags, _self.active_synergies, _self);
		    }

			
            var attack_event = CreateAttackEvent(_self, AttackType.RANGED, _direction, _attack);
            TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
            
            return _attack;
        },
        
        secondary_attack: function(_self, _direction, _range, _projectile_struct) {
           
			
			 var _attack = Lob_Projectile(_self, _direction, _range, _projectile_struct.object);
			
						// NEW: Apply synergy behaviors to projectile
		    if (variable_instance_exists(_self, "active_combined_tags")) {
		        ApplySynergyBehavior(_attack, _self.active_combined_tags, _self.active_synergies, _self);
		    }

			
            return _attack;
        }
    },
	
	ChainWhip: {
    name: "Chain Whip",
    id: Weapon.ChainWhip, // Add to your Weapon enum
    type: WeaponType.Melee,
    projectile_struct: noone, // Not using projectile struct
    melee_object_type: obj_chain_whip,
    default_element: ELEMENT.PHYSICAL,
	synergy_tags: InitializeWeaponTags(Weapon.ChainWhip),
	sprite: spr_knife,
    // Attack queue system
    attack_queue: 0,
    max_queue: 3,
    queue_timer: 0,
    queue_interval: 10,
    is_executing_queue: false,
    current_attack_direction: 0,
    
    // Attack properties
    attack_range: 128,
    knife_range: 256,
    
    // Damage scaling per queued hit
    queue_damage_mults: [1.0, 1.1, 1.2], // 1st, 2nd, 3rd hit
    queue_knockback_mults: [1.0, 1.0, 1.2],
    
    // Knife tracking
    active_knife: noone,
    
    primary_attack: function(_self, _direction, _range, _projectile_struct) {
        // Queue up an attack (max 3)
        if (attack_queue < max_queue) {
            attack_queue++;
            
            // Start executing if not already
            if (!is_executing_queue) {
                is_executing_queue = true;
                queue_timer = 0;
                current_attack_direction = _direction;
                ExecuteQueuedAttack(_self, 0); // Execute first immediately
            }
        }
        
        return _self.melee_weapon;
    },
    
    secondary_attack: function(_self, _direction, _range, _projectile_struct) {
        // Only throw if no active knife
        //if (active_knife != noone && instance_exists(active_knife)) {
            //return noone;
        //}
        show_debug_message("secondary_attack chain link init");
        // Create knife projectile
        var knife = instance_create_depth(_self.x, _self.y, _self.depth - 1, obj_chain_knife);
        knife.owner = _self.id;
        knife.direction = _direction;
        knife.image_angle = _direction;
        knife.damage = _self.attack * 0.7;
        knife.max_distance = knife_range;
        knife.weapon_struct = self; // Reference back to weapon
        
        active_knife = knife;
        
        var attack_event = CreateAttackEvent(_self, AttackType.RANGED, _direction, knife);
        TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
        
        return knife;
    },
    
    step: function(_self) {
        // Process attack queue
        if (is_executing_queue) {
            queue_timer++;
            
            // Check if it's time for next queued attack
            if (queue_timer >= queue_interval && attack_queue > 0) {
                var attack_index = max_queue - attack_queue; // 0, 1, or 2
                ExecuteQueuedAttack(_self, attack_index);
                queue_timer = 0;
            }
            
            // Check if queue is finished
            if (attack_queue <= 0 && queue_timer >= queue_interval) {
                is_executing_queue = false;
                queue_timer = 0;
            }
        }
        
        // Clean up dead knife reference
        if (active_knife != noone && !instance_exists(active_knife)) {
            active_knife = noone;
        }
    },
    
    /// @method ExecuteQueuedAttack(_self, _attack_index)
    ExecuteQueuedAttack: function(_self, _attack_index) {
        if (!instance_exists(_self.melee_weapon)) return;
        
        attack_queue--;
        
        // Get damage multiplier for this hit in sequence
        var damage_mult = queue_damage_mults[_attack_index];
        var knockback_mult = queue_knockback_mults[_attack_index];
        
        // Update melee weapon
        _self.melee_weapon.attack = _self.attack * damage_mult;
        _self.melee_weapon.knockbackForce = 20 * knockback_mult;
        _self.melee_weapon.startSwing = true;
        _self.melee_weapon.current_queue_hit = _attack_index;
        
        // Create attack event
        var attack_event = CreateAttackEvent(_self, AttackType.MELEE, current_attack_direction, noone);
        attack_event.damage = _self.melee_weapon.attack;
        attack_event.queue_hit = _attack_index;
        
        TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
    }
},
    
    Sword: {
    name: "Sword",
    id: Weapon.Sword,
    type: WeaponType.Melee,
    projectile_struct: noone,
    melee_object_type: obj_sword,
    default_element: ELEMENT.PHYSICAL,
    synergy_tags: InitializeWeaponTags(Weapon.Sword),
    sprite: spr_sword,
    
    // SWORD STATS: High damage, low knockback, slower swing
    attack_cooldown: 0,
    
    primary_attack: function(_self, _direction, _range, _projectile_struct) {
        if (attack_cooldown > 0) return noone;
        
        // Sword: 1.5x player attack, low knockback, slower cooldown
        var melee_attack = _self.attack * 1.5;
        
        if (instance_exists(_self.melee_weapon)) {
            _self.melee_weapon.attack = melee_attack;
            _self.melee_weapon.knockbackForce = 12; // LOW knockback
            _self.melee_weapon.startSwing = true;
            _self.melee_weapon.swingSpeed = 6; // SLOWER swing
        }
        
        attack_cooldown = 35; // Slower attack rate
        
        var attack_event = CreateAttackEvent(_self, AttackType.MELEE, _direction, noone);
        attack_event.damage = melee_attack;
        TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
        
        return _self.melee_weapon;
    },
    
    secondary_attack: function(_self, _direction, _range, _projectile_struct) {
        // No secondary for sword
    },
    
    step: function(_self) {
        if (attack_cooldown > 0) attack_cooldown = timer_tick(attack_cooldown);
    }
},
    
   Dagger: {
    name: "Dagger",
    id: Weapon.Dagger,
    type: WeaponType.Melee,
    projectile_struct: global.Projectile_.Knife,
    melee_object_type: obj_dagger,
    default_element: ELEMENT.PHYSICAL,
    synergy_tags: InitializeWeaponTags(Weapon.Dagger),
    sprite: spr_dagger,
    
    // DAGGER STATS: Fast, always lunges, lunge based on speed
    attack_cooldown: 0,
    
    primary_attack: function(_self, _direction, _range, _projectile_struct) {
        if (attack_cooldown > 0) return noone;
        
        // Dagger: 0.7x player attack, very low knockback, VERY fast
        var melee_attack = _self.attack * 0.7;
        
        // LUNGE CALCULATION - Based on player speed stat
        var base_lunge = 8;
        var speed_stat = _self.stats.speed; // Player's speed stat
        var lunge_power = base_lunge + (speed_stat * 1.5); // More speed = longer lunge
        lunge_power = clamp(lunge_power, 8, 30); // Min 8, max 30
        
        // Apply lunge to player
        _self.knockback.Apply(_direction, lunge_power);
        
        if (instance_exists(_self.melee_weapon)) {
            _self.melee_weapon.attack = melee_attack;
            _self.melee_weapon.knockbackForce = 6; // Very low knockback
            _self.melee_weapon.startSwing = true;
            _self.melee_weapon.swingSpeed = 18; // VERY FAST swing
            _self.melee_weapon.is_lunging = true;
            _self.melee_weapon.lunge_distance = lunge_power;
        }
        
        attack_cooldown = 12; // Very fast attack rate
        
        var attack_event = CreateAttackEvent(_self, AttackType.MELEE, _direction, noone);
        attack_event.damage = melee_attack;
        attack_event.is_lunge = true;
        TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
        
        return _self.melee_weapon;
    },
    
    secondary_attack: function(_self, _direction, _range, _projectile_struct) {
        if (attack_cooldown > 0) return noone;
        
        // Throw knife
        var proj = instance_create_depth(_self.x, _self.y, _self.depth - 1, obj_knife);
        proj.direction = _direction;
        proj.speed = 14;
        proj.damage = _self.attack * 0.5;
        proj.owner = _self.id;
        proj.image_angle = _direction;
        
        attack_cooldown = 15;
        
        var attack_event = CreateAttackEvent(_self, AttackType.RANGED, _direction, proj);
        TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
        
        return proj;
    },
    
    step: function(_self) {
        if (attack_cooldown > 0) attack_cooldown = timer_tick(attack_cooldown);
    }
},


	HolyWater: {
        name: "Holy_Water",
        id: Weapon.Holy_Water,
        type: WeaponType.Range,
        projectile_struct: global.Projectile_.Holy_Water,
        default_element: ELEMENT.PHYSICAL,
		synergy_tags: InitializeWeaponTags(Weapon.Holy_Water),
		sprite: spr_holy_water,
       primary_attack: function(_self, _direction, _range, _projectile_struct) {
		    var proj = Lob_Projectile(_self, _direction, _range, projectile_struct.object);
		    
		    // NEW: Apply synergies to projectile
		    if (variable_instance_exists(_self, "active_combined_tags") && 
		        variable_instance_exists(_self, "active_synergies")) {
		        ApplySynergyBehavior(proj, _self.active_combined_tags, _self.active_synergies, _self);
		    }
		    
		    // Existing modifier trigger
		    var attack_event = CreateAttackEvent(_self, AttackType.RANGED, _direction, proj);
		    TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
		    
		    return proj;
		},
        
        secondary_attack: function(_self, _direction, _range, _projectile_struct) {
            var _attack = Lob_Projectile(_self, _direction, _range, projectile_struct.object);
			
			
			// NEW: Apply synergies to projectile
		    if (variable_instance_exists(_self, "active_combined_tags") && 
		        variable_instance_exists(_self, "active_synergies")) {
		        ApplySynergyBehavior(_attack, _self.active_combined_tags, _self.active_synergies, _self);
		    }
		    
		    // Existing modifier trigger
		    var attack_event = CreateAttackEvent(_self, AttackType.RANGED, _direction, _attack);
		    TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
			
            return _attack;
        }
    },
	PotionBomb: {
        name: "Potion_Bomb",
        id: Weapon.PotionBomb,
        type: WeaponType.Range,
        projectile_struct: global.Projectile_.Potion_Bomb,
        default_element: ELEMENT.PHYSICAL,
		synergy_tags: InitializeWeaponTags(Weapon.PotionBomb),
		sprite: spr_potions,
       primary_attack: function(_self, _direction, _range, _projectile_struct) {
		    var proj = Lob_Projectile(_self, _direction, _range, projectile_struct.object);
		    
		    // NEW: Apply synergies to projectile
		    if (variable_instance_exists(_self, "active_combined_tags") && 
		        variable_instance_exists(_self, "active_synergies")) {
		        ApplySynergyBehavior(proj, _self.active_combined_tags, _self.active_synergies, _self);
		    }
		    
		    // Existing modifier trigger
		    var attack_event = CreateAttackEvent(_self, AttackType.RANGED, _direction, proj);
		    TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
		    
		    return proj;
		},
        
        secondary_attack: function(_self, _direction, _range, _projectile_struct) {
            var _attack = Lob_Projectile(_self, _direction, _range, projectile_struct.object);
			
			
			// NEW: Apply synergies to projectile
		    if (variable_instance_exists(_self, "active_combined_tags") && 
		        variable_instance_exists(_self, "active_synergies")) {
		        ApplySynergyBehavior(_attack, _self.active_combined_tags, _self.active_synergies, _self);
		    }
		    
		    // Existing modifier trigger
		    var attack_event = CreateAttackEvent(_self, AttackType.RANGED, _direction, _attack);
		    TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
			
            return _attack;
        }
    },
    
	BaseballBat: {
    name: "Baseball Bat",
    id: Weapon.BaseballBat,
    type: WeaponType.Melee,
    projectile_struct: noone,
    melee_object_type: obj_baseball_bat,
    synergy_tags: InitializeWeaponTags(Weapon.BaseballBat),    
    sprite: spr_way_better_bat,
    
    // BAT STATS: Lower damage, HIGH knockback, faster swing
    attack_cooldown: 0,
    
    primary_attack: function(_self, _direction, _range, _projectile_struct) {
        if (attack_cooldown > 0) return noone;
        
        // Bat: 0.8x player attack, HIGH knockback, faster cooldown
        var melee_attack = _self.attack * 0.8;
        var base_knockback = 48; // HIGH knockback
        
        // CHECK FOR BASEBALL PLAYER HOMERUN SYNERGY
        var homerun_chance = 0;
        if (_self.character_class == CharacterClass.BASEBALL_PLAYER) {
            // Baseball player gets homerun chance based on luck
            var luck = variable_instance_exists(_self, "luck") ? _self.luck : 0;
            homerun_chance = 0.05 + (luck * 0.01); // 5% base + 1% per luck point
            homerun_chance = min(homerun_chance, 0.35); // Cap at 35%
        }
        
        if (instance_exists(_self.melee_weapon)) {
            _self.melee_weapon.attack = melee_attack;
            _self.melee_weapon.knockbackForce = base_knockback;
            _self.melee_weapon.startSwing = true;
            _self.melee_weapon.swingSpeed = 12; // FASTER swing
            
            // Pass homerun chance to bat object
            _self.melee_weapon.homerun_chance = homerun_chance;
            _self.melee_weapon.is_baseball_player = (_self.character_class == CharacterClass.BASEBALL_PLAYER);
        }
        
        attack_cooldown = 20; // Faster attack rate
        
        var attack_event = CreateAttackEvent(_self, AttackType.MELEE, _direction, noone);
        attack_event.damage = melee_attack;
        TriggerModifiers(_self, MOD_TRIGGER.ON_ATTACK, attack_event);
        
        return _self.melee_weapon;
    },
    
    secondary_attack: function(_self, _direction, _range, _projectile_struct) {
        // No secondary for bat
    },
    
    step: function(_self) {
        if (attack_cooldown > 0) attack_cooldown = timer_tick(attack_cooldown);
    }
},
	
    Boomerang: {
        name: "Boomerang",
		id: Weapon.Boomerang,
        type: WeaponType.Range,
        projectile_struct: global.Projectile_.Boomerang,  // Add this
        cooldown: 0,
        cooldown_max: 60,
        default_element: ELEMENT.PHYSICAL,
		synergy_tags: InitializeWeaponTags(Weapon.Boomerang),
		sprite: spr_boomerang,
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
		id: Weapon.ChargeCannon,
        description: "Hold right-click to charge, left-click to fire",
        type: WeaponType.Range,
        projectile_struct: global.Projectile_.Cannonball,
        default_element: ELEMENT.PHYSICAL,
		synergy_tags: InitializeWeaponTags(Weapon.ChargeCannon),
		sprite: spr_air_cannon,
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
				_self.knockback.Apply(-_direction, recoil);
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
                if (_self.knockback.Get_) {
                    _self.isCannonBalling = false;
                }
                
                // Trail effect while cannonballing
                if (current_time % 2 == 0) {
                    // Create afterimage or particle
                }
            }
        }
    },
	ThrowableItem: {
    name: "Throwable Item",
    id: Weapon.ThrowableItem,
    type: WeaponType.Range,
    projectile_struct: noone, // Will be set dynamically based on carried object
    charge_rate: 0.01, // Charge speed (adjust to taste)
    max_charge_speed: 15, // Maximum projectile speed when fully charged
    min_charge_speed: 4,  // Minimum projectile speed
    max_charge_damage_mult: 3.0, // 3x damage at full charge
    min_charge_damage_mult: 0.5, // 0.5x damage at no charge
    default_element: ELEMENT.PHYSICAL,
	synergy_tags: InitializeWeaponTags(Weapon.ThrowableItem),
	sprite: spr_rock_proj,
    primary_attack: function(_self, _direction, _range, _projectile_struct) {
        // Only attack if carrying something
        if (!_self.is_carrying || !instance_exists(_self.carried_object)) {
            return noone;
        }
        
        var obj = _self.carried_object;
        var charge = _self.charge_amount; // 0.0 to 1.0
        
        // Calculate charge-based stats
        var throw_speed = lerp(min_charge_speed, max_charge_speed, charge);
        var damage_mult = lerp(min_charge_damage_mult, max_charge_damage_mult, charge);
        
        // Release the carried object
        _self.is_carrying = false;
        obj.is_being_carried = false;
        obj.carrier = noone;
        
        // Convert to projectile
        obj.is_projectile = true;
        obj.projectile_speed = throw_speed;
        obj.damage = _self.attack * damage_mult;
        obj.moveX = lengthdir_x(throw_speed, _direction);
        obj.moveY = lengthdir_y(throw_speed, _direction);
        obj.image_angle = _direction;
        obj.thrown_direction = _direction;
        obj.is_charged_throw = (charge > 0.7); // Consider "charged" if 70%+
        
        // Destroy on impact
        obj.destroy_on_impact = true;
        
        // Visual feedback
        if (obj.is_charged_throw) {
            obj.trail_color = c_yellow;
            obj.has_trail = true;
        }
        
        // Call custom throw event
        if (variable_instance_exists(obj, "OnChargedThrow")) {
            obj.OnChargedThrow(_self, _direction, charge);
        }
        
        // Reset player state
        _self.carried_object = noone;
        _self.stats.temp_speed_mult = 1.0;
        _self.charge_amount = 0;
        
        // Switch back to previous weapon (or unarmed)
        if (instance_exists(_self.previous_weapon_instance)) {
            _self.weaponCurrent = _self.previous_weapon_instance;
        } else {
            _self.weaponCurrent = global.WeaponStruct.Bow; // Default fallback
        }
        
        return obj;
    },
    
    secondary_attack: function(_self, _direction, _range, _projectile_struct) {
    // Gentle lob - doesn't destroy object
    if (!_self.is_carrying || !instance_exists(_self.carried_object)) {
        return noone;
    }
    
    var obj = _self.carried_object;
    
    // Calculate target position for shadow tracking
    var target_dist = min(_range, 200);
    obj.targetX = obj.x + lengthdir_x(target_dist, _direction);
    obj.targetY = obj.y + lengthdir_y(target_dist, _direction);
    
    // Release
    _self.is_carrying = false;
    obj.is_being_carried = false;
    obj.carrier = noone;
    
    // Gentle lob setup
    obj.is_projectile = true;
    obj.is_lob_shot = true;
    obj.projectile_speed = 6;
    obj.damage = _self.attack * 0.3;
    obj.lob_direction = _direction;
    obj.targetDistance = target_dist;
    obj.destroy_on_impact = false;
    
    // Arc physics
    obj.xStart = obj.x;
    obj.yStart = obj.y;
    obj.lobHeight = 32;
    obj.lobProgress = 0;
    obj.lobStep = 0; // Reset progress
    
    // Set movement
    var lob_speed = 4;
    obj.moveX = lengthdir_x(lob_speed, _direction);
    obj.moveY = lengthdir_y(lob_speed, _direction);
    
    if (variable_instance_exists(obj, "OnLobThrow")) {
        obj.OnLobThrow(_self, _direction);
    }
    
    // Reset player
    _self.carried_object = noone;
    _self.stats.temp_speed_mult = 1.0;
    _self.charge_amount = 0;
    
    if (instance_exists(_self.previous_weapon_instance)) {
        _self.weaponCurrent = _self.previous_weapon_instance;
    } else {
        _self.weaponCurrent = global.WeaponStruct.Bow;
    }
    
    return obj;
},
    
    step: function(_self) {
        // Visual charge indicator
        if (_self.is_charging && _self.is_carrying) {
            // You could spawn charge particles here
            if (_self.charge_amount > 0.9) {
                // Full charge visual effect
            }
        }
    }
}
}
#endregion