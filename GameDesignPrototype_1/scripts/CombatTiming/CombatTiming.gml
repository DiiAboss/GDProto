/// @function EvaluateAttackTiming()
/// @description Checks weapon cooldown and returns timing quality
/// @returns "perfect", "good", "early", or "ready"
function EvaluateAttackTiming() {
    // Check if weapon has cooldown system
    if (!variable_struct_exists(weaponCurrent, "attack_cooldown")) {
        return "ready"; // No cooldown = always ready
    }
    
    var cooldown = weaponCurrent.attack_cooldown;
    
    // If no cooldown, attack is ready
    if (cooldown <= 0) {
        return "ready";
    }
    
    // Get the max cooldown for this combo hit
    var max_cooldown = 30; // Default
    if (variable_struct_exists(weaponCurrent, "combo_attacks")) {
        var combo_idx = min(weaponCurrent.combo_count, array_length(weaponCurrent.combo_attacks) - 1);
        max_cooldown = weaponCurrent.combo_attacks[combo_idx].duration;
    } else if (variable_struct_exists(weaponCurrent, "cooldown_max")) {
        max_cooldown = weaponCurrent.cooldown_max;
    }
    
    // Calculate progress (0 = just attacked, 1 = fully ready)
    var progress = 1 - (cooldown / max_cooldown);
    
    // Evaluate timing windows
    if (progress >= perfect_window_start && progress <= perfect_window_end) {
        return "perfect";
    } else if (progress >= good_window_start) {
        return "good";
    } else {
        return "early"; // Button mashing
    }
}

/// @function ApplyTimingBonus(_quality)
/// @description Applies effects based on timing quality and returns damage multiplier
/// @param _quality The timing quality string
/// @returns Damage multiplier
function ApplyTimingBonus(_quality) {
    last_timing_quality = _quality;
    
    switch (_quality) {
        case "perfect":
            timing_bonus_multiplier = 1.5; // 50% bonus
            perfect_flash_timer = 8;
            perfect_hits_count++;
            
            // Screen effect (optional)
            // with (obj_camera_controller) { shake = 2; }
            
            // Audio cue (add when ready)
            // audio_play_sound(snd_perfect_timing, 5, false);
            
            return 1.5;
            
        case "good":
            timing_bonus_multiplier = 1.0; // Normal damage
            good_hits_count++;
            return 1.0;
            
        case "ready":
            timing_bonus_multiplier = 1.0; // Normal, waited for full cooldown
            return 1.0;
            
        case "early":
            timing_bonus_multiplier = 0.75; // 25% penalty
            perfect_flash_timer = 0; // No flash
            early_hits_count++;
            
            // Reset combo on bad timing (optional, can tune this)
            if (variable_struct_exists(weaponCurrent, "combo_count")) {
                weaponCurrent.combo_count = max(0, weaponCurrent.combo_count - 1);
            }
            
            return 0.75;
            
        default:
            return 1.0;
    }
}

/// @function UpdateTimingVisuals()
/// @description Updates visual feedback for timing system (call in Step)
function UpdateTimingVisuals() {
    // Decay flash timer
    if (perfect_flash_timer > 0) {
        perfect_flash_timer--;
    }
    
    // Update timing circle based on weapon cooldown
    if (variable_struct_exists(weaponCurrent, "attack_cooldown")) {
        var cooldown = weaponCurrent.attack_cooldown;
        
        if (cooldown > 0) {
            // Get max cooldown
            var max_cooldown = 30;
            if (variable_struct_exists(weaponCurrent, "combo_attacks")) {
                var combo_idx = min(weaponCurrent.combo_count, array_length(weaponCurrent.combo_attacks) - 1);
                max_cooldown = weaponCurrent.combo_attacks[combo_idx].duration;
            } else if (variable_struct_exists(weaponCurrent, "cooldown_max")) {
                max_cooldown = weaponCurrent.cooldown_max;
            }
            
            var progress = 1 - (cooldown / max_cooldown);
            
            // Circle shrinks from 2.0 to 0.8 as cooldown progresses
            timing_circle_scale = lerp(2.0, 0.8, progress);
            
            // Base alpha
            timing_circle_alpha = 0.4;
            
            // Pulse during perfect window
            if (progress >= perfect_window_start && progress <= perfect_window_end) {
                timing_circle_alpha = 0.6 + (sin(current_time * 0.015) * 0.3);
            }
            // Subtle glow during good window
            else if (progress >= good_window_start) {
                timing_circle_alpha = 0.5;
            }
        } else {
            // Fade out when ready
            timing_circle_alpha = lerp(timing_circle_alpha, 0, 0.15);
        }
    } else {
        // No cooldown system, hide circle
        timing_circle_alpha = 0;
    }
}

/// @function GetTimingCircleColor()
/// @description Returns color for timing circle based on current window
/// @returns Color constant
function GetTimingCircleColor() {
    if (!variable_struct_exists(weaponCurrent, "attack_cooldown")) {
        return c_white;
    }
    
    var cooldown = weaponCurrent.attack_cooldown;
    if (cooldown <= 0) return c_green; // Ready
    
    // Get progress
    var max_cooldown = 30;
    if (variable_struct_exists(weaponCurrent, "combo_attacks")) {
        var combo_idx = min(weaponCurrent.combo_count, array_length(weaponCurrent.combo_attacks) - 1);
        max_cooldown = weaponCurrent.combo_attacks[combo_idx].duration;
    } else if (variable_struct_exists(weaponCurrent, "cooldown_max")) {
        max_cooldown = weaponCurrent.cooldown_max;
    }
    
    var progress = 1 - (cooldown / max_cooldown);
    
    // Color based on timing window
    if (progress >= perfect_window_start && progress <= perfect_window_end) {
        return c_yellow; // Perfect window
    } else if (progress >= good_window_start) {
        return c_lime; // Good window
    } else {
        return c_red; // Too early
    }
}