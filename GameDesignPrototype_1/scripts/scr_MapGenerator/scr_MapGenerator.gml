/// @desc scr_MapGenerator (NEW SECTION)

/// @function PlaceSubRoomDoors(_zone)
function PlaceSubRoomDoors(_zone) {
    var doors_to_place = [
        { type: ROOM_TYPE.ARENA, sprite: spr_door_arena },
        { type: ROOM_TYPE.CHALLENGE, sprite: spr_door_challenge },
        { type: ROOM_TYPE.BOSS, sprite: spr_door_boss }
    ];
    
    for (var i = 0; i < array_length(doors_to_place); i++) {
        var door_data = doors_to_place[i];
        
        // Find safe spawn location (not on pit, not near player spawn)
        var door_x = 0;
        var door_y = 0;
        var attempts = 0;
        var max_attempts = 50;
        
        var tile_layer_id = layer_get_id("Tiles_2");
        var tilemap_id = layer_tilemap_get_id(tile_layer_id);
        
        while (attempts < max_attempts) {
            door_x = irandom_range(100, room_width - 100);
            door_y = irandom_range(100, room_height - 100);
            
            var tile = tilemap_get_at_pixel(tilemap_id, door_x, door_y);
            var is_safe = (tile <= 446 && tile != 0);
            var far_from_spawn = point_distance(door_x, door_y, room_width/2, room_height/2) > 200;
            
            if (is_safe && far_from_spawn && !place_meeting(door_x, door_y, obj_obstacle)) {
                // Found valid spot
                var door = instance_create_depth(door_x, door_y, -100, obj_zone_door);
                door.door_type = door_data.type;
                door.target_zone = _zone;
                door.sprite_index = door_data.sprite;
                door.return_room = room;
                door.return_x = door_x;
                door.return_y = door_y;
                
                // Add visual indicator (glowing particle effect)
                CreateDoorParticles(door_x, door_y);
                
                break;
            }
            attempts++;
        }
        
        if (attempts >= max_attempts) {
            show_debug_message("WARNING: Could not place door: " + string(door_data.type));
        }
    }
}

/// @function CreateDoorParticles(_x, _y)
function CreateDoorParticles(_x, _y) {

}