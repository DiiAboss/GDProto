/// @description
/// @desc Active totem visual

totem_type = TotemType.CHAOS; // Set when spawned
totem_data = undefined;

// Visual effects
glow_scale = 1.0;
glow_timer = 0;
pulse_speed = 0.03;

// Particle effect
particle_timer = 0;
particle_interval = 20;

// Color based on type
totem_colors = [
    c_red,      // Chaos
    c_orange,   // Horde
    c_purple,   // Champion
    c_yellow,   // Greed
    c_fuchsia   // Fury
];

totem_color = totem_colors[totem_type];

depth = -y;

// Sprite (use placeholder or create totem sprite)
sprite_index = spr_chest; // Replace with spr_totem when created