/// @description Mission/Quest tracking system

// ==========================================
// MISSION DATA STRUCTURE
// ==========================================

global.Missions = {
    // Tutorial missions
    first_kill: {
        id: "first_kill",
        name: "First Blood",
        description: "Defeat your first enemy",
        reward_souls: 10,
        completed: false,
        progress: 0,
        goal: 1,
        type: "kills"
    },
    
    kill_10: {
        id: "kill_10",
        name: "Getting Started",
        description: "Defeat 10 enemies",
        reward_souls: 25,
        completed: false,
        progress: 0,
        goal: 10,
        type: "kills"
    },
    
    kill_100: {
        id: "kill_100",
        name: "Seasoned Hunter",
        description: "Defeat 100 enemies",
        reward_souls: 100,
        completed: false,
        progress: 0,
        goal: 100,
        type: "kills"
    },
    
    reach_level_5: {
        id: "reach_level_5",
        name: "Power Up",
        description: "Reach level 5 in a single run",
        reward_souls: 50,
        completed: false,
        progress: 0,
        goal: 5,
        type: "level"
    },
    
    score_5000: {
        id: "score_5000",
        name: "High Scorer",
        description: "Score 5000+ points in a run",
        reward_souls: 75,
        completed: false,
        progress: 0,
        goal: 5000,
        type: "score"
    },
    
    open_10_chests: {
        id: "open_10_chests",
        name: "Treasure Hunter",
        description: "Open 10 chests",
        reward_souls: 50,
        completed: false,
        progress: 0,
        goal: 10,
        type: "chests"
    }
};

// ==========================================
// MISSION FUNCTIONS
// ==========================================

/// @function InitializeMissions()
function InitializeMissions() {
    // Load mission progress from save data
    if (!variable_struct_exists(global.SaveData, "missions")) {
        global.SaveData.missions = {};
    }
    
    // Sync global missions with saved progress
    var mission_keys = variable_struct_get_names(global.Missions);
    for (var i = 0; i < array_length(mission_keys); i++) {
        var key = mission_keys[i];
        var mission = global.Missions[$ key];
        
        if (variable_struct_exists(global.SaveData.missions, key)) {
            var saved = global.SaveData.missions[$ key];
            mission.completed = saved.completed;
            mission.progress = saved.progress;
        }
    }
}

/// @function UpdateMission(_mission_id, _progress_amount)
function UpdateMission(_mission_id, _progress_amount = 1) {
    if (!variable_struct_exists(global.Missions, _mission_id)) return;
    
    var mission = global.Missions[$ _mission_id];
    
    // Skip if already completed
    if (mission.completed) return;
    
    // Update progress
    mission.progress += _progress_amount;
    
    // Check completion
    if (mission.progress >= mission.goal) {
        mission.progress = mission.goal;
        mission.completed = true;
        
        // Award souls
        AddSouls(mission.reward_souls);
        
        // Show notification
        ShowMissionComplete(mission);
        
        show_debug_message("MISSION COMPLETED: " + mission.name + " - Earned " + string(mission.reward_souls) + " souls!");
    }
    
    // Save progress
    SaveMissionProgress(_mission_id);
}

/// @function SaveMissionProgress(_mission_id)
function SaveMissionProgress(_mission_id) {
    if (!variable_struct_exists(global.Missions, _mission_id)) return;
    
    var mission = global.Missions[$ _mission_id];
    
    global.SaveData.missions[$ _mission_id] = {
        completed: mission.completed,
        progress: mission.progress
    };
    
    SaveGame();
}

/// @function ShowMissionComplete(_mission)
function ShowMissionComplete(_mission) {
    // TODO: Create a fancy UI notification
    // For now, just spawn text
    if (instance_exists(obj_player)) {
        spawn_damage_number(
            obj_player.x, 
            obj_player.y - 64, 
            "MISSION COMPLETE!\n" + _mission.name + "\n+" + string(_mission.reward_souls) + " Souls", 
            c_yellow, 
            false
        );
    }
}

/// @function GetActiveMissions()
/// @returns {array} Array of incomplete missions
function GetActiveMissions() {
    var active = [];
    var mission_keys = variable_struct_get_names(global.Missions);
    
    for (var i = 0; i < array_length(mission_keys); i++) {
        var key = mission_keys[i];
        var mission = global.Missions[$ key];
        
        if (!mission.completed) {
            array_push(active, mission);
        }
    }
    
    return active;
}

/// @function GetCompletedMissions()
/// @returns {array} Array of completed missions
function GetCompletedMissions() {
    var completed = [];
    var mission_keys = variable_struct_get_names(global.Missions);
    
    for (var i = 0; i < array_length(mission_keys); i++) {
        var key = mission_keys[i];
        var mission = global.Missions[$ key];
        
        if (mission.completed) {
            array_push(completed, mission);
        }
    }
    
    return completed;
}