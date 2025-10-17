/// @description Baseball Bat - Create Event
event_inherited();

// Customize bat properties
swordSprite = spr_way_better_bat;
sprite_index = spr_way_better_bat;
attack = 15;
knockbackForce = 100; // Bats hit harder!
swingSpeed = 10; // Slightly faster than sword

// Baseball bat specific - Sweet Spot System
sweet_spot_distance = 40; // Distance from player where sweet spot is
sweet_spot_radius = 20; // Size of sweet spot collision area
sweet_spot_active_start = 0.4; // When sweet spot becomes active (40% through swing)
sweet_spot_active_end = 0.6; // When sweet spot ends (60% through swing)

// Sweet spot tracking
sweet_spot_x = x;
sweet_spot_y = y;
hit_sweet_spot = false;
hit_sweet_spot_timer = 0;

// Home run multipliers
homerun_damage_mult = 3.0; // 3x damage on sweet spot
homerun_knockback_mult = 5.0; // 5x knockback on sweet spot