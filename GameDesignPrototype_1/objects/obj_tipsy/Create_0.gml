/// @description obj_tipsy - Create Event
event_inherited();

// OVERRIDE BOSS PARENT SETTINGS
boss_name = "TIPSY";
damage_sys = new DamageComponent(self, 1000);
maxHp = 500;
hp = 500;
sky_target_y = -200;
sky_jump_progress = 0;

show_crash_shadow = false;
shadow_locked = false;
sky_jump_y = y;


enum TIPSY_STATE {
    CHILL,
    LESSCHILL,
    FRUSTRATED,
    ANGRY,
    ENEMY,
    JUMPING,
    CHARGING,
    SKY_ATTACK,
    CRASHING,      // NEW STATE
    FEEDING,
    BONUS_ARENA,
    REWARDING,
    DEFEATED
}

state = TIPSY_STATE.CHILL;
hit_count = 0;

// GOLD PAYMENT SYSTEM
gold_paid = 0;
gold_required = 100;
gold_payment_increment = 10; // Minimum payment amount

jump_start_x = x;
jump_start_y = y;

// LID SYSTEM
lid_is_open = false;
lid_object = noone;
lid_return_timer = 0;

// JUMP ATTACK VARIABLES
jump_height = 0;
jump_target_height = 80;
jump_timer = 0;
jump_duration = 30; // Frames to reach peak
landing_timer = 0;
shadow_x = x;
shadow_y = y;
shadow_scale = 1.0;

// ATTACK PATTERN
jumps_completed = 0;
jumps_per_cycle = 3;
charge_timer = 0;
charge_duration = 120; // 2 seconds
sky_timer = 0;
sky_duration = 300; // 5 seconds
crash_timer = 0;

// LIL TIPSY SPAWNING
lil_tipsy_spawn_timer = 0;
lil_tipsy_spawn_rate = 60; // Every second
lil_tipsy_max = 10;

// VISUAL
sprite_index = spr_tipsy;
lid_sprite = spr_tipsy_top;
draw_lid = true;

// TIMING SYSTEM (replaces alarms)
intro_dialogue_timer = 0;
intro_camera_return_timer = 0;
bonus_arena_transition_timer = 0;
jump_start_timer = 0;
ripple_timer_1 = 0;
ripple_timer_2 = 0;
ripple_timer_3 = 0;
lid_reattach_timer = 0;
death_explosion_timer = 0;
lid_drop_timer = 0;
shadow_lock_timer = 0;
crash_down_timer = 0;
sky_jump_y_position_x = x;
sky_jump_y_position_y = y;
crash_down_progress = 0;


context_sens = noone;

/// @function PayGold()
PayGold = function() {
    if (!instance_exists(obj_player)) return;
    
    var player = obj_player;
    
    // Check if player has enough gold for minimum payment
    if (player.gold < gold_payment_increment) {
        obj_main_controller.textbox_system.Show("TIPSY", "NOT ENOUGH COIN!", false);
        return;
    }
    
    // Determine payment amount (up to remaining needed)
    var remaining = gold_required - gold_paid;
    var payment = min(player.gold, min(gold_payment_increment, remaining));
    
    // Deduct gold from player
    player.gold -= payment;
    gold_paid += payment;
    
    // De-escalate state if angry (but gold counts toward total)
    if (state > TIPSY_STATE.CHILL && state < TIPSY_STATE.ENEMY) {
        state--;
        obj_main_controller.textbox_system.Show("TIPSY", "OKAY! TIPSY FORGIVE!", false);
    } else if (state == TIPSY_STATE.CHILL) {
        obj_main_controller.textbox_system.Show("TIPSY", "YUM YUM! MORE!", false);
    }
    
    // Spawn healing ripple
    var ripple = instance_create_depth(x, y, depth, obj_ripple_attack);
    ripple.target = obj_enemy; // Damages enemies only
    
    // Check if fully paid
    if (gold_paid >= gold_required) {
        StartBonusArena();
    }
    
    UpdateContextPrompt();
}



/// @function UpdateContextPrompt()
UpdateContextPrompt = function() {
    if (!instance_exists(context_sens)) return;
    
    if (state == TIPSY_STATE.ENEMY) {
        context_sens.can_interact = false;
        context_sens.show_prompt = false;
    } else {
        var remaining = gold_required - gold_paid;
        context_sens.prompt_text = "Press E - Pay Gold (" + string(remaining) + " needed)";
        context_sens.can_interact = true;
    }
}

