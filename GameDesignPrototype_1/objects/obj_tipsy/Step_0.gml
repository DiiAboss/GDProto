/// @description obj_tipsy - Step Event

// DISABLE PARENT ENEMY MOVEMENT during boss states
if (state >= TIPSY_STATE.ENEMY) {
    if (global.gameSpeed == 0) exit;
    
    damage_sys.Update();
    
	knockback.Update(self);
    timers.Update();
    
    hp = damage_sys.hp;
    maxHp = damage_sys.max_hp;
    
	if (hp <= 0)
	{
		state = TIPSY_STATE.DEFEATED;
	}
	
	
    if (hitFlashTimer > 0) hitFlashTimer--;
    if (shake > 0) shake *= 0.9;
    
    healthbar_alpha = lerp(healthbar_alpha, healthbar_target_alpha, 0.1);
	

} else {
    event_inherited();
    if (global.gameSpeed == 0) exit;
}

var _delta = game_speed_delta();

// State machine
switch(state) {
    case TIPSY_STATE.CHILL:
    case TIPSY_STATE.LESSCHILL:
    case TIPSY_STATE.FRUSTRATED:
    case TIPSY_STATE.ANGRY:
        // Idle, waiting for interaction
        break;
        
    case TIPSY_STATE.ENEMY:
        // Waiting for jump - tick jump start timer
        jump_start_timer = timer_tick(jump_start_timer);
        if (jump_start_timer == 0) {
            jump_start_x = x;
            jump_start_y = y;
            shadow_x = obj_player.x;
            shadow_y = obj_player.y;
            state = TIPSY_STATE.JUMPING;
            jump_timer = 0;
            jump_height = 0;
        }
        break;
        
    case TIPSY_STATE.JUMPING:
        UpdateJump(_delta);
        break;
        
    case TIPSY_STATE.CHARGING:
        UpdateCharge(_delta);
        break;
        
    case TIPSY_STATE.SKY_ATTACK:
    // Handle sky attack sub-timers FIRST
    lid_drop_timer = timer_tick(lid_drop_timer);
    if (lid_drop_timer == 0 && !lid_is_open) {
        DropLid();
        lid_drop_timer = -1;
    }
    
    shadow_lock_timer = timer_tick(shadow_lock_timer);
    if (shadow_lock_timer == 0 && !shadow_locked) {
        shadow_locked = true;
        shadow_scale = 1.5;
        crash_down_timer = 90; // 1.5 second delay after lock before crash
        shadow_lock_timer = -1;
    }
    
    crash_down_timer = timer_tick(crash_down_timer);
    if (crash_down_timer == 0 && shadow_locked) {
        PerformCrashDown(); // This now starts the crash animation
        crash_down_timer = -1;
    }
    
    UpdateSkyAttack(_delta);
    break;
	
	
        case TIPSY_STATE.CRASHING:
    UpdateCrashDown(_delta);
    break;
        
    case TIPSY_STATE.FEEDING:
        bonus_arena_transition_timer = timer_tick(bonus_arena_transition_timer);
        if (bonus_arena_transition_timer == 0) {
            state = TIPSY_STATE.BONUS_ARENA;
        }
        break;
        
    case TIPSY_STATE.DEFEATED:
        death_explosion_timer = timer_tick(death_explosion_timer);
        if (death_explosion_timer == 0) {
            ExplodeAndDie();
        }
        break;
}

// Global timers (always tick)
if (lid_reattach_timer > 0) {
    lid_reattach_timer = timer_tick(lid_reattach_timer);
    if (lid_reattach_timer == 0) {
        ReattachLid();
    }
}

if (ripple_timer_1 > 0) {
    ripple_timer_1 = timer_tick(ripple_timer_1);
    if (ripple_timer_1 == 0) {
        instance_create_depth(x, y, depth, obj_ripple_attack);
    }
}

if (ripple_timer_2 > 0) {
    ripple_timer_2 = timer_tick(ripple_timer_2);
    if (ripple_timer_2 == 0) {
        instance_create_depth(x, y, depth, obj_ripple_attack);
    }
}

if (ripple_timer_3 > 0) {
    ripple_timer_3 = timer_tick(ripple_timer_3);
    if (ripple_timer_3 == 0) {
        instance_create_depth(x, y, depth, obj_ripple_attack);
    }
}

depth = -y;