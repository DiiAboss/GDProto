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
class_component.Update(); // CLASS SYSTEM UPDATE




// Sync legacy variables
hp = damage_sys.hp;
invincible = invincibility.active;
invincible_timer = invincibility.timer;
total_damage_taken = 0;


while (experience_points >= exp_to_next_level) {
    experience_points -= exp_to_next_level;
    player_level += 1;
    exp_to_next_level = calculate_exp_requirement(player_level);
    
    // NEW: Trigger level up with popup
    //TriggerLevelUp();
	on_level_up();
}



/// @function TriggerLevelUp()
function TriggerLevelUp() {
    // Heal on level up
    //hp = min(hp + (maxHp * 0.2), maxHp);
    
    // Tell game manager to show popup
    var _gm = obj_game_manager;
    _gm.ShowLevelUpPopup(_gm.can_click);
    
    UpdateMission("reach_level_5", 1);
    show_debug_message("Level Up! Now level " + string(player_level));
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
    
    show_debug_message("Level Up! Starting slowdown sequence");
}






// DAMAGE DETECTION

if (!invincibility.active) {
    CheckDamage();
}


// COIN COLLECTION

if (place_meeting(x, y, obj_coin)) {
    with (instance_place(x, y, obj_coin)) {
        other.gold += 1;
        instance_destroy();
    }
}


// INPUT UPDATE

//input.Update(self);
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

if (weaponCurrent)
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
	
	// When player attacks (in your FirePress section)
	if (input.FirePress) {
	    // Evaluate timing
	    if (attack_timing_window > 0 && attack_timing_window <= perfect_timing_threshold) {
	        last_timing_quality = "perfect";
	    } else if (attack_timing_window > 0 && attack_timing_window <= perfect_timing_threshold * 2) {
	        last_timing_quality = "good";
	    } else {
	        last_timing_quality = "normal";
	    }
	    
	    // Reset window for next attack
	    attack_timing_window = 60; // 1 second window
	 
		
	    // Your existing attack code...
	    var attack_result = weaponCurrent.primary_attack(self, mouseDirection, mouseDistance, weaponCurrent.projectile_struct);
		if (attack_result && switch_near_enemy > 0)
		{
			AwardStylePoints("WEAPON SWAP", 5, 1);
		}
	}
	
	if (input.AltPress) {
	    weaponCurrent.secondary_attack(self, mouseDirection, mouseDistance, weaponCurrent.projectile_struct);
		show_debug_message("AltrFire Pressed");
	}
	
	if (variable_struct_exists(weaponCurrent, "step")) {
	    weaponCurrent.step(self);
	}
	
	UpdateTimingVisuals();
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
            ThrowCarriedObject();
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
            
            // DEBUG: Check if weapon has synergy tags
            show_debug_message("=== PICKUP DEBUG ===");
            if (variable_struct_exists(weaponCurrent, "synergy_tags")) {
                show_debug_message("ThrowableItem has synergy_tags");
            } else {
                show_debug_message("ThrowableItem MISSING synergy_tags!");
            }
            
            // Update synergy tags for throwable weapon
            // NOTE: We're not switching weapon slots, just weaponCurrent reference
            // So we need to temporarily put it in the weapons array
            var temp_weapon = weapons[current_weapon_index];
            weapons[current_weapon_index] = weaponCurrent;
            UpdateWeaponTags(id, current_weapon_index);
            weapons[current_weapon_index] = temp_weapon; // Restore original
            
            show_debug_message("Combined tags: " + active_combined_tags.DebugPrint());
            show_debug_message("Active synergies: " + string(active_synergies));
            show_debug_message("===================");
            
            if (variable_instance_exists(nearest, "OnPickedUp")) {
                nearest.OnPickedUp(id);
            }
            
            show_debug_message("Picked up: " + object_get_name(nearest.object_index));
        }
    }
}

