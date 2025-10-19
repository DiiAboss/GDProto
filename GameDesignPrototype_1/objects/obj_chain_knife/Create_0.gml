/// @description obj_chain_knife
/// CREATE EVENT

owner = noone;
weapon_struct = noone;

// Movement
direction = 0;
speed = 12;
image_angle = direction;

// State
is_returning = false;
return_speed = 15;

// Range
start_x = x;
start_y = y;
max_distance = 80;
distance_traveled = 0;

// Damage
damage = 5;
has_hit = false;

// Visuals  
sprite_index = spr_knife;
image_speed = 0;
depth = -y;

// Chain visuals
chain_link_sprite = spr_chain_link;
chain_link_size = 8;