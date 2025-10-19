/// @desc Game Manager Step

ui.update();

pause_manager.Update();
// Handle slowdown effect
if (slowdown_active) {
    slowdown_timer++;
    
    // Gradually slow down
    var progress = slowdown_timer / slowdown_duration;
    var target_speed = lerp(1.0, slowdown_target, progress);
    
    // Override game speed during slowdown
    // (This happens BEFORE pause manager pauses fully)
    if (!pause_manager.IsPaused()) {
        global.gameSpeed = target_speed;
    }
    
    // When slowdown complete, pause fully
    if (slowdown_timer >= slowdown_duration) {
        slowdown_active = false;
        // Now pause manager takes over
    }
}
// Update managers
if (current_room_type == GAME_ROOM.GAMEPLAY) {
    score_manager.Update(game_speed_delta());
    time_manager.Update(game_speed_delta());
	
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
// Update weapon swap prompt
UpdateWeaponSwapPrompt();


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
//if (chaos_totem_active) {
    //chaos_spawn_timer = timer_tick(chaos_spawn_timer);
    //
    //if (chaos_spawn_timer >= chaos_spawn_interval) {
        //
        //
        //if (instance_exists(obj_player)) {
            //var spawn_x = obj_player.x + irandom_range(-200, 200);
            //var spawn_y = obj_player.y + irandom_range(-200, 200);
            //
            //if (!place_meeting(spawn_x, spawn_y, obj_wall)) {
                //var ball = instance_create_depth(spawn_x, spawn_y, 0, obj_rolling_ball);
                //ball.myDir = irandom(359);
                //show_debug_message("Chaos Totem: Spawned rolling ball");
            //}
			//chaos_spawn_timer = 0;
        //}
    //}
//}

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
	
}



// ==========================================
// CHEST EVENT FUNCTIONS
// ==========================================

/// @function OnChestOpening(_chest)
/// @param {Id.Instance} _chest The chest being opened
function OnChestOpening(_chest) {
    show_debug_message("Chest opening - starting slowdown effect");
    
    // Start slowdown effect
    slowdown_active = true;
    slowdown_timer = 0;
    
    call_later(slowdown_duration, time_source_units_frames, function() {
        // Pause for chest opening
  		pause_manager.Pause(PAUSE_REASON.CHEST_OPENING, 0);
        
    })
}

