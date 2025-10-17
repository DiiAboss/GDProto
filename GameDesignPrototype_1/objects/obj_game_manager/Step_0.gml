/// @desc Game Manager Step

if (instance_exists(obj_exp))
{
    with (obj_exp)
    {
        if (settled)
        {
            var _dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);
            if (_dist_to_player <= 128)
            {
                direction = point_direction(x, y, obj_player.x, obj_player.y);
                speed += 0.1 * game_speed_delta();
                
                if (_dist_to_player <= 4)
                {
					obj_player.experience_points += obj_exp.amount;
                    instance_destroy();
                }
            }
            else
            {
                speed = 0;
            }
        }
    }
}

if (instance_exists(obj_coin))
{
    with (obj_coin)
    {
        if (settled)
        {
            var _dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);
            if (_dist_to_player <= 128)
            {
                direction = point_direction(x, y, obj_player.x, obj_player.y);
                speed += 0.1 * game_speed_delta();
                
                if (_dist_to_player <= 4)
                {
                    instance_destroy();
					obj_player.gold += 1;
                }
            }
            else
            {
                speed = 0;
            }
        }
    }
}

// ==========================================
// LEVEL UP POPUP (P key for testing)
// ==========================================
if (keyboard_check_pressed(ord("P"))) {
    if (!variable_global_exists("selection_popup") || global.selection_popup == undefined) {
        ShowLevelUpPopup();
    }
}

// ==========================================
// UPDATE SELECTION POPUP (Level-ups)
// ==========================================
if (variable_global_exists("selection_popup") && global.selection_popup != undefined) {
    var popup = global.selection_popup;
    popup.step();

    if (popup.finished) {
        global.selection_popup = undefined;
    }
}

// ==========================================
// UPDATE CHEST POPUP
// ==========================================
if (variable_global_exists("chest_popup") && global.chest_popup != undefined) {
    var chest_popup = global.chest_popup;
    chest_popup.step();
    
    if (chest_popup.finished) {
        global.chest_popup = undefined;
    }
}

// ==========================================
// TOTEM SYSTEMS
// ==========================================
// Chaos Totem - Spawn rolling balls
if (chaos_totem_active) {
    chaos_spawn_timer = timer_tick(chaos_spawn_timer);
    
    if (chaos_spawn_timer <= 0) {
        chaos_spawn_timer = chaos_spawn_interval;
        
        if (instance_exists(obj_player)) {
            var spawn_x = obj_player.x + irandom_range(-200, 200);
            var spawn_y = obj_player.y + irandom_range(-200, 200);
            
            if (!place_meeting(spawn_x, spawn_y, obj_wall)) {
                var ball = instance_create_depth(spawn_x, spawn_y, 0, obj_rolling_ball);
                ball.myDir = irandom(359);
                show_debug_message("Chaos Totem: Spawned rolling ball");
            }
        }
    }
}

// Champion Totem - Spawn mini-boss
if (champion_totem_active) {
    champion_spawn_timer = timer_tick(champion_spawn_timer);
    
    if (champion_spawn_timer <= 0) {
        champion_spawn_timer = champion_spawn_interval;
        
        if (instance_exists(obj_player)) {
            var spawn_x = obj_player.x + irandom_range(-300, 300);
            var spawn_y = obj_player.y + irandom_range(-300, 300);
            
            if (!place_meeting(spawn_x, spawn_y, obj_wall)) {
                var champion = instance_create_depth(spawn_x, spawn_y, 0, obj_enemy);
                
                // Buff champion stats
                champion.damage_sys.max_hp *= 3;
                champion.damage_sys.hp *= 3;
                champion.damage *= 1.5;
                champion.moveSpeed *= 0.8;
                champion.image_xscale = 1.5;
                champion.image_yscale = 1.5;
                champion.image_blend = c_red;
                
                show_debug_message("Champion Totem: Spawned mini-boss!");
            }
        }
    }
}

// ==========================================
// HELPER FUNCTIONS
// ==========================================
/// @function gm_trigger_event(trigger, player, extra)
function gm_trigger_event(trigger, player, extra) {
    var mods = playerModsArray;

    for (var i = 0; i < array_length(mods); i++) {
        var m = mods[i];

        if (m.trigger == trigger && is_callable(m.effect)) {
            m.effect(player, m, extra);
        }
    }
}

/// @function gm_calculate_player_stats(base_attack, base_hp, base_knockback, base_spd)
function gm_calculate_player_stats(base_attack, base_hp, base_knockback, base_spd) {
    var atk = base_attack;
    var hp  = base_hp;
    var kb  = base_knockback;
    var spd = base_spd;

    var mods = playerModsArray;

    for (var i = 0; i < array_length(mods); i++) {
        var m = mods[i];
        atk *= (1 + m.attack);
        hp  = round(hp + (1 + m.hp));
        kb  *= 1 + m.knockback;
        spd *= 1 + m.spd;
    }

    return [atk, hp, kb, spd];
}