/// @desc Player Step Event - Component-based
if (is_dead) exit;

// SYSTEM UPDATES

camera.update();
depth = -y;

if (global.gameSpeed == 0) exit;

// COMPONENT UPDATES
timers.Update();
invincibility.Update();
damage_sys.Update();
knockback.Update(self);


// Trigger passive modifiers 
stats.ResetTemporaryMods();
TriggerModifiers(self, MOD_TRIGGER.PASSIVE, EventData());


if (can_interact > 0)
{
 can_interact--;
}

img_xscale = (mouseDirection > 90 && mouseDirection < 270) ? -1 : 1; // For weapon directions

// Sync legacy variables
hp = damage_sys.hp;


while (experience_points >= exp_to_next_level) {
    experience_points -= exp_to_next_level;
    player_level += 1;
    exp_to_next_level = calculate_exp_requirement(player_level);
    
	on_level_up();
}



/// @function TriggerLevelUp()
function TriggerLevelUp() {
    // Tell game manager to show popup
    var _gm = obj_game_manager;
    _gm.ShowLevelUpPopup(_gm.can_click);
    
	// Update Mission Status
    UpdateMission("reach_level_5", 1);
}


/// @function on_level_up()
/// @description Called when player levels up
function on_level_up() {
    // Visual feedback first
    var popup = instance_create_depth(x, y - 60, -9999, obj_floating_text);
    popup.text = "LEVEL UP!";
    popup.color = c_yellow;
    popup.lifetime = 120;
    popup.rise_speed = 0.5;
    popup.scale = 2.0;
    
    // Heal player slightly
    hp = min(hp + (maxHp * 0.2), maxHp);
    
    // Start slowdown sequence
    obj_game_manager.level_up_slowdown_active = true;
    obj_game_manager.level_up_slowdown_timer = 0;
}


// DAMAGE DETECTION
if (!invincibility.active) {
    CheckDamage();
}


// COIN COLLECTION

if (place_meeting(x, y, obj_coin)) {
    with (instance_place(x, y, obj_coin)) {
        instance_destroy();
    }
	gold += 1 * (stats.gold_mult);
}


// INPUT UPDATE
mouseDirection = input.Direction;
mouseDistance = distance_to_point(mouse_x, mouse_y);



// CARRYING SYSTEM

HandleCarrying();


// WEAPON SWITCHING

HandleWeaponSwitching();


// MOVEMENT

var _hasMoved = movement.Update(input, scale_movement(mySpeed));
image_speed = scale_animation(_hasMoved ? 0.4 : 0.2);
currentSprite = SpriteHandler.UpdateSpriteByAimDirection(currentSprite, mouseDirection);













// Track timing window between attacks
if (attack_timing_window > 0) {
    attack_timing_window-=game_speed_delta();
}

