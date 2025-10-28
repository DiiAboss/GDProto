/// @desc Totem system for battlefield modifiers

function TotemData(_type, _name, _desc, _base_cost, _color) constructor {
    type = _type;
    name = _name;
    description = _desc;
    base_cost = _base_cost;
    color = _color; // NEW
    active = false;
    activation_time = 0;
    
    static GetScaledCost = function(_player_level) {
        return floor(base_cost * (1 + _player_level * 0.15));
    }
}

// Global totem definitions
global.TotemDefinitions = {
    Chaos: new TotemData(
        TotemType.CHAOS,
        "Chaos Totem",
        "Spawns rolling balls periodically.",
        150,
        c_red
    ),
    
    Horde: new TotemData(
        TotemType.HORDE,
        "Horde Totem",
        "Increases enemy spawn rate by 50%.",
        200,
        c_orange
    ),
    
    Champion: new TotemData(
        TotemType.CHAMPION,
        "Champion Totem",
        "Spawns a mini-boss every 45 seconds.",
        400,
        c_purple
    ),
    
    Greed: new TotemData(
        TotemType.GREED,
        "Greed Totem",
        "Enemies drop 2x gold but have 50% more HP.",
        250,
        c_yellow
    ),
    
    Fury: new TotemData(
        TotemType.FURY,
        "Fury Totem",
        "Enemies move 30% faster. 1.5x XP multiplier!",
        300,
        c_fuchsia
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
        default: return noone;
    }
}

/// @func ActivateTotem(_type, _player)
function ActivateTotem(_type, _player) {
    var totem_data = GetTotemByType(_type);
    if (totem_data == noone) return false;
    
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
            // Effect handled in obj_totem_active Step event
            show_debug_message("Chaos Totem activated - balls will spawn");
            break;
            
        case TotemType.HORDE:
            with (obj_enemySpawner) {
                spawner_timer = max(spawner_timer, 30); // Speed up spawning
                spawn_rate_multiplier = 0.6; // 40% faster spawns
            }
            break;
            
        case TotemType.CHAMPION:
            with (obj_game_manager) {
                champion_totem_active = true;
                champion_spawn_timer = 45 * 60; // 45 seconds
            }
            break;
            
        case TotemType.GREED:
            with (obj_enemy) {
                if (!variable_instance_exists(self, "greed_applied")) {
                    maxHp = ceil(maxHp * 1.5);
                    hp = ceil(hp * 1.5);
                    greed_applied = true;
                }
            }
            break;
            
        case TotemType.FURY:
            with (obj_enemy) {
                if (!variable_instance_exists(self, "fury_applied")) {
                    moveSpeed *= 1.3;
                    baseSpeed *= 1.3;
                    fury_applied = true;
                }
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