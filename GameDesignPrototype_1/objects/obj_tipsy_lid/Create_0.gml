/// @description obj_tipsy_lid - Create Event
event_inherited();

// OVERRIDE ROLLING BALL SETTINGS
sprite_index = spr_tipsy_top;
maxSpeed = 12;
mySpeed = 6;

// Remove timed destruction
alarm[0] = -1; // Disable auto-destroy

// Custom properties
parent_tipsy = noone;
returning_to_parent = false;

// Falling state
falling = false;
fall_target_y = 0;
fall_shadow_x = x;
fall_shadow_y = y;
fall_speed = 0;
fall_acceleration = 0.5;