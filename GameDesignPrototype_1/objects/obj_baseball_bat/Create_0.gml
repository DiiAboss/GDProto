/// @description

event_inherited();

weapon_id = Weapon.BaseballBat;
sprite_index = spr_bat;
swing_arc = 100;
swing_speed = 12;

// Sweet spot mechanics
sweet_spot_distance = 48; // Distance from owner where sweet spot exists
sweet_spot_radius = 32;    // How big the sweet spot is
sweet_spot_active_start = 0.3; // Swing progress when sweet spot activates
sweet_spot_active_end = 0.7;   // Swing progress when sweet spot deactivates

homerun_damage_mult = 3.0;     // Triple damage on sweet spot
homerun_knockback_mult = 5.0;  // 5x knockback on sweet spot

// Visual
sweet_spot_x = x;
sweet_spot_y = y;
hit_sweet_spot = false;

hit_sweet_spot_timer = 0;
dynamic_tracking = true; // Enable mouse tracking for bat