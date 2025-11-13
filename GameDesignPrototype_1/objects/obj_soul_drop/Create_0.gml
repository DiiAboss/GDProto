/// @description Insert description here
// You can write your code in this editor
sprite_index = spr_orb; // Use existing orb sprite or create spr_soul
image_speed = 0;
image_blend = c_aqua; // Cyan color for souls
image_xscale = 0.5;
image_yscale = 0.5;

// Movement
z = 0;
z_velocity = -2; // Float upward
gravity_z = 0.1;

// Lifespan
lifetime = 180; // 3 seconds
timer = 0;

// Collection
collect_radius = 64;
magnet_speed = 8;
being_collected = false;

// Value
soul_value = 1;

// Fade
alpha = 1;