/// @function StartBonusArena()
StartBonusArena = function() {
    state = TIPSY_STATE.FEEDING;
    
    if (instance_exists(context_sens)) {
        context_sens.can_interact = false;
    }
    
    obj_main_controller.textbox_system.Show("TIPSY", "TIPSY FULL! TIME FOR GAME!", true);
    bonus_arena_transition_timer = 120;
}

/// @function OnMeleeHit()
OnMeleeHit = function() {
    // Only count hits if not in boss mode yet
    if (state >= TIPSY_STATE.ENEMY) return;
    
    hit_count++;
    
    // Escalate state
    switch(state) {
        case TIPSY_STATE.CHILL:
            state = TIPSY_STATE.LESSCHILL;
            obj_main_controller.textbox_system.Show("TIPSY", "OW! DON'T HIT TIPSY!", false);
            break;
            
        case TIPSY_STATE.LESSCHILL:
            state = TIPSY_STATE.FRUSTRATED;
            obj_main_controller.textbox_system.Show("TIPSY", "TIPSY GETTING ANGRY!", false);
            break;
            
        case TIPSY_STATE.FRUSTRATED:
            state = TIPSY_STATE.ANGRY;
            obj_main_controller.textbox_system.Show("TIPSY", "LAST CHANCE! PAY NOW!", false);
            break;
            
        case TIPSY_STATE.ANGRY:
            state = TIPSY_STATE.ENEMY;
            StartBossFight();
            break;
    }
    
    UpdateContextPrompt();
}

/// @function StartBossFight()
StartBossFight = function() {
    obj_main_controller.textbox_system.Show("TIPSY", "TOO LATE! TIPSY SMASH YOU!", true);
    PlayBossIntro("YOU ASKED FOR THIS!");
    jumps_completed = 0;
    jump_start_timer = 180; // 3 seconds
}

/// @function OnBossDefeated()
OnBossDefeated = function() {
    state = TIPSY_STATE.DEFEATED;
    
    if (draw_lid) {
        lid_object = instance_create_depth(x, y, depth, obj_tipsy_lid);
        lid_object.myDir = 90;
        lid_object.mySpeed = 20;
    }
    
    death_explosion_timer = 30; // 0.5 seconds
}

/// @function TakeBossDamage(_damage, _attacker)
TakeBossDamage = function(_damage, _attacker) {
    var final_damage = _damage;
    
    // Apply damage multipliers
    if (instance_exists(_attacker)) {
        // Check for thrown rocks
        if (_attacker.object_index == obj_rock && _attacker.is_projectile) {
            final_damage *= damage_multiplier_rock;
        }
        // Check for thrown baseballs
        else if (_attacker.object_index == obj_baseball_ground && _attacker.is_projectile) {
            final_damage *= damage_multiplier_baseball;
        }
        // Standard damage
        else {
            final_damage *= damage_multiplier_standard;
        }
    }
    
    // Apply damage
    damage_sys.TakeDamage(final_damage, _attacker);
    hitFlashTimer = 10;
    shake = 5;
    
    return final_damage;
}

/// @function ShowHealthBar()
ShowHealthBar = function() {
    healthbar_visible = true;
    healthbar_target_alpha = 1;
}

/// @function HideHealthBar()
HideHealthBar = function() {
    healthbar_target_alpha = 0;
}

/// @function PlayBossIntro(_dialogue_text)
PlayBossIntro = function(_dialogue_text) {
    if (boss_intro_played) return;
    boss_intro_played = true;
    
    intro_dialogue = _dialogue_text;
    
    if (instance_exists(obj_player)) {
        obj_player.camera.pan_to(x, y);
    }
    
    intro_dialogue_timer = 180; // 3 seconds
    ShowHealthBar();
}

/// @function OnBossDefeated()
OnBossDefeated = function() {
    // Override in child classes
    show_debug_message("Boss defeated!");
}

/// @function UpdateJump(_delta)
UpdateJump = function(_delta) {
    jump_timer += _delta;
    
    var total_duration = jump_duration * 2;
    
    // Move toward shadow position while jumping
    var move_progress = min(jump_timer / total_duration, 1); // Cap at 1
    x = lerp(jump_start_x, shadow_x, move_progress);
    y = lerp(jump_start_y, shadow_y, move_progress);
    
    // Rising
    if (jump_timer < jump_duration) {
        var progress = jump_timer / jump_duration;
        jump_height = lerp(0, jump_target_height, progress);
    }
    // Falling
    else {
        var fall_time = jump_timer - jump_duration;
        var progress = min(fall_time / jump_duration, 1); // Cap at 1
        jump_height = lerp(jump_target_height, 0, progress);
        
        // Land when fall is complete
        if (fall_time >= jump_duration) {
            OnJumpLand();
        }
    }
}

