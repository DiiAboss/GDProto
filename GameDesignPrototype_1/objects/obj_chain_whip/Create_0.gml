/// @description obj_chain_whip - Inherits from obj_melee_parent
/// CREATE EVENT
event_inherited();

// Override parent properties
baseRange = 128; // Max extended range
swordLength = 64; // Idle/resting length (3 links at 8px each)
swingSpeed = 8;
knockbackForce = 4;
damage = 20;

// Chain visual properties
chain_link_sprite = spr_chain_link;
chain_link_size = 8;
chain_wave_amplitude = 2;
chain_wave_speed = 0.2;
knife_sprite = spr_knife;

// Dynamic range during swing
current_range = swordLength;
idle_range = 24; // 3 links
max_extended_range = baseRange;

// Weapon ID
weapon_id = Weapon.ChainWhip;