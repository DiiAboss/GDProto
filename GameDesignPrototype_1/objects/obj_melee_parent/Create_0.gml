// Owner reference
owner = noone;

// Combat stats
attack = 10;
knockbackForce = 64;
swing_arc = 90;
swing_speed = 15;

// Swing state
startSwing = false;
isSwinging = false;
swing_progress = 0;
swing_direction = 0;

currentAngleOffset = 180;

// Combo tracking
current_combo_hit = 0;

// Weapon type identifier
weapon_id = Weapon.None;

// Hit tracking to prevent multi-hit
hit_enemies = ds_list_create();
dynamic_tracking = false; // Set to true for weapons that follow mouse