/// @function OnChestClosing(_chest)
/// @param {Id.Instance} _chest The chest being closed
function OnChestClosing(_chest) {
    show_debug_message("Chest closing - resuming game");
    
    // Resume from chest pause
    pause_manager.Resume(PAUSE_REASON.CHEST_OPENING);
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

/// @function ShowLevelUpPopup()
/// Add this to obj_game_manager
function ShowLevelUpPopup() {
    // Don't show popup if one is already active
    if (variable_global_exists("selection_popup") && global.selection_popup != undefined) {
        return;
    }
    
    // Generate 3 random modifier choices
    var options = [];
    var available_mods = GetAvailableModifiers();
    
    // Pick 3 random unique modifiers
    var chosen_mods = [];
    for (var i = 0; i < 3; i++) {
        if (array_length(available_mods) == 0) break;
        
        var random_index = irandom(array_length(available_mods) - 1);
        var mod_key = available_mods[random_index];
        array_push(chosen_mods, mod_key);
        
        // Remove from available to avoid duplicates
        array_delete(available_mods, random_index, 1);
    }
    
    // Build option structs for popup
    for (var i = 0; i < array_length(chosen_mods); i++) {
        var mod_key = chosen_mods[i];
        var mod_data = global.Modifiers[$ mod_key];
        
        // Get sprite for this modifier
        var mod_sprite = GetModifierSprite(mod_key);
        
        array_push(options, {
            name: mod_data.name ?? mod_key,
            desc: GetModifierDescription(mod_key),
            sprite: mod_sprite,
            mod_key: mod_key
        });
    }
    
    // Callback when player selects
    function on_modifier_select(index, option) {
        // Add modifier to player
        if (instance_exists(obj_player)) {
            AddModifier(obj_player, option.mod_key);
            show_debug_message("Player selected: " + option.name);
        }
        
        // Resume game
        obj_game_manager.pause_manager.Resume(PAUSE_REASON.LEVEL_UP);
    }
    
    // Pause game
    pause_manager.Pause(PAUSE_REASON.LEVEL_UP, 0);
    
    // Create popup
    global.selection_popup = new SelectionPopup(
        display_get_gui_width() / 2,
        display_get_gui_height() / 2,
        options,
        on_modifier_select
    );
}

/// @function GetAvailableModifiers()
/// @returns {array} Array of modifier keys
function GetAvailableModifiers() {
    var available = [];
    var mod_keys = struct_get_names(global.Modifiers);
    
    for (var i = 0; i < array_length(mod_keys); i++) {
        var key = mod_keys[i];
        
        // Check if player already has this modifier
        var already_has = false;
        for (var j = 0; j < array_length(obj_player.mod_list); j++) {
            if (obj_player.mod_list[j].template_key == key) {
                already_has = true;
                break;
            }
        }
        
        // Only add if player doesn't have it
        if (!already_has) {
            array_push(available, key);
        }
    }
    
    return available;
}

/// @function GetModifierSprite(_mod_key)
/// @param {string} _mod_key Modifier key
/// @returns {Asset.GMSprite} Sprite for this modifier
function GetModifierSprite(_mod_key) {
    // Direct sprite mapping - asset_get_index doesn't work reliably
    switch (_mod_key) {
        case "TripleRhythmFire":
            return spr_mod_TripleRhythmFire;
        case "SpreadFire":
            return spr_mod_SpreadFire;
        case "DoubleLightning":
            return spr_mod_DoubleLightning;
        case "ChainLightning":
            return spr_mod_ChainLightning;
        case "StaticCharge":
            return spr_mod_StaticCharge;
        case "ThunderStrike":
            return spr_mod_ThunderStrike;
        case "DeathFireworks":
            return spr_mod_DeathFireworks;
        case "PoisonCorpse":
            return spr_mod_PoisonCorpse;
        case "ChainReaction":
            return spr_mod_ChainReaction;
        case "MultiShot":
            return spr_mod_MultiShot;
        case "BurstFire":
            return spr_mod_BurstFire;
        default:
            // Fallback
            if (sprite_exists(spr_mod_default)) {
                return spr_mod_default;
            }
            return -1; // No sprite available
    }
}

/// @function GetModifierDescription(_mod_key)
/// @param {string} _mod_key Modifier key
/// @returns {string} Description text
function GetModifierDescription(_mod_key) {
    var _mod = global.Modifiers[$ _mod_key];
    
    var desc = "";
    
    switch (_mod_key) {
        // ===============================
        // ORIGINAL MODIFIERS
        // ===============================
        case "TripleRhythmFire":
            desc = "Every 3rd attack shoots a fireball";
            break;
            
        case "SpreadFire":
            desc = "+4 projectiles in a spread\n+30° melee arc";
            break;
            
        case "DoubleLightning":
            desc = "Every 2nd attack strikes with lightning";
            break;
            
        case "ChainLightning":
            desc = "25% chance to chain lightning\nto nearby enemies";
            break;
            
        case "StaticCharge":
            desc = "Build up 5 charges, then unleash\nmassive lightning storm";
            break;
            
        case "ThunderStrike":
            desc = "30% chance for melee attacks\nto chain lightning";
            break;
            
        case "DeathFireworks":
            desc = "Killed enemies explode into\n8 projectiles";
            break;
            
        case "PoisonCorpse":
            desc = "Killed enemies release\ntoxic clouds";
            break;
            
        case "ChainReaction":
            desc = "50% chance for explosion kills\nto trigger more explosions";
            break;
            
        case "MultiShot":
            desc = "+1 projectile per shot";
            break;
            
        case "BurstFire":
            desc = "Each shot fires 3 times\nin quick succession";
            break;
            
        // ===============================
        // NEW COMMON / STAT MODIFIERS
        // ===============================
        case "AttackUp":
            desc = "x1.15 Attack Power";
            break;
            
        case "DefenseUp":
            desc = "x1.20 Damage Resistance";
            break;
            
        case "SpeedUp":
            desc = "x1.10 Movement Speed";
            break;
            
        case "HealthUp":
            desc = "x1.25 Max Health";
            break;
            
        case "CriticalChance":
            desc = "x1.10 Critical Hit Chance";
            break;
            
        case "CriticalDamage":
            desc = "x1.50 Critical Damage Multiplier";
            break;
            
        case "KnockbackBoost":
            desc = "x1.25 Knockback Force";
            break;
            
        case "LifeSteal":
            desc = "Gain 5% of damage dealt as HP";
            break;
            
        case "Haste":
            desc = "Attacks and abilities recharge\n20% faster";
            break;
            
        case "Adrenaline":
            desc = "Gain x1.25 speed below 0.30 MAX_HP";
            break;
            
        case "Regeneration":
            desc = "Regenerate x1.01 of max HP per second";
            break;
            
        case "Barrier":
            desc = "Gain a shield that blocks one hit\nevery 10 seconds";
            break;
            
        case "Overdrive":
            desc = "Increase attack speed by x1.30\nfor 3s after taking damage";
            break;
            
        case "Evasion":
            desc = "x1.10 chance to dodge attacks";
            break;
            
        case "Momentum":
            desc = "x1.02 damage for each enemy killed\n(stackable up to 10x)";
            break;
            
        case "GoldRush":
            desc = "Enemies drop x1.30 more coins";
            break;
            
        case "Precision":
            desc = "First hit on full HP enemy\nalways crits";
            break;
            
        case "Fortified":
            desc = "Gain x1.10 defense when stationary";
            break;
            
        case "QuickStep":
            desc = "Dodging increases speed by x1.50\nfor 1.5s";
            break;
            
        case "Revenge":
            desc = "After taking damage, next attack\ndeals x1.50 damage";
            break;
            
        default:
            desc = "Dev Forgot Description... (again)";
            break;
    }
    
    return desc;
}
