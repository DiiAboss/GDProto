/// @description Insert description here

depth = -y;

// Always recalc stats with passive mods
var stats = obj_game_manager.gm_calculate_player_stats(
    base_attack, base_maxHp, base_knockback, base_speed
);

attack        = stats[0];
maxHp         = stats[1];
knockbackPower= stats[2];
mySpeed       = stats[3];


input.Update(self);
mouseDirection = input.Direction;
mouseDistance = distance_to_point(mouse_x, mouse_y);


var _hasMoved = movement.Update(input)

image_speed = _hasMoved ? 0.4 : 0.2;
currentSprite = SpriteHandler.UpdateSpriteByAimDirection(currentSprite, mouseDirection);

if (input.FirePress)
{
	weaponCurrent.primary_attack(self, mouseDirection, mouseDistance, weaponCurrent.projectile_struct);
}
if (input.AltPress)
{
	weaponCurrent.secondary_attack(self, mouseDirection, mouseDistance, weaponCurrent.projectile_struct);
}





// Attack input - trigger sword swing
if (mouse_check_button_pressed(mb_left) && currentWeapon == Weapon.Sword) {
    sword.attack = attack;
	sword.startSwing = true;
}

// Update timers
if (attack_cooldown > 0) attack_cooldown--;
if (combo_window > 0) combo_window--;

// Update buffer timeouts
for (var i = array_length(attack_buffer) - 1; i >= 0; i--) {
    attack_buffer[i].timeout--;
    if (attack_buffer[i].timeout <= 0) {
        array_delete(attack_buffer, i, 1);
    }
}

// Check cancel window
can_cancel = false;
if (combo_state != ComboState.IDLE && combo_state < array_length(combo_data)) {
    var current_combo = combo_data[combo_state];
    if (current_combo.cancel_start >= 0) { // Has cancel window
        var progress = current_combo.duration - attack_cooldown;
        can_cancel = (progress >= current_combo.cancel_start && progress <= current_combo.cancel_end);
    }
}

// Reset combo if window expires
if (combo_window <= 0 && combo_state != ComboState.IDLE) {
    combo_state = ComboState.IDLE;
}

// Input Detection
if (mouse_check_button_pressed(mb_left) && currentWeapon == Weapon.Sword) {
    add_input_to_buffer(AttackType.LIGHT);
}

if (mouse_check_button_pressed(mb_right) && currentWeapon == Weapon.Sword) {
    add_input_to_buffer(AttackType.HEAVY);
}

if (keyboard_check_pressed(vk_space)) {
    add_input_to_buffer(AttackType.DASH);
}

// Process buffer
process_attack_buffer();

// ===========================================
// HELPER FUNCTIONS
// ===========================================

function add_input_to_buffer(input_type) {
    if (array_length(attack_buffer) >= attack_buffer_max) return;
    
    array_push(attack_buffer, {
        type: input_type,
        timeout: attack_buffer_timeout
    });
	show_debug_message(string(attack_buffer));
}

function process_attack_buffer() {
	
	if (array_length(attack_buffer) == 0) return;
    if (attack_cooldown > 0 && !can_cancel) return;
    
    var input = attack_buffer[0];
    var next_state = get_next_combo_state(combo_state, input.type);
    
    if (next_state >= 0) {
        if (next_state == ComboState.IDLE) {
            // Dash interrupt
            execute_dash();
        } else {
            execute_attack(next_state);
        }
        array_delete(attack_buffer, 0, 1);
    }
}

function get_next_combo_state(current_state, input_type) {
    // Handle dash special case - can interrupt during cancel windows
    if (input_type == AttackType.DASH && (combo_state == ComboState.IDLE || can_cancel)) {
        return ComboState.IDLE; // Return to idle for dash
    }
    
    // Normal combo transitions
    if (current_state < array_length(combo_transitions) && 
        input_type < array_length(combo_transitions[current_state])) {
        
        var next_state = combo_transitions[current_state][input_type];
        
        // Check if we can actually perform this transition
        if (next_state >= 0 && (combo_state == ComboState.IDLE || can_cancel || attack_cooldown <= 0)) {
            return next_state;
        }
    }
    
    return -1; // Invalid transition
}

