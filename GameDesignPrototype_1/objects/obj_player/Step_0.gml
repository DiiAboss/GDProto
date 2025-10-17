/// @desc Player Step Event - Component-based

if (global.gameSpeed <= 0) {
    if (keyboard_check_pressed(vk_escape)) {
        global.gameSpeed = 1.0;
        global.pause_game = false;
    }
    exit;
}

// ==========================================
// SYSTEM UPDATES
// ==========================================
camera.update();
depth = -y;

// ==========================================
// COMPONENT UPDATES
// ==========================================
timers.Update();
invincibility.Update();
damage_sys.Update();
knockback.Update(self);
class_component.Update(); // CLASS SYSTEM UPDATE

// Sync legacy variables
hp = damage_sys.hp;
invincible = invincibility.active;
invincible_timer = invincibility.timer;

// ==========================================
// LEVEL UP CHECK
// ==========================================
if (experience_points >= exp_to_next_level) {
    experience_points -= exp_to_next_level;
    player_level += 1;
}

// ==========================================
// PAUSE INPUT
// ==========================================
if (keyboard_check_pressed(vk_escape)) {
    global.pause_game = true;
    global.gameSpeed = 0;
    exit;
}

// ==========================================
// STAT RECALCULATION
// ==========================================
stats.Recalculate(function(_atk, _hp, _kb, _spd) {
    return obj_game_manager.gm_calculate_player_stats(_atk, _hp, _kb, _spd);
});

// Apply class-specific modifiers
stats.attack = class_component.ApplyModifiers(stats.attack);

// Sync legacy variables
attack = stats.attack;
mySpeed = stats.speed;
knockbackPower = stats.knockback;
maxHp = stats.hp_max;

// ==========================================
// DAMAGE DETECTION
// ==========================================
if (!invincibility.active) {
    CheckDamage();
}

// ==========================================
// COIN COLLECTION
// ==========================================
if (place_meeting(x, y, obj_coin)) {
    with (instance_place(x, y, obj_coin)) {
        other.gold += 1;
        instance_destroy();
    }
}

// ==========================================
// INPUT UPDATE
// ==========================================
input.Update(self);
mouseDirection = input.Direction;
mouseDistance = distance_to_point(mouse_x, mouse_y);


// ==========================================
// CARRYING SYSTEM
// ==========================================
HandleCarrying();

// ==========================================
// WEAPON SWITCHING
// ==========================================
HandleWeaponSwitching();

// ==========================================
// MOVEMENT
// ==========================================
var _hasMoved = movement.Update(input, scale_movement(mySpeed));
image_speed = scale_animation(_hasMoved ? 0.4 : 0.2);
currentSprite = SpriteHandler.UpdateSpriteByAimDirection(currentSprite, mouseDirection);

// ==========================================
// CHARGE WEAPON
// ==========================================
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

// ==========================================
// WEAPON ATTACKS
// ==========================================
if (input.FirePress) {
    var timing_quality = EvaluateAttackTiming();
    var timing_mult = ApplyTimingBonus(timing_quality);
    
    var attack_result = weaponCurrent.primary_attack(self, mouseDirection, mouseDistance, weaponCurrent.projectile_struct);
    
    if (attack_result != noone) {
        if (weaponCurrent.type == WeaponType.Melee && instance_exists(attack_result)) {
            attack_result.attack *= timing_mult;
            if (timing_quality == "perfect") {
                attack_result.is_perfect_attack = true;
            }
        }
        else if (weaponCurrent.type == WeaponType.Range && instance_exists(attack_result)) {
            if (variable_instance_exists(attack_result, "damage")) {
                attack_result.damage *= timing_mult;
            }
        }
    }
}

if (input.AltPress) {
    weaponCurrent.secondary_attack(self, mouseDirection, mouseDistance, weaponCurrent.projectile_struct);
}

if (variable_struct_exists(weaponCurrent, "step")) {
    weaponCurrent.step(self);
}

UpdateTimingVisuals();




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
            previous_weapon_instance = weaponCurrent; // Store current weapon
            weaponCurrent = global.WeaponStruct.ThrowableItem;
            charge_amount = 0;
            
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

// ==========================================
// DEBUG COMMANDS
// ==========================================
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


// ==========================================
// HELPER FUNCTIONS (at bottom of step)
// ==========================================

/// @func CheckDamage()
function CheckDamage() {
    // ===== ENEMY CONTACT =====
    var enemy = instance_place(x, y, obj_enemy);
    if (enemy != noone && !enemy.marked_for_death && !knockback.IsActive()) {
        // Apply damage and activate invincibility
        damage_sys.TakeDamage(enemy.damage, enemy);
        invincibility.Activate();
        
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

/// @func HandleWeaponSwitching()
function HandleWeaponSwitching() {
    if (keyboard_check_pressed(ord("1"))) {
        if (instance_exists(melee_weapon)) instance_destroy(melee_weapon);
        weaponCurrent = global.WeaponStruct.Bow;
        melee_weapon = noone;
    }
    else if (keyboard_check_pressed(ord("2"))) {
        if (instance_exists(melee_weapon)) instance_destroy(melee_weapon);
        weaponCurrent = global.WeaponStruct.Sword;
        melee_weapon = instance_create_depth(x, y, depth-1, obj_sword);
        melee_weapon.owner = id;
    }
    else if (keyboard_check_pressed(ord("3"))) {
        if (instance_exists(melee_weapon)) instance_destroy(melee_weapon);
        weaponCurrent = global.WeaponStruct.Boomerang;
    }
    else if (keyboard_check_pressed(ord("4"))) {
        if (instance_exists(melee_weapon)) instance_destroy(melee_weapon);
        weaponCurrent = global.WeaponStruct.ChargeCannon;
    }
    else if (keyboard_check_pressed(ord("5"))) {
        if (instance_exists(melee_weapon)) instance_destroy(melee_weapon);
        weaponCurrent = global.WeaponStruct.Dagger;
        melee_weapon = instance_create_depth(x, y, depth-1, obj_dagger);
        melee_weapon.owner = id;
    }
    else if (keyboard_check_pressed(ord("6"))) {
        if (instance_exists(melee_weapon)) instance_destroy(melee_weapon);
        weaponCurrent = global.WeaponStruct.BaseballBat;
        melee_weapon = instance_create_depth(x, y, depth-1, obj_baseball_bat);
        melee_weapon.owner = id;
    }
}