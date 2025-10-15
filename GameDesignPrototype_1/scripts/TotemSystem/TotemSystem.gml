/// @desc Totem system for battlefield modifiers

function TotemData(_type, _name, _desc, _base_cost) constructor {
    type = _type;
    name = _name;
    description = _desc;
    base_cost = _base_cost;
    active = false;
    activation_time = 0; // When it was activated
    
    /// @func GetScaledCost(_player_level)
    static GetScaledCost = function(_player_level) {
        // Cost scales with player level: base_cost * (1 + level * 0.15)
        return floor(base_cost * (1 + _player_level * 0.15));
    }
}

// Global totem definitions
global.TotemDefinitions = {
    Chaos: new TotemData(
        TotemType.CHAOS,
        "Chaos Totem",
        "Spawns rolling balls periodically. More chaos, more fun!",
        150
    ),
    
    Horde: new TotemData(
        TotemType.HORDE,
        "Horde Totem",
        "Increases enemy spawn rate by 50%. More enemies, more XP!",
        200
    ),
    
    Champion: new TotemData(
        TotemType.CHAMPION,
        "Champion Totem",
        "Spawns a mini-boss every 45 seconds. High risk, high reward!",
        400
    ),
    
    Greed: new TotemData(
        TotemType.GREED,
        "Greed Totem",
        "Enemies drop 2x gold but have 50% more HP.",
        250
    ),
    
    Fury: new TotemData(
        TotemType.FURY,
        "Fury Totem",
        "Enemies move 30% faster and hit harder. 1.5x XP multiplier!",
        300
    )
};

/// @func GetTotemByType(_type)
function GetTotemByType(_type) {
    switch (_type) {
        case TotemType.CHAOS: return global.TotemDefinitions.Chaos;
        case TotemType.HORDE: return global.TotemDefinitions.Horde;
        case TotemType.CHAMPION: return global.TotemDefinitions.Champion;
        case TotemType.GREED: return global.TotemDefinitions.Greed;
        case TotemType.FURY: return global.TotemDefinitions.Fury;
        default: return undefined;
    }
}

/// @func ActivateTotem(_type, _player)
function ActivateTotem(_type, _player) {
    var totem_data = GetTotemByType(_type);
    if (totem_data == undefined) return false;
    
    // Check if already active
    if (totem_data.active) {
        show_debug_message("Totem already active: " + totem_data.name);
        return false;
    }
    
    // Check if player can afford
    var cost = totem_data.GetScaledCost(_player.player_level);
    if (_player.gold < cost) {
        show_debug_message("Not enough gold! Need: " + string(cost));
        return false;
    }
    
    // Deduct cost
    _player.gold -= cost;
    
    // Activate totem
    totem_data.active = true;
    totem_data.activation_time = current_time;
    
    // Spawn visual totem in world
    var totem_obj = instance_create_depth(
        obj_player.x + irandom_range(-100, 100),
        obj_player.y + irandom_range(-100, 100),
        -9999,
        obj_totem_active
    );
    totem_obj.totem_type = _type;
    totem_obj.totem_data = totem_data;
    
    // Apply immediate effects
    ApplyTotemEffect(_type);
    
    show_debug_message("Activated: " + totem_data.name + " for " + string(cost) + " gold");
    return true;
}

/// @func ApplyTotemEffect(_type)
function ApplyTotemEffect(_type) {
    switch (_type) {
        case TotemType.CHAOS:
            // Start chaos ball spawning
            with (obj_game_manager) {
                chaos_totem_active = true;
            }
            break;
            
        case TotemType.HORDE:
            // Increase spawn rate
            with (obj_enemySpawner) {
                spawn_rate_multiplier = (spawn_rate_multiplier ?? 1.0) * 1.5;
            }
            break;
            
        case TotemType.CHAMPION:
            // Start champion spawning
            with (obj_game_manager) {
                champion_totem_active = true;
                champion_spawn_timer = 0;
            }
            break;
            
        case TotemType.GREED:
            // Modify enemy stats
            with (obj_enemy) {
                maxHp *= 1.5;
                hp *= 1.5;
                gold_multiplier = 2.0;
            }
            break;
            
        case TotemType.FURY:
            // Increase enemy speed and damage
            with (obj_enemy) {
                moveSpeed *= 1.3;
                damage_multiplier = 1.3;
            }
            break;
    }
}

/// @func GetActiveTotemCount()
function GetActiveTotemCount() {
    var count = 0;
    if (global.TotemDefinitions.Chaos.active) count++;
    if (global.TotemDefinitions.Horde.active) count++;
    if (global.TotemDefinitions.Champion.active) count++;
    if (global.TotemDefinitions.Greed.active) count++;
    if (global.TotemDefinitions.Fury.active) count++;
    return count;
}

/// @func GetScoreMultiplier()
function GetScoreMultiplier() {
    // Each active totem adds 0.25x to multiplier
    var base = 1.0;
    var totem_count = GetActiveTotemCount();
    return base + (totem_count * 0.25);
}