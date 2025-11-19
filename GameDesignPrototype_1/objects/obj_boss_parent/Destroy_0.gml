/// @description Insert description here
// You can write your code in this editor
// Check if any doors need unlocking in this zone
var needs_key = CheckIfKeyNeeded();

if (needs_key && (is_boss || irandom(100) < 5)) {
    // Boss always drops, or 5% chance
    var key = instance_create_depth(x, y, -100, obj_key);
    key.moveY = -6;
    key.moveX = random_range(-2, 2);
}

/// @function CheckIfKeyNeeded()
function CheckIfKeyNeeded() {
    var zone_key = "";
    switch(obj_main_controller.current_zone) {
        case MAP_ZONE.FOREST: zone_key = "forest"; break;
        case MAP_ZONE.DESERT: zone_key = "desert"; break;
        case MAP_ZONE.HELL: zone_key = "hell"; break;
        default: return false;
    }
    
    var doors = global.SaveData.discovered_doors[$ zone_key];
    
    // If ANY door is locked, key is needed
    return (
        (!variable_struct_exists(doors, "arena") || !doors.arena) ||
        (!variable_struct_exists(doors, "challenge") || !doors.challenge) ||
        (!variable_struct_exists(doors, "boss") || !doors.boss)
    );
}