// CHARGE WEAPON
if (weaponCurrent && !is_falling_in_pit)
{
	if (variable_struct_exists(weaponCurrent, "charge_rate")) {
	    if (input.Fire) {
	        is_charging = true;
	        charge_amount = min(charge_amount + weaponCurrent.charge_rate * game_speed_delta(), 1.0);
	    } else {
	        is_charging = false;
	    }
	    
	    // Natural decay when not charging
	    if (!is_charging && charge_amount > 0) {
	        charge_amount = max(charge_amount - 0.005 * game_speed_delta(), 0);
	    }
	}
	
	
	// WEAPON ATTACKS
	
		// Handle melee weapon visibility based on last used weapon
	if (variable_instance_exists(id, "last_attack_slot")) {
	    var should_show_melee = false;
	    var active_slot_weapon = weapons[last_attack_slot];
    
	    if (active_slot_weapon != noone && active_slot_weapon.type == WeaponType.Melee) {
	        should_show_melee = true;
        
	        // Switch melee weapon object if needed
	        if (instance_exists(melee_weapon)) {
	            if (variable_struct_exists(active_slot_weapon, "melee_object_type")) {
	                if (melee_weapon.object_index != active_slot_weapon.melee_object_type) {
	                    instance_destroy(melee_weapon);
	                    melee_weapon = instance_create_depth(x, y, depth - 1, active_slot_weapon.melee_object_type);
	                    melee_weapon.owner = self;
	                    melee_weapon.weapon_id = active_slot_weapon.id;
	                }
	            }
	        } else if (variable_struct_exists(active_slot_weapon, "melee_object_type")) {
	            melee_weapon = instance_create_depth(x, y, depth - 1, active_slot_weapon.melee_object_type);
	            melee_weapon.owner = self;
	            melee_weapon.weapon_id = active_slot_weapon.id;
	        }
	    }
    
	    // Hide melee weapon if last used was ranged
	    if (!should_show_melee && instance_exists(melee_weapon)) {
	        melee_weapon.visible = false;
	    } else if (instance_exists(melee_weapon)) {
	        melee_weapon.visible = true;
	    }
	}

	// PRIMARY ATTACK (LMB) - Slot 0
	if (input.FirePress && weapons[0] != noone) {
	    last_attack_slot = 0;
	    var primary_weapon = weapons[0];
		SwitchToWeaponSlot(0);
	    // Update weaponCurrent for systems that need it
	    weaponCurrent = primary_weapon;
	    UpdateWeaponTags(self, 0);
    
	    var attack_result = primary_weapon.primary_attack(self, mouseDirection, mouseDistance, primary_weapon.projectile_struct);
    
	    if (attack_result && switch_near_enemy > 0) {
	        AwardStylePoints("WEAPON SWAP", 5, 1);
	    }
	}

	// ALT ATTACK (RMB) - Slot 1
	if (input.AltPress && weapons[1] != noone) {
	    last_attack_slot = 1;
	    var alt_weapon = weapons[1];
		SwitchToWeaponSlot(1);
	    // Update weaponCurrent for systems that need it
	    weaponCurrent = alt_weapon;
	    UpdateWeaponTags(self, 1);
    
	    alt_weapon.primary_attack(self, mouseDirection, mouseDistance, alt_weapon.projectile_struct);
	}

	// Run step functions for BOTH weapons
	if (weapons[0] != noone && variable_struct_exists(weapons[0], "step")) {
	    weapons[0].step(self);
	}
	if (weapons[1] != noone && variable_struct_exists(weapons[1], "step")) {
	    weapons[1].step(self);
	}
}


status.Update();

if (switch_near_enemy > 0)
{
	switch_near_enemy -= game_speed_delta();
}


if (keyboard_check_pressed(ord("F")))
{
    instance_create_depth(x, y, depth, obj_split_projectile);
}


/// @func HandleCarrying()
function HandleCarrying() {
    // THROW CARRIED OBJECT
    if (is_carrying && instance_exists(carried_object)) {
        if (input.FirePress) { // Left click to throw
            ThrowCarriedObject(self);
            return;
        }
        
        // Apply carry speed penalty
        stats.temp_speed_mult = carry_speed_multiplier;
    } else {
        // Not carrying - check for pickup
        if (keyboard_check_pressed(ord("E"))) {
            AttemptPickup();
        }
    }
}

/// @func AttemptPickup()
function AttemptPickup() {
    var nearest = instance_nearest(x, y, obj_can_carry);
    
    if (instance_exists(nearest)) {
        var dist = point_distance(x, y, nearest.x, nearest.y);
        
        if (dist < nearest.interaction_range && nearest.can_be_carried && !nearest.is_being_carried && !nearest.is_projectile) {
            // Pick up object
            is_carrying = true;
            carried_object = nearest;
            
            nearest.is_being_carried = true;
            nearest.carrier = id;
            nearest.moveX = 0;
            nearest.moveY = 0;
            
            // **SWITCH TO THROWABLE WEAPON**
            previous_weapon_instance = weaponCurrent;
            weaponCurrent = global.WeaponStruct.ThrowableItem;
            charge_amount = 0;
            
            
            // Update synergy tags for throwable weapon
            // NOTE: We're not switching weapon slots, just weaponCurrent reference
            // So we need to temporarily put it in the weapons array
            var temp_weapon = weapons[current_weapon_index];
            weapons[current_weapon_index] = weaponCurrent;
            UpdateWeaponTags(id, current_weapon_index);
            weapons[current_weapon_index] = temp_weapon; // Restore original
            if (variable_instance_exists(nearest, "OnPickedUp")) {
                nearest.OnPickedUp(id);
            }
        }
    }
}

