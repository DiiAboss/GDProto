/// @desc Totem system for battlefield modifiers
// Module role: Purchasable global mutators. Activation spends gold, toggles
// game-wide knobs (spawns, stats), spawns a visual marker, and contributes to
// a score multiplier. Designed to be readable and data-driven.

function TotemData(_type, _name, _desc, _base_cost) constructor {
    type = _type;                // Enum tag used across systems
    name = _name;                // UI label
    description = _desc;         // UI/help text
    base_cost = _base_cost;      // Base before level scaling
    active = false;              // Flag set on purchase/activation
    activation_time = 0;         // Timestamp for time-based behaviors
    
    /// @func GetScaledCost(_player_level)
    /// Cost grows with level: keeps late-game purchases meaningful.
    static GetScaledCost = function(_player_level) {
        return floor(base_cost * (1 + _player_level * 0.15));
    }
}

// Global totem definitions
// Authoring surface: tweak costs/descriptions here; behaviors live in ApplyTotemEffect.
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
/// Lookup helper: converts enum to shared definition instance.
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
/// Purchase flow: affordability check → toggle active → spawn world marker →
/// apply immediate systemic effects. Returns true on success.
function ActivateTotem(_type, _player) {
    var totem_data = GetTotemByType(_type);
    if (totem_data == undefined) return false; // Invalid type
    
    // Avoid double-activation
    if (totem_data.active) {
        show_debug_message("Totem already active: " + totem_data.name);
        return false;
    }
    
    // Affordability gate with level-scaled price
    var cost = totem_data.GetScaledCost(_player.player_level);
    if (_player.gold < cost) {
        show_debug_message("Not enough gold! Need: " + string(cost));
        return false;
    }
    
    // Spend and mark active
    _player.gold -= cost;
    totem_data.active = true;
    totem_data.activation_time = current_time;
    
    // Spawn a visual anchor nearby (purely cosmetic; stores metadata)
    var totem_obj = instance_create_depth(
        obj_player.x + irandom_range(-100, 100),
        obj_player.y + irandom_range(-100, 100),
        -9999,
        obj_totem_active
    );
    totem_obj.totem_type = _type;
    totem_obj.totem_data = totem_data;
    
    // Switch on global/systemic effects
    ApplyTotemEffect(_type);
    
    show_debug_message("Activated: " + totem_data.name + " for " + string(cost) + " gold");
    return true;
}

/// @func ApplyTotemEffect(_type)
/// Centralized side-effects: flips flags/multipliers across manager/spawner/enemy
/// systems. Called once on activation; persistent behavior should live in those
/// systems (e.g., spawners read their multipliers each step).
function ApplyTotemEffect(_type) {
    switch (_type) {
        case TotemType.CHAOS:
            // Enable periodic chaos hazard spawns in the game manager
            with (obj_game_manager) {
                chaos_totem_active = true;
            }
            break;
            
        case TotemType.HORDE:
            // Multiplicative spawn rate bump; idempotent via *=
            with (obj_enemySpawner) {
                spawner_timer = max(spawner_timer, 30); // Speed up spawning
                spawn_rate_multiplier = 0.6; // 40% faster spawns
            }
            break;
            
        case TotemType.CHAMPION:
            // Begin boss-cycle logic in manager (timer-driven)
            with (obj_game_manager) {
                champion_totem_active = true;
                champion_spawn_timer = 45 * 60; // 45 seconds
            }
            break;
            
        case TotemType.GREED:
            // Tougher enemies; double gold yield. Applied to existing instances.
            with (obj_enemy) {
                if (!variable_instance_exists(self, "greed_applied")) {
                    maxHp = ceil(maxHp * 1.5);
                    hp = ceil(hp * 1.5);
                    greed_applied = true;
                }
            }
            break;
            
        case TotemType.FURY:
            // Global haste + damage bump for enemies
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
/// Utility for HUD/scoring: counts active flags in the definitions table.
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
/// Simple risk→reward scaling: each active totem adds +0.25x to the multiplier.
function GetScoreMultiplier() {
    var base = 1.0;
    var totem_count = GetActiveTotemCount();
    return base + (totem_count * 0.25);
}