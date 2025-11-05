/// @description
/// @description Weapon pickup on ground

// Weapon data - set by spawner
weapon_data = undefined; // Will hold the weapon struct
weapon_name = "Mystery Weapon";
weapon_sprite = spr_knife; // Default sprite

// Pickup properties
pickup_range = 48;
can_pickup = true;

// Float animation
float_timer = 0;
float_speed = 0.05;
float_height = 4;
base_y = y;

// Shadow
shadow_alpha = 0.3;
shadow_scale = 0.8;

// Glow effect
glow_timer = 0;
glow_pulse = 0;

// Interaction
show_prompt = false;

depth = -y;