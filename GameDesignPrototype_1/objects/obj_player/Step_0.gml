/// obj_player Step Event

depth = -y;

// Always recalc stats with passive mods
var stats = obj_game_manager.gm_calculate_player_stats(
    base_attack, base_maxHp, base_knockback, base_speed
);

attack         = stats[0];
maxHp          = stats[1];
knockbackPower = stats[2];
mySpeed        = stats[3];

// ===================================
// INPUT UPDATE
// ===================================
input.Update(self);
mouseDirection = input.Direction;
mouseDistance = distance_to_point(mouse_x, mouse_y);

// ===================================
// WEAPON SWITCHING
// ===================================
if (keyboard_check_pressed(ord("1"))) {
    weaponCurrent = Weapon_.Bow;
    show_debug_message("Switched to Bow");
}
if (keyboard_check_pressed(ord("2"))) {
    weaponCurrent = Weapon_.Sword;
    show_debug_message("Switched to Sword");
}
if (keyboard_check_pressed(ord("3"))) {
    weaponCurrent = Weapon_.Boomerang;
    show_debug_message("Switched to Boomerang");
}
if (keyboard_check_pressed(ord("4"))) {
    weaponCurrent = Weapon_.ChargeCannon;
    show_debug_message("Switched to Charge Cannon");
}

// ===================================
// MOVEMENT
// ===================================
var _hasMoved = movement.Update(input);
image_speed = _hasMoved ? 0.4 : 0.2;
currentSprite = SpriteHandler.UpdateSpriteByAimDirection(currentSprite, mouseDirection);

// ===================================
// CHARGE WEAPON HANDLING
// ===================================
if (variable_struct_exists(weaponCurrent, "charge_rate")) {
    // Right-click: Start/continue charging
    if (mouse_check_button(mb_right)) {
        is_charging = true;
        charge_amount = min(charge_amount + weaponCurrent.charge_rate, 1.0);
        
        // Visual feedback at full charge
        if (charge_amount >= 1.0 && current_time % 10 == 0) {
            // Spawn charge particles around player
        }
    }
    
    // Release right-click: Stop charging (but keep charge stored)
    if (mouse_check_button_released(mb_right)) {
        is_charging = false;
    }
    
    // Natural charge decay when not charging
    if (!is_charging && charge_amount > 0) {
        charge_amount = max(charge_amount - 0.005, 0);
    }
}

// ===================================
// WEAPON ATTACKS
// ===================================
if (input.FirePress) {
    weaponCurrent.primary_attack(self, mouseDirection, mouseDistance, weaponCurrent.projectile_struct);
}

if (input.AltPress) {
    weaponCurrent.secondary_attack(self, mouseDirection, mouseDistance, weaponCurrent.projectile_struct);
}

// ===================================
// WEAPON STEP UPDATE
// ===================================
// Update current weapon (cooldowns, timers, etc)
if (variable_struct_exists(weaponCurrent, "step")) {
    weaponCurrent.step(self);
}

// ===================================
// KNOCKBACK PHYSICS
// ===================================
if (abs(knockbackX) > 0.1 || abs(knockbackY) > 0.1) {
    var nextX = x + knockbackX;
    var nextY = y + knockbackY;
    
    var hitHorizontal = false;
    var hitVertical = false;
    
    // Check for wall collision
    if (place_meeting(nextX * 1.01, nextY * 1.01, obj_wall)) {
        if (place_meeting(nextX * 1.01, y, obj_wall)) {
            hitHorizontal = true;
        }
        
        if (place_meeting(x, nextY * 1.01, obj_wall)) {
            hitVertical = true;
        }
        
        // Apply bounces with dampening
        if (hitHorizontal && abs(knockbackX)) {
            knockbackX = -knockbackX;
        } else if (hitHorizontal) {
            knockbackX = 0;
        }
        
        if (hitVertical && abs(knockbackY)) {
            knockbackY = -knockbackY;
        } else if (hitVertical) {
            knockbackY = 0;
        }
    }
    
    // Move to new position if not blocked
    if (!place_meeting(x + knockbackX, y, obj_wall)) {
        x += knockbackX;
    }
    if (!place_meeting(x, y + knockbackY, obj_wall)) {
        y += knockbackY;
    }
    
    knockbackX *= knockbackFriction;
    knockbackY *= knockbackFriction;
}

// ===================================
// DEBUG COMMANDS
// ===================================
if (keyboard_check_pressed(ord("M"))) {
    AddModifier(id, "TripleRhythmFire");
    show_debug_message("Added TripleRhythmFire - modifier count: " + string(array_length(mod_list)));
}

if (keyboard_check_pressed(ord("Q"))) {
    var _near_enemy = instance_nearest(x, y, obj_enemy);
    if (instance_exists(_near_enemy)) {
        scr_chain_lightning(self, _near_enemy, 10, 256, 100, 10);
    }
}

if (keyboard_check_pressed(ord("0"))) {
    AddModifier(id, "MultiShot");
    show_debug_message("Added MultiShot modifier");
}