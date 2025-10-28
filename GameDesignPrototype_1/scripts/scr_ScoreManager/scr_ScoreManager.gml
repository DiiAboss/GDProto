/// @description ScoreManager Constructor
/// Create: scr_score_manager.gml

// ==========================================
// ENUMS
// ==========================================

enum STYLE_TYPE {
    PERFECT_TIMING,
    OVERKILL,
    CHAIN_KILL,
    MULTI_HIT,
    COMBO_MASTER,
    FLAWLESS
}

// ==========================================
// SCORE MANAGER CONSTRUCTOR
// ==========================================

/// @function ScoreManager()
/// @description Manages all scoring, combos, and style tracking
function ScoreManager() constructor {
    
    // Core score
    current_score = 0;
    display_manager = new ScoreDisplayManager();
	
    // Combo system
    combo_multiplier = 1.0;
    combo_timer = 0;
    combo_decay_rate = 2; // Frames per tick
    max_combo = 5.0;
    min_combo = 1.0;
    
    // Kill chain tracking
    kill_chain_timer = 0;
    kill_chain_timeout = 45; // Frames
    kills_this_chain = 0;
    
    // Style tracking
    style_stats = {
        perfect_timing_kills: 0,
        overkill_kills: 0,
        chain_kills: 0,
        multi_kills: 0,
        total_overkill_damage: 0,
        highest_chain: 0,
        highest_combo: 1.0
    };
    
    // Score events (for replay/analysis)
    score_events = [];
    max_events = 100; // Keep last 100 events
    
    // ==========================================
    // CORE FUNCTIONS
    // ==========================================
    
    /// @function AddScore(_base_amount, _style_bonuses)
    /// @param {real} _base_amount Base score value
    /// @param {struct} _style_bonuses Optional struct with style bonus data
    /// @returns {real} Total score added
    static AddScore = function(_base_amount, _style_bonuses = noone) {
        var base_score = _base_amount;
        var style_score = 0;
        
        // Calculate style bonuses
        if (_style_bonuses != noone) {
            style_score = CalculateStyleScore(_style_bonuses);
        }
        
        // Apply combo multiplier
        var multiplied_base = base_score * combo_multiplier;
        var multiplied_style = style_score * combo_multiplier;
        var total = multiplied_base + multiplied_style;
        
        // Add to current score
        current_score += total;
        
        // Log event
        LogScoreEvent({
            base: base_score,
            style: style_score,
            multiplier: combo_multiplier,
            total: total,
            timestamp: current_time
        });
        
        return total;
    }
    
    /// @function CalculateStyleScore(_bonuses)
    /// @param {struct} _bonuses Struct containing style bonus flags/values
    /// @returns {real} Style bonus score
    static CalculateStyleScore = function(_bonuses) {
        var total_style = 0;
        
        // Check each style type
        if (struct_exists(_bonuses, "perfect_timing") && _bonuses.perfect_timing) {
            total_style += 20;
            style_stats.perfect_timing_kills++;
        }
        
        if (struct_exists(_bonuses, "overkill_mult") && _bonuses.overkill_mult > 0) {
            var overkill_bonus = _bonuses.overkill_mult * 5;
            total_style += overkill_bonus;
            style_stats.overkill_kills++;
        }
        
        if (struct_exists(_bonuses, "chain_count") && _bonuses.chain_count > 1) {
            var chain_bonus = _bonuses.chain_count * 3;
            total_style += chain_bonus;
            style_stats.chain_kills++;
        }
        
        if (struct_exists(_bonuses, "multi_hit_count") && _bonuses.multi_hit_count > 1) {
            var multi_bonus = _bonuses.multi_hit_count * 5;
            total_style += multi_bonus;
            style_stats.multi_kills++;
        }
        
        return total_style;
    }
    
   /// @function RegisterKill(_enemy, _damage_dealt, _player_ref)
    /// @param {Id.Instance} _enemy Enemy instance
    /// @param {real} _damage_dealt Total damage dealt
    /// @param {Id.Instance} _player_ref Player reference for timing check
    /// @returns {real} Score awarded
    static RegisterKill = function(_enemy, _damage_dealt, _player_ref = noone) {
        // Debug output
        show_debug_message("RegisterKill called!");
        
        // Get base score from enemy
        var base_score = 10;
        if (variable_instance_exists(_enemy, "score_value")) {
            base_score = _enemy.score_value;
        }
        
        show_debug_message("Base score: " + string(base_score));
        
        // Build style bonuses struct
        var style_bonuses = {
		    perfect_timing: false,
		    overkill_mult: 0,
		    chain_count: 0
		};
        
        // Check perfect timing (safely)
        if (instance_exists(_player_ref)) {
            if (variable_instance_exists(_player_ref, "last_timing_quality")) {
                if (_player_ref.last_timing_quality == "perfect") {
                    style_bonuses.perfect_timing = true;
                    show_debug_message("Perfect timing bonus!");
                }
            }
        }
        
        // Check overkill (safely)
        var enemy_max_hp = 10; // Default
        if (variable_instance_exists(_enemy, "maxHp")) {
            enemy_max_hp = _enemy.maxHp;
        } else if (variable_instance_exists(_enemy, "hp")) {
            enemy_max_hp = _enemy.hp;
        }
        
        if (_damage_dealt > enemy_max_hp * 2) {
            var overkill_mult = floor(_damage_dealt / enemy_max_hp);
            style_bonuses.overkill_mult = overkill_mult;
            style_stats.total_overkill_damage += (_damage_dealt - enemy_max_hp);
            show_debug_message("Overkill bonus: x" + string(overkill_mult));
        }
        
        // Update kill chain
        kill_chain_timer = kill_chain_timeout;
        kills_this_chain++;
        
        if (kills_this_chain > 1) {
            style_bonuses.chain_count = kills_this_chain;
            show_debug_message("Chain bonus: x" + string(kills_this_chain));
        }
        
        // Track highest chain
        if (kills_this_chain > style_stats.highest_chain) {
            style_stats.highest_chain = kills_this_chain;
        }
        
        // Add score
        var score_awarded = AddScore(base_score, style_bonuses);
        
		
		
		
		// CREATE VISUAL EVENTS
	    var display = obj_game_manager.score_display; // Reference to display manager
	    
	    // Base kill event
	    var kill_name = "KILL";
	    if (variable_instance_exists(_enemy, "enemy_type")) {
	        kill_name = _enemy.enemy_type + " KILL";
	    }
	    display.AddComboEvent(kill_name, base_score, 1);
	    
	    // Perfect timing
	    if (style_bonuses.perfect_timing) {
	        display.AddComboEvent("PERFECT", 20, 1);
	    }
	    
	    // Overkill
	    if (style_bonuses.overkill_mult > 0) {
	        display.AddComboEvent("OVERKILL", 5, style_bonuses.overkill_mult);
	    }
	    
	    // Chain kills
	    if (style_bonuses.chain_count > 1) {
	        display.AddComboEvent("CHAIN", 10, style_bonuses.chain_count);
	    }
		
		
        show_debug_message("Score awarded: " + string(score_awarded));
        show_debug_message("Total score now: " + string(current_score));
        
        // Increase combo on kill
        IncreaseCombo();
        
        return score_awarded;
    }
    
    /// @function IncreaseCombo(_amount)
    /// @param {real} _amount Amount to increase (default 0.1)
    static IncreaseCombo = function(_amount = 0.1) {
        combo_multiplier = min(max_combo, combo_multiplier + _amount);
        combo_timer = 180; // 3 seconds at 60fps
        
        // Track highest
        if (combo_multiplier > style_stats.highest_combo) {
            style_stats.highest_combo = combo_multiplier;
        }
    }
    
    /// @function ResetCombo()
    static ResetCombo = function() {
        combo_multiplier = min_combo;
        combo_timer = 0;
    }
    
    /// @function Update(_delta)
    /// @param {real} _delta Game speed delta
    static Update = function(_delta) {
        // Decay combo timer
        if (combo_timer > 0) {
            combo_timer -= combo_decay_rate * _delta;
            
            if (combo_timer <= 0) {
                combo_multiplier = max(min_combo, combo_multiplier - 0.1);
                combo_timer = 0;
            }
        }
        
        // Decay kill chain
        if (kill_chain_timer > 0) {
            kill_chain_timer -= _delta;
            
            if (kill_chain_timer <= 0) {
                kills_this_chain = 0;
                kill_chain_timer = 0;
            }
        }
    }
    
    /// @function GetScore()
    /// @returns {real} Current score
    static GetScore = function() {
        return current_score;
    }
    
    /// @function GetComboMultiplier()
    /// @returns {real} Current combo multiplier
    static GetComboMultiplier = function() {
        return combo_multiplier;
    }
    
    /// @function GetStyleStats()
    /// @returns {struct} Copy of style stats
    static GetStyleStats = function() {
        // Return copy to prevent external modification
        return {
            perfect_timing_kills: style_stats.perfect_timing_kills,
            overkill_kills: style_stats.overkill_kills,
            chain_kills: style_stats.chain_kills,
            multi_kills: style_stats.multi_kills,
            total_overkill_damage: style_stats.total_overkill_damage,
            highest_chain: style_stats.highest_chain,
            highest_combo: style_stats.highest_combo
        };
    }
    
    /// @function Reset()
    /// @description Reset all scoring for new game
    static Reset = function() {
        current_score = 0;
        combo_multiplier = 1.0;
        combo_timer = 0;
        kill_chain_timer = 0;
        kills_this_chain = 0;
        
        style_stats = {
            perfect_timing_kills: 0,
            overkill_kills: 0,
            chain_kills: 0,
            multi_kills: 0,
            total_overkill_damage: 0,
            highest_chain: 0,
            highest_combo: 1.0
        };
        
        score_events = [];
    }
    
    // ==========================================
    // HELPER FUNCTIONS
    // ==========================================
    
    /// @function LogScoreEvent(_event_data)
    /// @param {struct} _event_data Event data to log
    static LogScoreEvent = function(_event_data) {
        array_push(score_events, _event_data);
        
        // Trim if over max
        if (array_length(score_events) > max_events) {
            array_delete(score_events, 0, 1);
        }
    }
    
    /// @function GetRecentEvents(_count)
    /// @param {real} _count Number of recent events to get
    /// @returns {array} Array of recent score events
    static GetRecentEvents = function(_count = 10) {
        var count = min(_count, array_length(score_events));
        var start_index = max(0, array_length(score_events) - count);
        
        var recent = [];
        for (var i = start_index; i < array_length(score_events); i++) {
            array_push(recent, score_events[i]);
        }
        
        return recent;
    }
    
    /// @function GetScoreRank()
    /// @returns {string} Rank based on score
    static GetScoreRank = function() {
        if (current_score >= 10000) return "S";
        if (current_score >= 5000) return "A";
        if (current_score >= 2500) return "B";
        if (current_score >= 1000) return "C";
        return "D";
    }
}

// ==========================================
// USAGE EXAMPLE
// ==========================================

/*
// In obj_game_manager Create Event:
score_manager = new ScoreManager();

// In obj_game_manager Step Event:
score_manager.Update(game_speed_delta());

// When enemy dies (in obj_enemy death code):
var damage_dealt = maxHp + 10; // Example
obj_game_manager.score_manager.RegisterKill(self, damage_dealt, obj_player);

// To add custom score:
obj_game_manager.score_manager.AddScore(50);

// To add score with style bonuses:
var bonuses = {
    perfect_timing: true,
    chain_count: 3
};
obj_game_manager.score_manager.AddScore(100, bonuses);

// To get current score:
var score = obj_game_manager.score_manager.GetScore();

// To reset for new game:
obj_game_manager.score_manager.Reset();

// To get stats for game over screen:
var stats = obj_game_manager.score_manager.GetStyleStats();
show_debug_message("Perfect timing kills: " + string(stats.perfect_timing_kills));
*/