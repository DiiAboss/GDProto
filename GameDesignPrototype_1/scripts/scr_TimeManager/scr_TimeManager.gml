/// @description TimeManager Constructor
/// Create: scr_time_manager.gml

// ==========================================
// ENUMS
// ==========================================

enum TIME_STATE {
    STOPPED,
    RUNNING,
    PAUSED
}

// ==========================================
// TIME MANAGER CONSTRUCTOR
// ==========================================

/// @function TimeManager()
/// @description Manages game time, intervals, and time-based events
function TimeManager() constructor {
    
    // Core time tracking
    game_time = 0;           // Total frames elapsed
    game_time_seconds = 0;   // Total seconds
    game_time_minutes = 0;   // Total minutes
    
    // State
    state = TIME_STATE.STOPPED;
    
    // Intervals (for events that trigger every X seconds)
    intervals = {};
    
    // Session tracking
    session_start_time = 0;
    session_end_time = 0;
    total_paused_time = 0;
    pause_start_time = 0;
    
    // Milestones (achievements based on time survived)
    milestones = [];
    milestone_index = 0;
    
    // ==========================================
    // CORE FUNCTIONS
    // ==========================================
    
    /// @function Start()
    /// @description Start the timer
    static Start = function() {
        state = TIME_STATE.RUNNING;
        session_start_time = current_time;
    }
    
    /// @function Pause()
    /// @description Pause the timer
    static Pause = function() {
        if (state == TIME_STATE.RUNNING) {
            state = TIME_STATE.PAUSED;
            pause_start_time = current_time;
        }
    }
    
    /// @function Resume()
    /// @description Resume from pause
    static Resume = function() {
        if (state == TIME_STATE.PAUSED) {
            state = TIME_STATE.RUNNING;
            total_paused_time += (current_time - pause_start_time);
            pause_start_time = 0;
        }
    }
    
    /// @function Stop()
    /// @description Stop the timer completely
    static Stop = function() {
        state = TIME_STATE.STOPPED;
        session_end_time = current_time;
    }
    
    /// @function Update(_delta)
    /// @param {real} _delta Game speed delta
    static Update = function(_delta) {
        if (state != TIME_STATE.RUNNING) return;
        
        // Increment time
        game_time += _delta;
        
        // Calculate seconds and minutes
        var old_seconds = game_time_seconds;
        game_time_seconds = floor(game_time / 60);
        game_time_minutes = floor(game_time_seconds / 60);
        
        // Check if a new second passed
        if (game_time_seconds != old_seconds) {
            OnSecondPassed();
        }
        
        // Update intervals
        UpdateIntervals(_delta);
        
        // Check milestones
        CheckMilestones();
    }
    
    /// @function Reset()
    /// @description Reset timer for new game
    static Reset = function() {
        game_time = 0;
        game_time_seconds = 0;
        game_time_minutes = 0;
        state = TIME_STATE.STOPPED;
        total_paused_time = 0;
        pause_start_time = 0;
        session_start_time = 0;
        session_end_time = 0;
        milestone_index = 0;
        intervals = {};
    }
    
    // ==========================================
    // FORMATTING
    // ==========================================
    
    /// @function GetFormattedTime(_include_milliseconds)
    /// @param {bool} _include_milliseconds Include milliseconds
    /// @returns {string} Formatted time string "MM:SS" or "MM:SS.MS"
    static GetFormattedTime = function(_include_milliseconds = false) {
        var mins = game_time_minutes;
        var secs = game_time_seconds % 60;
        
        var min_str = mins < 10 ? "0" + string(mins) : string(mins);
        var sec_str = secs < 10 ? "0" + string(secs) : string(secs);
        
        if (_include_milliseconds) {
            var frames = game_time % 60;
            var ms = floor((frames / 60) * 100);
            var ms_str = ms < 10 ? "0" + string(ms) : string(ms);
            return min_str + ":" + sec_str + "." + ms_str;
        }
        
        return min_str + ":" + sec_str;
    }
    
    /// @function GetTimeInSeconds()
    /// @returns {real} Total time in seconds
    static GetTimeInSeconds = function() {
        return game_time_seconds;
    }
    
    /// @function GetTimeInMinutes()
    /// @returns {real} Total time in minutes
    static GetTimeInMinutes = function() {
        return game_time_minutes;
    }
    
    /// @function GetRealTimeElapsed()
    /// @returns {real} Real time elapsed (including pauses) in milliseconds
    static GetRealTimeElapsed = function() {
        if (session_end_time > 0) {
            return session_end_time - session_start_time;
        }
        return (current_time - session_start_time);
    }
    
    /// @function GetActivePlayTime()
    /// @returns {real} Time actually playing (excluding pauses) in milliseconds
    static GetActivePlayTime = function() {
        return GetRealTimeElapsed() - total_paused_time;
    }
    
    // ==========================================
    // INTERVAL SYSTEM
    // ==========================================
    
    /// @function RegisterInterval(_name, _seconds, _callback, _repeat)
    /// @param {string} _name Unique identifier
    /// @param {real} _seconds Interval in seconds
    /// @param {function} _callback Function to call
    /// @param {bool} _repeat Whether to repeat (default true)
    static RegisterInterval = function(_name, _seconds, _callback, _repeat = true) {
        intervals[$ _name] = {
            interval: _seconds * 60, // Convert to frames
            timer: _seconds * 60,
            callback: _callback,
            repeat: _repeat,
            active: true
        };
    }
    
    /// @function RemoveInterval(_name)
    /// @param {string} _name Interval to remove
    static RemoveInterval = function(_name) {
        if (struct_exists(intervals, _name)) {
            struct_remove(intervals, _name);
        }
    }
    
    /// @function PauseInterval(_name)
    /// @param {string} _name Interval to pause
    static PauseInterval = function(_name) {
        if (struct_exists(intervals, _name)) {
            intervals[$ _name].active = false;
        }
    }
    
    /// @function ResumeInterval(_name)
    /// @param {string} _name Interval to resume
    static ResumeInterval = function(_name) {
        if (struct_exists(intervals, _name)) {
            intervals[$ _name].active = true;
        }
    }
    
    /// @function UpdateIntervals(_delta)
    /// @param {real} _delta Delta time
    static UpdateIntervals = function(_delta) {
        var names = struct_get_names(intervals);
        
        for (var i = 0; i < array_length(names); i++) {
            var name = names[i];
            var interval = intervals[$ name];
            
            if (!interval.active) continue;
            
            interval.timer -= _delta;
            
            if (interval.timer <= 0) {
                // Trigger callback
                interval.callback();
                
                if (interval.repeat) {
                    // Reset timer
                    interval.timer = interval.interval;
                } else {
                    // Remove one-shot interval
                    RemoveInterval(name);
                }
            }
        }
    }
    
    // ==========================================
    // MILESTONE SYSTEM
    // ==========================================
    
    /// @function SetupDefaultMilestones()
    /// @description Setup standard time milestones
    static SetupDefaultMilestones = function() {
        milestones = [
            { time_seconds: 30, name: "30 Seconds", triggered: false, callback: undefined },
            { time_seconds: 60, name: "1 Minute", triggered: false, callback: undefined },
            { time_seconds: 120, name: "2 Minutes", triggered: false, callback: undefined },
            { time_seconds: 180, name: "3 Minutes", triggered: false, callback: undefined },
            { time_seconds: 300, name: "5 Minutes", triggered: false, callback: undefined },
            { time_seconds: 600, name: "10 Minutes", triggered: false, callback: undefined },
            { time_seconds: 900, name: "15 Minutes", triggered: false, callback: undefined }
        ];
        milestone_index = 0;
    }
    
    /// @function AddMilestone(_seconds, _name, _callback)
    /// @param {real} _seconds Time in seconds
    /// @param {string} _name Milestone name
    /// @param {function} _callback Optional callback when reached
    static AddMilestone = function(_seconds, _name, _callback = undefined) {
        array_push(milestones, {
            time_seconds: _seconds,
            name: _name,
            triggered: false,
            callback: _callback
        });
        
        // Sort milestones by time
        array_sort(milestones, function(a, b) {
            return a.time_seconds - b.time_seconds;
        });
    }
    
    /// @function CheckMilestones()
    static CheckMilestones = function() {
        if (milestone_index >= array_length(milestones)) return;
        
        var current_milestone = milestones[milestone_index];
        
        if (game_time_seconds >= current_milestone.time_seconds && !current_milestone.triggered) {
            current_milestone.triggered = true;
            OnMilestoneReached(current_milestone);
            
            // Execute callback if exists
            if (current_milestone.callback != undefined) {
                current_milestone.callback();
            }
            
            milestone_index++;
        }
    }
    
    // ==========================================
    // EVENTS (Override these in game_manager)
    // ==========================================
    
    /// @function OnSecondPassed()
    /// @description Called every game second
    static OnSecondPassed = function() {
        // Override this in game_manager if needed
        // Example: spawn enemies, update difficulty
    }
    
    /// @function OnMilestoneReached(_milestone)
    /// @param {struct} _milestone The milestone that was reached
    static OnMilestoneReached = function(_milestone) {
        // Override this in game_manager
        // Example: show notification, trigger event
        show_debug_message("Milestone reached: " + _milestone.name);
    }
    
    // ==========================================
    // UTILITY
    // ==========================================
    
    /// @function IsRunning()
    /// @returns {bool} Whether timer is running
    static IsRunning = function() {
        return state == TIME_STATE.RUNNING;
    }
    
    /// @function IsPaused()
    /// @returns {bool} Whether timer is paused
    static IsPaused = function() {
        return state == TIME_STATE.PAUSED;
    }
    
    /// @function GetState()
    /// @returns {enum.TIME_STATE} Current state
    static GetState = function() {
        return state;
    }
    
    /// @function GetTimeData()
    /// @returns {struct} All time data for saving/display
    static GetTimeData = function() {
        return {
            formatted: GetFormattedTime(),
            seconds: game_time_seconds,
            minutes: game_time_minutes,
            frames: game_time,
            real_time: GetRealTimeElapsed(),
            active_time: GetActivePlayTime(),
            state: state
        };
    }
}

