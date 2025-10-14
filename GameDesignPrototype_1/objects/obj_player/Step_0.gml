/// obj_player Step Event

// Update camera
camera.update();

depth = -y;

if (experience_points >= exp_to_next_level)
{
	var _temp_exp = exp_to_next_level - experience_points;
	experience_points = 0;
	player_level += 1;
}

if (keyboard_check_pressed(vk_escape))
{
	global.pause_game = true;
}


function levelUp()
{
	global.gameSpeed = 0;
	
	
	
	if (keyboard_check_pressed(vk_enter))
	{
		global.gameSpeed = 1;
		global.pause_game = false;
	}
}

if (global.pause_game)
{
	levelUp();
}



// obj_player Step Event - ADD this before your existing code

#region Class-Specific Updates (NEW)
switch (character_class) {
    case CharacterClass.WARRIOR:
        var health_percent = hp / hp_max;
        if (health_percent < 0.5) {
            rage_damage_bonus = (0.5 - health_percent) * 2;
            // This will be applied after the game_manager stat calc
        }
        break;
        
    case CharacterClass.HOLY_MAGE:
        if (mana < mana_max) {
            mana += class_stats.mana_regen;
            mana = min(mana, mana_max);
        }
        if (on_blessed_ground) {
            hp += class_stats.blessed_heal / room_speed;
            hp = min(hp, hp_max);
        }
        break;
        
    case CharacterClass.VAMPIRE:
        if (blood_frenzy_timer > 0) {
            blood_frenzy_timer--;
            mySpeed = base_speed * class_stats.blood_frenzy_bonus;
        } else {
            mySpeed = base_speed;
        }
        
        if (is_burning && burn_timer > 0) {
            burn_timer--;
            if (burn_timer % 30 == 0) {
                hp -= 2;
            }
            mySpeed = base_speed * 1.5;
            
            var burn_radius = 50;
            with (obj_enemy) {
                if (point_distance(x, y, other.x, other.y) < burn_radius) {
                    on_fire = true;
                    fire_timer = 120;
                }
            }
        }
        break;
}
#endregion

// Just modify the stat calculation part to include class bonuses:
var stats = obj_game_manager.gm_calculate_player_stats(
    base_attack, hp_max, base_knockback, base_speed
);

attack = stats[0];
maxHp = stats[1];
knockbackPower = stats[2];
mySpeed = stats[3];

// Apply class-specific modifiers AFTER game_manager calculation
if (character_class == CharacterClass.WARRIOR && rage_damage_bonus > 0) {
    attack *= (1 + rage_damage_bonus);
}

depth = -y;