/// @func ThrowCarriedObject()
function ThrowCarriedObject() {
    if (!instance_exists(carried_object)) {
        is_carrying = false;
        carried_object = noone;
        return;
    }
    
    var obj = carried_object;
    
    // Release object
    is_carrying = false;
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
            
            show_debug_message("Applied synergies to thrown object. Synergies: " + string(active_synergies));
        }
        
        // Call throw event (for custom behavior)
        if (variable_instance_exists(obj, "OnThrown")) {
            obj.OnThrown(id, throw_dir);
        }
    }
    
    carried_object = noone;
    stats.temp_speed_mult = 1.0; // Restore speed
    weaponCurrent = previous_weapon_instance;
    show_debug_message("Threw object!");
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


// DEBUG COMMANDS

#region Debug
if (keyboard_check_pressed(ord("M"))) AddModifier(id, "TripleRhythmFire");
if (keyboard_check_pressed(ord("Q"))) {
    var _near = instance_nearest(x, y, obj_enemy);
    if (instance_exists(_near)) scr_chain_lightning(self, _near, 10, 256, 10, 10);
}
if (keyboard_check_pressed(ord("0"))) AddModifier(id, "MultiShot");

// Camera debug
if (keyboard_check_pressed(vk_f1)) camera.add_shake(5);
if (keyboard_check_pressed(vk_f2)) camera.add_shake(15);
if (keyboard_check_pressed(vk_f3)) camera.set_zoom(1.5);
if (keyboard_check_pressed(vk_f4)) camera.set_zoom(0.8);
if (keyboard_check_pressed(vk_f5)) camera.set_zoom(1.0);
#endregion







// HELPER FUNCTIONS


