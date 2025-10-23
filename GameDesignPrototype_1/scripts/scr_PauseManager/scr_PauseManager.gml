// ==========================================
// PAUSE REASONS ENUM
// ==========================================

enum PAUSE_REASON {
    NONE,
    CHEST_OPENING,
    LEVEL_UP,
    TOTEM_SHOP,
    PAUSE_MENU,
    DIALOGUE,
    GAME_OVER
}

// ==========================================
// PAUSE MANAGER CONSTRUCTOR
// ==========================================

/// @function PauseManager()
/// @description Manages all game pausing with priority system
function PauseManager() constructor {
    
    // Stack of active pause reasons (LIFO - Last In First Out)
    pause_stack = [];
    
    // Current game speed (0 to 1)
    target_speed = 1.0;
    current_speed = 1.0;
    speed_transition = 0.15; // How fast to lerp to target
    
    // Pause states
    is_paused = false;
    current_reason = PAUSE_REASON.NONE;
    
    /// @function Pause(_reason, _target_speed)
    /// @param {enum.PAUSE_REASON} _reason Why we're pausing
    /// @param {real} _target_speed Target game speed (0 to 1), default 0
    static Pause = function(_reason, _target_speed = 0) {
        // Add to stack
        array_push(pause_stack, {
            reason: _reason,
            speed: _target_speed
        });
        
        // Update current state
        UpdatePauseState();
        
        show_debug_message("PAUSE: " + GetReasonName(_reason) + " (speed: " + string(_target_speed) + ")");
    }
    
    /// @function Resume(_reason)
    /// @param {enum.PAUSE_REASON} _reason Which pause to resume from
    static Resume = function(_reason) {
        // Find and remove this reason from stack
        for (var i = array_length(pause_stack) - 1; i >= 0; i--) {
            if (pause_stack[i].reason == _reason) {
                array_delete(pause_stack, i, 1);
                break;
            }
        }
        
        // Update current state
        UpdatePauseState();
        
        show_debug_message("RESUME: " + GetReasonName(_reason));
    }
    
    /// @function ResumeAll()
    /// @description Resume everything (emergency unpause)
    static ResumeAll = function() {
        pause_stack = [];
        UpdatePauseState();
        show_debug_message("RESUME ALL - Emergency unpause");
    }
    
    /// @function UpdatePauseState()
    /// @description Update pause state based on stack
    static UpdatePauseState = function() {
        if (array_length(pause_stack) == 0) {
            // Nothing pausing us
            is_paused = false;
            current_reason = PAUSE_REASON.NONE;
            target_speed = 1.0;
			show_debug_message("UPDATE PAUSE STATE: nothing paused us")
        } else {
            // Get top of stack (most recent pause)
            var top = pause_stack[array_length(pause_stack) - 1];
            is_paused = true;
            current_reason = top.reason;
            target_speed = top.speed;
			show_debug_message("UPDATE PAUSE STATE: Is Paused: " + string(target_speed));
        }
    }
    
    /// @function Update()
    /// @description Call every frame to update game speed
    static Update = function() {
        // Smoothly lerp to target speed
        if (current_speed != target_speed) {
            var diff = target_speed - current_speed;
            show_debug_message("Target_Speed: " + string(target_speed));
            if (abs(diff) < 0.01) {
                current_speed = target_speed;
            } else {
                current_speed += diff * 0.15;
            }
        }
        show_debug_message("current_Speed: " + string(current_speed));
        // Update global
        global.gameSpeed = current_speed;
		
				if (is_paused) {
		    if (global.gameSpeed > 0) {
		        show_debug_message("WARNING: gameSpeed reset after pause_manager.Update()");
		    }
}
    }
    
    /// @function IsPaused()
    /// @returns {bool} Whether game is paused
    static IsPaused = function() {
        return is_paused;
    }
    
    /// @function GetCurrentReason()
    /// @returns {enum.PAUSE_REASON} Current pause reason
    static GetCurrentReason = function() {
        return current_reason;
    }
    
    /// @function IsPausedBy(_reason)
    /// @param {enum.PAUSE_REASON} _reason Reason to check
    /// @returns {bool} Whether this specific reason is active
    static IsPausedBy = function(_reason) {
        for (var i = 0; i < array_length(pause_stack); i++) {
            if (pause_stack[i].reason == _reason) {
                return true;
            }
        }
        return false;
    }
    
    /// @function GetReasonName(_reason)
    /// @param {enum.PAUSE_REASON} _reason
    /// @returns {string} Human-readable name
    static GetReasonName = function(_reason) {
        switch (_reason) {
            case PAUSE_REASON.NONE: return "None";
            case PAUSE_REASON.CHEST_OPENING: return "Chest Opening";
            case PAUSE_REASON.LEVEL_UP: return "Level Up";
            case PAUSE_REASON.TOTEM_SHOP: return "Totem Shop";
            case PAUSE_REASON.PAUSE_MENU: return "Pause Menu";
            case PAUSE_REASON.DIALOGUE: return "Dialogue";
            case PAUSE_REASON.GAME_OVER: return "Game Over";
            default: return "Unknown";
        }
    }
    
    /// @function GetGameSpeed()
    /// @returns {real} Current game speed
    static GetGameSpeed = function() {
        return current_speed;
    }
}