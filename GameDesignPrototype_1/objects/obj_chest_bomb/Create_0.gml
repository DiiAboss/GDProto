/// @description
// Visual
image_speed = 0;
image_index = 0;
wick_sprite = spr_chest; // Replace with wick sprite when you make it
wick_angle = 0;
fuse_lit = false;
fuse_timer = 0;
fuse_duration = 90; // 1.5 seconds

// Physics
hit_cooldown = 0;
move_speed = 0;
move_direction = 0;
friction_amount = 0.92;

// Damage
damage = 100;
explosion_radius = 128;
knockback_force = 20;

// State
exploded = false;

depth = -y;