/// @func CheckDamage()
function CheckDamage() {
	
	
	if (just_hit > 0) just_hit--;
    // ===== ENEMY CONTACT =====
    var enemy = instance_place(x, y, obj_enemy);
    if (enemy != noone && !enemy.marked_for_death && !knockback.IsActive()) {
        // Apply damage and activate invincibility
        damage_sys.TakeDamage(enemy.damage, enemy);
        invincibility.Activate();
        just_hit = 30;
        // Knockback from enemy
        var kbDir = point_direction(enemy.x, enemy.y, x, y);
        knockback.Apply(kbDir, enemy.knockbackForce);
        
        // Enemy bounce back
        enemy.knockbackX = lengthdir_x(2, kbDir + 180);
        enemy.knockbackY = lengthdir_y(2, kbDir + 180);
        enemy.hitFlashTimer = 5;
        
        // Show HP bar
        timers.Set("hp_bar", 120);
        
        // IMPORTANT: Exit to prevent multiple hits this frame
        return;
    }
    
    // ===== ENEMY PROJECTILES =====
    var projectile = instance_place(x, y, obj_enemy_attack_orb);
    if (projectile != noone) {
        damage_sys.TakeDamage(10, projectile);
        invincibility.Activate();
        instance_destroy(projectile);
        timers.Set("hp_bar", 120);
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
            invincibility.Activate();
            
            knockback.x_velocity = 0;
            knockback.y_velocity = 0;
            var bounceDir = point_direction(spike.x, spike.y, x, y);
            x += lengthdir_x(5, bounceDir);
            y += lengthdir_y(5, bounceDir);
            
            ds_list_add(spike.hitList, [id, spike.hitCooldown * 2]);
            spike.bloodTimer = 20;
            spike.shake = 3;
            
            timers.Set("hp_bar", 120);
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
            damage_sys.TakeDamage(ball.damage, ball);
            invincibility.Activate();
            
            var kbDir = point_direction(ball.x, ball.y, x, y);
            knockback.Apply(kbDir, ball.knockbackForce);
            
            ball.myDir = point_direction(x, y, ball.x, ball.y);
            ball.levelDecayTimer = 0;
            
            ds_list_add(ball.hitList, [id, ball.hitCooldown]);
            ball.hitFlashTimer = 5;
            
            timers.Set("hp_bar", 120);
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


//// DEBUG: Give random weapon
//if (keyboard_check_pressed(vk_f6)) {
    //var test_weapon = choose(Weapon.Sword, Weapon.Bow, Weapon.BaseballBat);
    //GiveWeapon(self, test_weapon);
//}

if (keyboard_check_pressed(vk_f6)) {
    // Direct score add test
    if (instance_exists(obj_game_manager)) {
        obj_game_manager.score_manager.AddScore(100);
        var current = obj_game_manager.score_manager.GetScore();
        show_debug_message("Added 100 score. Total now: " + string(current));
    }
}


// DEATH CHECK

if (hp <= 0 && instance_exists(obj_main_controller) && !obj_main_controller.death_sequence_active) {
    // Trigger death sequence through main controller
    obj_main_controller.death_sequence.Trigger(
    obj_game_manager,
    obj_player,
    obj_main_controller.highscore_system
);
    
    // Stop player movement
    hsp = 0;
    vsp = 0;
    
    // Optional: Change sprite to death sprite if you have one
    // sprite_index = spr_player_death;
}


// In obj_player Step_0
if (keyboard_check_pressed(vk_f5)) {
    show_debug_message("===== SYNERGY DEBUG =====");
    
    // Better character tag display
    if (variable_instance_exists(id, "synergy_tags")) {
        var char_tags = synergy_tags.GetAllTags();
        var char_str = "";
        for (var i = 0; i < array_length(char_tags); i++) {
            char_str += GetTagName(char_tags[i]);
            if (i < array_length(char_tags) - 1) char_str += ", ";
        }
        show_debug_message("Character Tags: " + char_str);
    }
    
    // Better weapon tag display
    if (weapons[current_weapon_index] != noone) {
        var weapon = weapons[current_weapon_index];
        if (variable_struct_exists(weapon, "synergy_tags")) {
            var weap_tags = weapon.synergy_tags.GetAllTags();
            var weap_str = "";
            for (var i = 0; i < array_length(weap_tags); i++) {
                weap_str += GetTagName(weap_tags[i]);
                if (i < array_length(weap_tags) - 1) weap_str += ", ";
            }
            show_debug_message("Weapon Tags: " + weap_str);
        }
    }
    
    // Combined tags
    if (variable_instance_exists(id, "active_combined_tags")) {
        var combined = active_combined_tags.GetAllTags();
        var comb_str = "";
        for (var i = 0; i < array_length(combined); i++) {
            comb_str += GetTagName(combined[i]);
            if (i < array_length(combined) - 1) comb_str += ", ";
        }
        show_debug_message("Combined Tags: " + comb_str);
    }
    
    // Active synergies
    if (variable_instance_exists(id, "active_synergies")) {
        var syn_str = "";
        for (var i = 0; i < array_length(active_synergies); i++) {
            syn_str += GetTagName(active_synergies[i]);
            if (i < array_length(active_synergies) - 1) syn_str += ", ";
        }
        show_debug_message("Active Synergies: " + syn_str);
    }
}


// Temporary test - press F6 to manually update tags
if (keyboard_check_pressed(vk_f6)) {
    if (weapons[current_weapon_index] != noone) {
        UpdateWeaponTags(self, current_weapon_index);
        show_debug_message("Force updated weapon tags!");
    }
}



if (keyboard_check_pressed(ord("1"))) {
    status.ApplyStatusEffect(ELEMENT.FIRE, {damage: 5, duration: 180});
}
if (keyboard_check_pressed(ord("2"))) {
    status.ApplyStatusEffect(ELEMENT.ICE, {slow_mult: 0.4, duration: 180});
}
if (keyboard_check_pressed(ord("3"))) {
    status.ApplyStatusEffect(ELEMENT.POISON, {damage: 2, duration: 240});
}
if (keyboard_check_pressed(ord("4"))) {
    status.ApplyStatusEffect(ELEMENT.LIGHTNING, {duration: 90});
}


if (keyboard_check_pressed(vk_f9)) {
    show_debug_message("=== WEAPON SLOTS DEBUG ===");
    show_debug_message("Total slots: " + string(weapon_slots));
    show_debug_message("Current weapon index: " + string(current_weapon_index));
    
    for (var i = 0; i < weapon_slots; i++) {
        var w = weapons[i];
        var _status = "EMPTY";
        if (w != noone) {
            _status = w.name;
        }
        show_debug_message("Slot " + string(i) + ": " + _status);
    }
}