/// @func ThrowCarriedObject()
function ThrowCarriedObject(_self) {
	if (!instance_exists(_self.carried_object)) {
        _self.is_carrying	   = false;
        _self.carried_object   = noone;
        return;
    }
    
    var obj = _self.carried_object;
    
    // Release object
    _self.is_carrying = false;
    obj.is_being_carried = false;
    obj.carrier = noone;
    
    // Launch toward mouse
    if (obj.can_be_thrown) {
        var throw_dir = point_direction(x, y, mouse_x, mouse_y);
        var throw_strength = obj.throw_force / obj.weight; // Heavier = shorter throw
        
        obj.moveX = lengthdir_x(throw_strength, throw_dir);
        obj.moveY = lengthdir_y(throw_strength, throw_dir);
        obj.is_projectile = true;
		obj.is_lob_shot = false;  // Straight throw
        // ========== NEW: APPLY SYNERGIES TO THROWN OBJECT ==========
        // Give the thrown object THROWABLE tag and apply synergies
        if (variable_instance_exists(id, "active_combined_tags") && 
            variable_instance_exists(id, "active_synergies")) {
            
            // Apply synergy behaviors (homing, power throw, etc)
            ApplySynergyBehavior(obj, active_combined_tags, active_synergies, id);
            
        }
        
        // Call throw event (for custom behavior)
        if (variable_instance_exists(obj, "OnThrown")) {
            obj.OnThrown(id, throw_dir);
        }
    }
    
    carried_object = noone;
    stats.temp_speed_mult = 1.0; // Restore speed
    weaponCurrent = previous_weapon_instance;
}

/// @func DropCarriedObject()
function DropCarriedObject() {
    if (!instance_exists(carried_object)) {
        is_carrying = false;
        carried_object = noone;
        return;
    }
    
    var obj = carried_object;
    
    // Gently drop (no velocity)
    is_carrying = false;
    obj.is_being_carried = false;
    obj.carrier = noone;
    obj.moveX = 0;
    obj.moveY = 0;
    
    // Call drop event
    if (variable_instance_exists(obj, "OnDropped")) {
        obj.OnDropped(id);
    }
    weaponCurrent = previous_weapon_instance;
    carried_object = noone;
    stats.temp_speed_mult = 1.0;
}

// In HandleCarrying():
if (is_carrying && keyboard_check_pressed(ord("Q"))) {
    DropCarriedObject();
}


//// Camera debug
//if (keyboard_check_pressed(vk_f1)) camera.add_shake(5);
//if (keyboard_check_pressed(vk_f2)) camera.add_shake(15);
//if (keyboard_check_pressed(vk_f3)) camera.set_zoom(1.5);
//if (keyboard_check_pressed(vk_f4)) camera.set_zoom(0.8);
//if (keyboard_check_pressed(vk_f5)) camera.set_zoom(1.0);








// HELPER FUNCTIONS

function OnPlayerDamaged() {
    // Reset combo
    if (combo_count > 0) {
        // Optional: Show combo break effect
        var popup = instance_create_depth(x, y - 32, -9999, obj_floating_text);
        popup.text = "COMBO BREAK!";
        popup.color = c_red;
    }
    
    // Track max combo before reset
    if (combo_count > max_combo_reached) {
        max_combo_reached = combo_count;
    }
    
    combo_count = 0;
    combo_display_timer = 0;
}