function execute_attack(new_combo_state) {
    combo_state = new_combo_state;
    var combo_info = combo_data[new_combo_state];
    
    attack_cooldown = combo_info.duration;
    combo_window = combo_window_max;
    
    // Apply to sword
    if (instance_exists(sword)) {
        sword.attack = attack * combo_info.damage_mult;
        sword.knockbackForce = (64 + (sword.comboCount * 1)) * combo_info.knockback_mult;
        sword.startSwing = true;
        sword.current_combo_state = new_combo_state;
    }
    
    // Effects
    create_attack_effects(new_combo_state);
}

function execute_dash() {
    combo_state = ComboState.IDLE;
    attack_cooldown = 0;
    combo_window = 0;
    
    // Your dash logic here
    show_debug_message("DASH!");
}

function create_attack_effects(combo_state) {
    switch (combo_state) {
        case ComboState.LIGHT_1:
        case ComboState.LIGHT_2:
            // Light attack effects
            break;
        case ComboState.LIGHT_3:
            // Light finisher effects
            break;
        case ComboState.HEAVY_1:
            // Heavy attack effects
            break;
        case ComboState.HEAVY_FINISHER:
            // Heavy finisher effects
            break;
    }
}


// Apply knockback from DVD ball or other sources
if (abs(knockbackX) > 0.1 || abs(knockbackY) > 0.1) {
     // Store original position
    var prevX = x;
    var prevY = y;
    
    // Try to move
    var nextX = x + knockbackX;
    var nextY = y + knockbackY;
    
    var hitHorizontal = false;
    var hitVertical = false;
    
    // Check both axes simultaneously for corner detection
    if (place_meeting(nextX * 1.01, nextY * 1.01, obj_wall)) {
        // We hit something, figure out what
        
        // Check horizontal collision
        if (place_meeting(nextX * 1.01, y, obj_wall)) {
            hitHorizontal = true;
        }
        
        // Check vertical collision
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


// Cannon cooldown
if (cannonCooldown > 0) {
    cannonCooldown--;
}

// Modified CANNON ABILITY
if (mouse_check_button_pressed(mb_right) && cannonCooldown <= 0) {
    mouseDistance = distance_to_point(mouse_x, mouse_y);
    
    // Create the cannonball first
    var cannonball = instance_create_depth(x, y, depth, obj_projectile);
    cannonball.direction = mouseDirection;
    cannonball.speed = 15;
    cannonball.owner = id;
    
    // Launch player backwards
    var cannonForce = 25;
    knockbackX = lengthdir_x(-cannonForce, mouseDirection);
    knockbackY = lengthdir_y(-cannonForce, mouseDirection);
    knockbackPower = cannonForce;
    
    isCannonBalling = true;
    cannonCooldown = cannonCooldownMax;
    
    // TRIGGER MODIFIERS - Pass the projectile reference
    var attack_event = {
        attack_type: "cannon",
        attack_direction: mouseDirection,
        attack_position_x: x,
        attack_position_y: y,
        projectile: cannonball,  // Pass the actual projectile
        damage: attack * 2,
        weapon: undefined
    };
    
    TriggerModifiers(id, MOD_TRIGGER.ON_ATTACK, attack_event);
}


// Update cannonball state
if (isCannonBalling) {
	
    // Check if we've slowed down enough
    if (abs(knockbackX) < 2 && abs(knockbackY) < 2) {
        isCannonBalling = false;
    }
    
    // Trail effect while cannonballing
    if (current_time % 2 == 0) {
        // Create afterimage or particle
    }
}



// In Player Step Event - Debug modifier adding
if (keyboard_check_pressed(ord("M"))) {
    AddModifier(id, "TripleRhythmFire");
    show_debug_message("Added TripleRhythmFire - attack count: " + string(array_length(mod_list)));
}


if (keyboard_check_pressed((ord("Q"))))
{
	var _near_enemy = instance_nearest(x, y, obj_enemy);
	scr_chain_lightning(self, _near_enemy, 10, 256, 100, 10)
}