// ==========================================
// USAGE EXAMPLE
// ==========================================

/*
// In obj_game_manager Create Event:
time_manager = new TimeManager();
time_manager.SetupDefaultMilestones();

// Override milestone callback
time_manager.OnMilestoneReached = function(_milestone) {
    show_debug_message("TIME MILESTONE: " + _milestone.name);
    
    // Trigger narrator
    if (instance_exists(obj_tarlhs_narrator)) {
        obj_tarlhs_narrator.QueueDialogue(
            "You've survived " + _milestone.name + "... impressive.",
            "TARLHS",
            c_red,
            120
        );
    }
}

// Start timer when game begins
time_manager.Start();

// In obj_game_manager Step Event:
time_manager.Update(game_speed_delta());

// Register an interval (spawn enemies every 30 seconds)
time_manager.RegisterInterval("enemy_wave", 30, function() {
    show_debug_message("Spawning enemy wave!");
    // Spawn logic here
});

// Pause timer
time_manager.Pause();

// Resume timer
time_manager.Resume();

// Get formatted time for display
var time_string = time_manager.GetFormattedTime(); // "05:23"

// Get time data for game over screen
var time_data = time_manager.GetTimeData();
show_debug_message("Survived: " + time_data.formatted);

// Reset for new game
time_manager.Reset();
*/