/// @func CheckDamage()
function CheckDamage() {
	
	if (just_hit > 0) just_hit--;
    // ===== ENEMY CONTACT =====
    var enemy = instance_place(x, y, obj_enemy);
    if (enemy != noone && !enemy.marked_for_death && !knockback.IsActive()) {
        // Apply damage and activate invincibility
        damage_sys.TakeDamage(enemy.damage, enemy);
        just_hit = max_just_hit;
		alarm[0] = 1; // Check for death
        // Knockback from enemy
        var kbDir = point_direction(enemy.x, enemy.y, x, y);
        knockback.Apply(kbDir, enemy.knockback.GetSpeed());
        
        // Enemy bounce back
        enemy.hitFlashTimer = 5;
        enemy.knockback.Apply(kbDir + 180, 2);
		
        
        // IMPORTANT: Exit to prevent multiple hits this frame
        return;
    }
    
    // ===== ENEMY PROJECTILES =====
    var projectile = instance_place(x, y, obj_enemy_attack_orb);
    if (projectile != noone) {
        damage_sys.TakeDamage(10, projectile);
		alarm[0] = 1;
        instance_destroy(projectile);
        return;
    }
    
    // ===== SPIKES =====
    var spike = instance_place(x, y, obj_spikes);
    if (spike != noone) {
        var canHit = true;
        for (var i = 0; i < ds_list_size(spike.hitList); i++) {
            if (spike.hitList[| i][0] == id) {
                canHit = false;
                break;
            }
        }
        
        if (canHit) {
            var impactSpeed = knockback.GetSpeed();
            var damage = spike.baseDamage + (impactSpeed * spike.velocityDamageMultiplier);
            damage = clamp(damage, spike.baseDamage, spike.maxDamage);
            
            damage_sys.TakeDamage(round(damage), spike);
            alarm[0] = 1;
            knockback.x_velocity = 0;
            knockback.y_velocity = 0;
            var bounceDir = point_direction(spike.x, spike.y, x, y);
            x += lengthdir_x(5, bounceDir);
            y += lengthdir_y(5, bounceDir);
            
            ds_list_add(spike.hitList, [id, spike.hitCooldown * 2]);
            spike.bloodTimer = 20;
            spike.shake = 3;
            return;
        }
    }
    
    // ===== ROLLING BALL =====
    var ball = instance_place(x, y, obj_rolling_ball);
    if (ball != noone) {
        var canHit = true;
        for (var i = 0; i < ds_list_size(ball.hitList); i++) {
            if (ball.hitList[| i][0] == id) {
                canHit = false;
                break;
            }
        }
        
        if (canHit) {
			alarm[0] = 1;
            damage_sys.TakeDamage(ball.damage, ball);
            
            var kbDir = point_direction(ball.x, ball.y, x, y);
            knockback.Apply(kbDir, ball.knockbackForce);
            
            ball.myDir = point_direction(x, y, ball.x, ball.y);
            ball.levelDecayTimer = 0;
            
            ds_list_add(ball.hitList, [id, ball.hitCooldown]);
            ball.hitFlashTimer = 5;
        }
    }
}


// WEAPON SWITCHING (Keyboard 1/2)


/// @function HandleWeaponSwitching()
/// @description Handle keyboard weapon switching (already in your player Step)
/// This is what you already have - just making sure weapons array is used
function HandleWeaponSwitching() {
    // Switch to slot 0
    if (keyboard_check_pressed(ord("1"))) {
        if (weapons[0] != noone) {
            SwitchToWeaponSlot(0);
        }
    }
    
    // Switch to slot 1
    if (keyboard_check_pressed(ord("2"))) {
        if (weapon_slots > 1 && weapons[1] != noone) {
            SwitchToWeaponSlot(1);
        }
    }
    
    // Scroll wheel switching
    if (mouse_wheel_up()) {
        var next_slot = (current_weapon_index + 1) % weapon_slots;
        if (weapons[next_slot] != noone) {
            SwitchToWeaponSlot(next_slot);
        }
    }
    
    if (mouse_wheel_down()) {
        var prev_slot = (current_weapon_index - 1);
        if (prev_slot < 0) prev_slot = weapon_slots - 1;
        if (weapons[prev_slot] != noone) {
            SwitchToWeaponSlot(prev_slot);
        }
    }
	
	if (keyboard_check_pressed(ord("7"))) {
    if (instance_exists(melee_weapon)) instance_destroy(melee_weapon);
    new_weapon = global.WeaponStruct.ChainWhip;
    melee_weapon = instance_create_depth(x, y, depth-1, obj_chain_whip);
    melee_weapon.owner = id;
    weapon_changed = true;
}
}


