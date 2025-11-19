/// @desc obj_zone_door Create Event

// Door properties
door_type = ROOM_TYPE.ARENA;
target_zone = MAP_ZONE.FOREST;
is_unlocked = false;
is_discovered = false;

// Visual
sprite_index = spr_door_arena; // Different sprites per type
door_text = "Arena Door";
unlock_text = "[E] Enter Arena";
locked_text = "Find the Arena Key";

// Room to return to
return_room = room;
return_x = x;
return_y = y;

// Discovery rewards
discovery_souls = 50;
first_clear_souls = 100;

// Check unlock status from save data
CheckUnlockStatus();

/// @function CheckUnlockStatus()
function CheckUnlockStatus() {
    var zone_key = GetZoneKey(target_zone);
    var door_key = GetDoorKey(door_type);
    
    // Check if discovered in save data
    if (variable_struct_exists(global.SaveData.discovered_doors, zone_key)) {
        var zone_doors = global.SaveData.discovered_doors[$ zone_key];
        is_discovered = variable_struct_exists(zone_doors, door_key) ? zone_doors[$ door_key] : false;
    }
    
    is_unlocked = is_discovered;
}

/// @function GetZoneKey(_zone)
function GetZoneKey(_zone) {
    switch(_zone) {
        case MAP_ZONE.FOREST: return "forest";
        case MAP_ZONE.DESERT: return "desert";
        case MAP_ZONE.HELL: return "hell";
        default: return "tutorial";
    }
}

/// @function GetDoorKey(_type)
function GetDoorKey(_type) {
    switch(_type) {
        case ROOM_TYPE.ARENA: return "arena";
        case ROOM_TYPE.CHALLENGE: return "challenge";
        case ROOM_TYPE.BOSS: return "boss";
        case ROOM_TYPE.SECRET: return "secret";
        default: return "unknown";
    }
}

/// @function EnterSubRoom()
function EnterSubRoom() {
    if (!is_unlocked) return;
    
    // Store return location in persistent controller
    with (obj_main_controller) {
        sub_room_return_data = {
            room: other.return_room,
            x: other.return_x,
            y: other.return_y,
            zone: other.target_zone,
            door_type: other.door_type
        };
    }
    
    // Transition to sub-room based on type
    switch(door_type) {
        case ROOM_TYPE.ARENA:
            room_goto(GetArenaRoom(target_zone));
            break;
        case ROOM_TYPE.CHALLENGE:
            room_goto(GetChallengeRoom(target_zone));
            break;
        case ROOM_TYPE.BOSS:
            room_goto(GetBossRoom(target_zone));
            break;
        case ROOM_TYPE.SECRET:
            room_goto(GetSecretRoom(target_zone));
            break;
    }
}

/// @function GetArenaRoom(_zone)
function GetArenaRoom(_zone) {
    switch(_zone) {
        case MAP_ZONE.FOREST: return rm_forest_arena;
        case MAP_ZONE.DESERT: return rm_desert_arena;
        case MAP_ZONE.HELL: return rm_hell_arena;
        default: return rm_demo_room;
    }
}

/// @function GetChallengeRoom(_zone)
function GetChallengeRoom(_zone) {
    switch(_zone) {
        case MAP_ZONE.FOREST: return rm_forest_challenge;
        case MAP_ZONE.DESERT: return rm_desert_challenge;
        case MAP_ZONE.HELL: return rm_hell_challenge;
        default: return rm_demo_room;
    }
}

/// @function GetBossRoom(_zone)
function GetBossRoom(_zone) {
    switch(_zone) {
        case MAP_ZONE.FOREST: return rm_forest_boss;
        case MAP_ZONE.DESERT: return rm_desert_boss;
        case MAP_ZONE.HELL: return rm_hell_boss;
        default: return rm_demo_room;
    }
}

/// @function GetSecretRoom(_zone)
function GetSecretRoom(_zone) {
    // Secret rooms can be procedural or hand-crafted
    return rm_secret_room;
}