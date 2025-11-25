/// @file scr_DropSystem.gml
/// @description Centralized drop system for XP, Gold, and Souls

// ===========================================
// XP SYSTEM
// ===========================================

/// @function GiveExperience(_player, _base_amount)
/// @description Give XP to player with multipliers applied
function GiveExperience(_player, _base_amount) {
    if (!instance_exists(_player)) return;
    
    var final_amount = _base_amount;
    
    // Apply experience multiplier from modifiers
    if (variable_instance_exists(_player.stats, "experience_mult")) {
        final_amount *= _player.stats.experience_mult;
    }
    
    // Apply to player
    _player.experience_points += final_amount;
    
    // Check for level up
    if (_player.experience_points >= _player.exp_to_next_level) {
        _player.experience_points -= _player.exp_to_next_level;
        _player.player_level++;
        _player.exp_to_next_level = _player.calculate_exp_requirement(_player.player_level);
        
        // Trigger level up event
        if (instance_exists(obj_game_manager)) {
            obj_game_manager.ShowLevelUpPopup(true);
        }
    }
    
    show_debug_message("XP: +" + string(floor(final_amount)) + " (base: " + string(_base_amount) + ")");
}

/// @function DropExperienceOrbs(_x, _y, _count, _spread)
/// @description Spawn XP orbs at location
function DropExperienceOrbs(_x, _y, _count = 3, _spread = 16) {
    for (var i = 0; i < _count; i++) {
        var orb = instance_create_depth(
            _x + random_range(-_spread, _spread),
            _y + random_range(-_spread, _spread),
            -100,
            obj_exp
        );
        orb.direction = random(360);
        orb.speed = random_range(2, 4);
    }
}

// ===========================================
// GOLD SYSTEM
// ===========================================

/// @function GiveGold(_player, _base_amount)
/// @description Give gold to player with multipliers applied
function GiveGold(_player, _base_amount) {
    if (!instance_exists(_player)) return;
    
    var final_amount = _base_amount;
    
    // Apply gold multiplier from modifiers
    if (variable_instance_exists(_player.stats, "gold_mult")) {
        final_amount *= _player.stats.gold_mult;
    }
    
    // Round to whole number
    final_amount = floor(final_amount);
    
    _player.gold += final_amount;
    
    show_debug_message("Gold: +" + string(final_amount) + " (base: " + string(_base_amount) + ")");
    
    return final_amount;
}

/// @function DropCoins(_x, _y, _count, _spread)
/// @description Spawn coin pickups at location
function DropCoins(_x, _y, _count = 3, _spread = 16) {
    for (var i = 0; i < _count; i++) {
        var coin = instance_create_depth(
            _x + random_range(-_spread, _spread),
            _y + random_range(-_spread, _spread),
            -100,
            obj_coin
        );
        coin.direction = random(360);
        coin.speed = random_range(2, 4);
    }
}

// ===========================================
// SOUL SYSTEM (Meta Currency)
// ===========================================

/// @function GiveSouls(_base_amount)
/// @description Give souls with multipliers applied (saved permanently)
function GiveSouls(_base_amount) {
    var final_amount = _base_amount;
    
    // Apply soul multiplier from modifiers (Souls2x)
    if (instance_exists(obj_player)) {
        if (variable_instance_exists(obj_player.stats, "soul_mult")) {
            final_amount *= obj_player.stats.soul_mult;
        }
    }
    
    // Round to whole number
    final_amount = floor(final_amount);
    
    // Add to save data
    global.SaveData.career.currency.souls += final_amount;
    global.SaveData.career.currency.lifetime_souls += final_amount;
    global.Souls = global.SaveData.career.currency.souls;
    show_debug_message("Souls: +" + string(final_amount) + " (base: " + string(_base_amount) + ")");
    
    return final_amount;
}

/// @function DropSouls(_x, _y, _count, _spread)
/// @description Spawn soul pickups at location
function DropSouls(_x, _y, _count = 1, _spread = 16) {
    for (var i = 0; i < _count; i++) {
        var soul = instance_create_depth(
            _x + random_range(-_spread, _spread),
            _y + random_range(-_spread, _spread),
            -100,
            obj_soul_drop
        );
        soul.z_velocity = random_range(-3, -1);
    }
}

// ===========================================
// DROP CHANCE SYSTEM
// ===========================================

/// @function RollDrop(_base_chance)
/// @description Roll for drop with lucky modifier applied
/// @returns {bool} True if drop succeeds
function RollDrop(_base_chance) {
    var final_chance = _base_chance;
    final_chance *= obj_player.stats.drop_rate_mult; // Apply drop multiplier
    final_chance += obj_player.stats.luck;           // Apply luck bonus
    final_chance = clamp(final_chance, 0, 1);        // Clamp to 0-100%
    return random(1) < final_chance;
}
// ===========================================
// UNIFIED DROP FUNCTION FOR ENEMIES
// ===========================================

/// @function DropEnemyRewards(_enemy_x, _enemy_y, _enemy_type)
/// @description Drop all rewards from an enemy death
function DropEnemyRewards(_enemy_x, _enemy_y, _enemy_type) {
    // Base drops
    var exp_orbs = irandom_range(1, 3);
    var coins = irandom_range(1, 2);
    var soul_count = 1;
    
    // Scale by enemy type
    switch (_enemy_type) {
        case obj_enemy_bomber:
            soul_count = 2;
            coins = irandom_range(2, 4);
            break;
            
        case obj_summoner_demon:
            soul_count = 5;
            coins = irandom_range(5, 8);
            exp_orbs = irandom_range(3, 5);
            break;
            
        // Add more enemy types
    }
    
    // Apply lucky modifier to drop count
    if (RollDrop(0.3)) {  // 30% chance for bonus drops
        exp_orbs++;
        coins++;
    }
    
    // Spawn drops
    DropExperienceOrbs(_enemy_x, _enemy_y, exp_orbs);
    DropCoins(_enemy_x, _enemy_y, coins);
    DropSouls(_enemy_x, _enemy_y, soul_count);
}