/// @function OnJumpLand()
OnJumpLand = function() {
    x = shadow_x;
    y = shadow_y;
    jump_height = 0;
    jump_timer = 0;
    jumps_completed++;
    
    instance_create_depth(x, y, depth, obj_ripple_attack);
    
    if (instance_exists(obj_player)) {
        obj_player.camera.add_shake(8);
    }
    
    if (jumps_completed >= jumps_per_cycle) {
        state = TIPSY_STATE.CHARGING;
        charge_timer = 0;
        jumps_completed = 0;
    } else {
        state = TIPSY_STATE.ENEMY;
        jump_start_timer = 60; // 1 second between jumps
    }
}

/// @function UpdateCharge(_delta)
UpdateCharge = function(_delta) {
    charge_timer += _delta;
    
    if (charge_timer >= charge_duration) {
        StartSkyAttack();
    }
}

/// @function StartSkyAttack()
StartSkyAttack = function() {
    state = TIPSY_STATE.SKY_ATTACK;
    sky_timer = 0;
    
    // Store Tipsy's launch position
    sky_jump_y = y;
    sky_jump_y_position_x = x;
    sky_jump_y_position_y = y;
    sky_target_y = camera_get_view_x(view_camera[view_current]) - 20;
    sky_jump_progress = 0;
    
    lid_drop_timer = 90; // 1.5 seconds
    shadow_lock_timer = 240; // 4 seconds warning
    
    if (instance_exists(obj_player)) {
        shadow_x = obj_player.x;
        shadow_y = obj_player.y;
    }
    shadow_scale = 2.0;
    show_crash_shadow = true;
    shadow_locked = false;
}


/// @function UpdateSkyAttack(_delta)
UpdateSkyAttack = function(_delta) {
    sky_timer += _delta;
    
    // Animate Tipsy jumping up off screen (SLOWER)
    if (sky_jump_progress < 1) {
        sky_jump_progress += 0.01 * _delta; // Changed from 0.05 to 0.01
        y = lerp(sky_jump_y, sky_target_y, sky_jump_progress);
        
        // Squash and stretch for juice
        image_yscale = lerp(1, 0.8, sky_jump_progress);
        image_xscale = lerp(1, 1.2, sky_jump_progress);
    }
    
    // Update shadow position if not locked
    if (!shadow_locked && instance_exists(obj_player)) {
        shadow_x = obj_player.x;
        shadow_y = obj_player.y;
    }
    
    // Spawn lil tipsys periodically
    lil_tipsy_spawn_timer += _delta;
    if (lil_tipsy_spawn_timer >= lil_tipsy_spawn_rate) {
        lil_tipsy_spawn_timer = 0;
        var current_count = instance_number(obj_lil_tipsy);
        if (current_count < lil_tipsy_max) {
            SpawnLilTipsys(1);
        }
    }
}

/// @function CrashDown()
CrashDown = function() {
    // Return to player position
    if (instance_exists(obj_player)) {
        x = obj_player.x;
        y = obj_player.y;
    }
    
    // Massive camera shake
    if (instance_exists(obj_player)) {
        obj_player.camera.add_shake(20);
    }
    
    // Triple ripple attacks
    alarm[3] = 1;   // Immediate
    alarm[4] = 18;  // 0.3 seconds
    alarm[5] = 36;  // 0.6 seconds
    
    // Return lid to Tipsy
    if (instance_exists(lid_object)) {
        // Lid bounces toward Tipsy
        lid_object.myDir = point_direction(lid_object.x, lid_object.y, x, y);
        lid_object.mySpeed = 12;
        alarm[6] = 60; // Reattach after 1 second
    }
    
    // Return to boss mode
    state = TIPSY_STATE.ENEMY;
    alarm[2] = 120; // 2 seconds before next jump
}