// Always recalc stats with passive mods
var stats = obj_game_manager.gm_calculate_player_stats(
    base_attack, hp_max, base_knockback, base_speed
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
// In weapon switching code:
if (keyboard_check_pressed(ord("1"))) {
    if (instance_exists(melee_weapon)) instance_destroy(melee_weapon);
    weaponCurrent = global.WeaponStruct.Bow;
    melee_weapon = noone; // Ranged weapon, no melee object
    show_debug_message("Switched to Bow");
}

if (keyboard_check_pressed(ord("2"))) {
    if (instance_exists(melee_weapon)) instance_destroy(melee_weapon);
    weaponCurrent = global.WeaponStruct.Sword;
    melee_weapon = instance_create_depth(x, y, depth-1, obj_sword);
    melee_weapon.owner = id;
    show_debug_message("Switched to Sword");
}

if (keyboard_check_pressed(ord("5"))) {
    if (instance_exists(melee_weapon)) instance_destroy(melee_weapon);
    weaponCurrent = global.WeaponStruct.Dagger;
    melee_weapon = instance_create_depth(x, y, depth-1, obj_dagger);
    melee_weapon.owner = id;
    show_debug_message("Switched to Dagger");
}
if (keyboard_check_pressed(ord("3"))) {
	if (instance_exists(melee_weapon)) instance_destroy(melee_weapon);
    weaponCurrent = global.WeaponStruct.Boomerang;
    show_debug_message("Switched to Boomerang");
}
if (keyboard_check_pressed(ord("4"))) {
	if (instance_exists(melee_weapon)) instance_destroy(melee_weapon);
    weaponCurrent = global.WeaponStruct.ChargeCannon;
    show_debug_message("Switched to Charge Cannon");
}

if (keyboard_check_pressed(ord("6"))) {
    if (instance_exists(melee_weapon)) instance_destroy(melee_weapon);
    weaponCurrent = global.WeaponStruct.BaseballBat;
    melee_weapon = instance_create_depth(x, y, depth-1, obj_baseball_bat);
    melee_weapon.owner = id;
    show_debug_message("Switched to Baseball Bat");
}

// ===================================
// MOVEMENT
// ===================================
var _hasMoved = movement.Update(input);
image_speed = _hasMoved ? 0.4 : 0.2;
currentSprite = SpriteHandler.UpdateSpriteByAimDirection(currentSprite, mouseDirection);



#region Charge Weapon Handling
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
#endregion


#region Weapon Attacks
// ===================================
// WEAPON ATTACKS
// ===================================
if (input.FirePress) {
    weaponCurrent.primary_attack(self, mouseDirection, mouseDistance, weaponCurrent.projectile_struct);
}

if (input.AltPress) {
    weaponCurrent.secondary_attack(self, mouseDirection, mouseDistance, weaponCurrent.projectile_struct);
}
#endregion


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

// ===================================
// CAMERA DEBUG CONTROLS
// ===================================
#region Camera Debug Keys

// Screen Shake
if (keyboard_check_pressed(vk_f1)) {
    camera.add_shake(5);
    show_debug_message("Light shake applied");
}

if (keyboard_check_pressed(vk_f2)) {
    camera.add_shake(15);
    show_debug_message("Heavy shake applied");
}

// Zoom Controls
if (keyboard_check_pressed(vk_f3)) {
    camera.set_zoom(1.5);
    show_debug_message("Zoom: 1.5x (Boss Fight)");
}

if (keyboard_check_pressed(vk_f4)) {
    camera.set_zoom(0.8);
    show_debug_message("Zoom: 0.8x (Arena View)");
}

if (keyboard_check_pressed(vk_f5)) {
    camera.set_zoom(1.0);
    show_debug_message("Zoom: 1.0x (Normal)");
}

// Pan to Nearest Enemy
if (keyboard_check_pressed(vk_f6)) {
    var nearest = instance_nearest(x, y, obj_enemy);
    if (instance_exists(nearest)) {
        camera.pan_to(nearest.x, nearest.y, function() {
            show_debug_message("Camera reached enemy!");
        });
        show_debug_message("Panning to enemy at " + string(nearest.x) + ", " + string(nearest.y));
    } else {
        show_debug_message("No enemy found to pan to");
    }
}

// Lock Camera at Room Center
if (keyboard_check_pressed(vk_f7)) {
    camera.lock_at(room_width / 2, room_height / 2);
    show_debug_message("Camera locked at room center");
}

// Unlock Camera (Return to Following Player)
if (keyboard_check_pressed(vk_f8)) {
    camera.unlock();
    show_debug_message("Camera unlocked - following player");
}

// Toggle Bounds
if (keyboard_check_pressed(vk_f9)) {
    if (camera.use_bounds) {
        camera.remove_bounds();
        show_debug_message("Camera bounds removed - free camera");
    } else {
        camera.set_bounds(280, 88, 1064, 648);
        show_debug_message("Camera bounds enabled");
    }
}

// Adjust Follow Speed (hold SHIFT for slower)
if (keyboard_check_pressed(vk_f10)) {
    if (keyboard_check(vk_shift)) {
        camera.follow_speed = max(0.05, camera.follow_speed - 0.05);
        show_debug_message("Follow speed: " + string(camera.follow_speed) + " (slower)");
    } else {
        camera.follow_speed = min(1.0, camera.follow_speed + 0.05);
        show_debug_message("Follow speed: " + string(camera.follow_speed) + " (faster)");
    }
}

#endregion



// Test score
if (keyboard_check_pressed(ord("7"))) {
    if (instance_exists(obj_ui_manager)) {
        obj_ui_manager.ui.add_score(100);
        show_debug_message("Added 100 score");
    }
}

// Test badges
if (keyboard_check_pressed(ord("8"))) {
    if (instance_exists(obj_ui_manager)) {
        obj_ui_manager.ui.show_badge(UI_BADGE_TYPE.DOUBLE_KILL);
    }
}

if (keyboard_check_pressed(ord("9"))) {
    if (instance_exists(obj_ui_manager)) {
        obj_ui_manager.ui.show_badge(UI_BADGE_TYPE.TRIPLE_KILL);
    }
}




if (place_meeting(x, y, obj_coin))
{
	with (instance_place(x, y, obj_coin))
{
	instance_destroy();
}
}