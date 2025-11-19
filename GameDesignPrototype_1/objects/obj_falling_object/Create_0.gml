/// @desc obj_falling_object Create Event

// What to spawn on impact
spawn_on_land = obj_rock; // Can be obj_barrel, obj_trap, etc.
fall_speed = 0;
fall_acceleration = 0.3;
landed = false;

// Shadow system
shadow_x = x;
shadow_y = y;
shadow_alpha = 0.5;
shadow_scale = 0.5;

// Start above screen
start_height = -80;
y = start_height;

// Warning indicator
warning_timer = 60; // 1 second warning
show_warning = true;

tilemap_id = Overworld_Tileset;