/// @function SpawnLilTipsys(_count)
SpawnLilTipsys = function(_count) {
    // Get tilemap for collision checking
    var tile_layer_id = layer_get_id("Tiles_2");
    var tilemap_id = layer_tilemap_get_id(tile_layer_id);
    
    repeat(_count) {
        var spawn_x = 0;
        var spawn_y = 0;
        var attempts = 0;
        var max_attempts = 20;
        
        // Find safe spawn point around Tipsy
        while (attempts < max_attempts) {
            spawn_x = sky_jump_y_position_x + random_range(-200, 200);
            spawn_y = sky_jump_y_position_y + random_range(-200, 200);
            
            // Check if safe
            var tile = tilemap_get_at_pixel(tilemap_id, spawn_x, spawn_y);
            var is_safe = (tile <= 446 && tile != 0);
            var far_from_player = instance_exists(obj_player) ? point_distance(spawn_x, spawn_y, obj_player.x, obj_player.y) > 150 : true;
            
            if (is_safe && far_from_player && !place_meeting(spawn_x, spawn_y, obj_obstacle)) {
                break;
            }
            attempts++;
        }
        
        // Spawn lil tipsy
        var lil_tipsy = instance_create_depth(spawn_x, spawn_y, -100, obj_lil_tipsy);
        
        // Spawn VFX
        repeat(10) {
            var p = instance_create_depth(spawn_x, spawn_y, -9999, obj_particle);
            p.direction = random(360);
            p.speed = random_range(2, 4);
            p.particle_color = c_white; // Glass sparkle
        }
    }
}


/// @function DropLid()
DropLid = function() {
    show_debug_message("DropLid() called!");
    
    lid_is_open = true;
    draw_lid = false;
    
    // Spawn lid at where Tipsy jumped from
    var lid_drop_x = sky_jump_y_position_x; // Tipsy's position when he jumped
    var lid_drop_y = camera_get_view_y(view_camera[view_current]);
    
    lid_object = instance_create_depth(lid_drop_x, lid_drop_y, depth, obj_tipsy_lid);
    
    
    lid_object.falling = true;
    lid_object.fall_target_y = sky_jump_y_position_y; // Land where Tipsy was
    lid_object.fall_shadow_x = lid_drop_x;
    lid_object.fall_shadow_y = sky_jump_y_position_y;
	
	// Spawn lil tipsys when lid is dropped
    SpawnLilTipsys(3); // Spawn 3 initially
}

/// @function PerformCrashDown()
PerformCrashDown = function() {
    // Start crash down animation
    state = TIPSY_STATE.CRASHING; // New state for the crash animation
    crash_start_y = y;
    crash_target_y = shadow_y;
    crash_start_x = x;
    crash_target_x = shadow_x;
    crash_down_progress = 0;
    
    show_crash_shadow = true; // Keep shadow visible during crash
}

/// @function UpdateCrashDown(_delta)
UpdateCrashDown = function(_delta) {
    crash_down_progress += 0.05 * _delta; // Fast crash
    
    // Lerp position
    x = lerp(crash_start_x, crash_target_x, crash_down_progress);
    y = lerp(crash_start_y, crash_target_y, crash_down_progress);
    
    // Squash animation as approaching ground
    image_yscale = lerp(1, 1.3, crash_down_progress);
    image_xscale = lerp(1, 0.8, crash_down_progress);
    
    // Impact when reached ground
    if (crash_down_progress >= 1) {
        OnCrashLand();
    }
}

/// @function OnCrashLand()
OnCrashLand = function() {
    x = crash_target_x;
    y = crash_target_y;
    show_crash_shadow = false;
    
    // Reset scale
    image_xscale = 1;
    image_yscale = 1;
    
    if (instance_exists(obj_player)) {
        obj_player.camera.add_shake(20);
    }
    
    ripple_timer_1 = 1;
    ripple_timer_2 = 18;
    ripple_timer_3 = 36;
    
    if (instance_exists(lid_object)) {
        lid_object.returning_to_parent = true;
        lid_object.parent_tipsy = self;
        lid_reattach_timer = 60;
    }
	
	instance_create_depth(x, y, depth, obj_knockback);
    
    state = TIPSY_STATE.ENEMY;
    jump_start_timer = 120;
}

/// @function ReattachLid()
ReattachLid = function() {
    if (instance_exists(lid_object)) {
        instance_destroy(lid_object);
    }
    lid_is_open = false;
    draw_lid = true;
    lid_object = noone;
}

/// @function ExplodeAndDie()
ExplodeAndDie = function() {
    repeat(irandom_range(25, 50)) {
        var coin = instance_create_depth(x, y, depth, obj_coin);
        coin.direction = random(360);
        coin.speed = random_range(3, 8);
    }
    
    repeat(100) {
        var soul = instance_create_depth(x, y, depth, obj_soul_drop);
        soul.direction = random(360);
        soul.speed = random_range(2, 6);
    }
    
    HideHealthBar();
    instance_destroy();
}

// CONTEXT PROMPT
context_sens = CreateContextPrompt(
    self,
    CreateCustomAction(method(self, PayGold)),
    "Press [E] to Pay Gold (100 needed)",
    64
);
context_sens.offset_y = -40;

UpdateContextPrompt();