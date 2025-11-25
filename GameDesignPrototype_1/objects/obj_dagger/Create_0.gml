/// obj_dagger Create Event
event_inherited();
weapon_id = Weapon.Dagger;
sprite_index = spr_dagger;
swing_arc = 70;  // Narrower arc
swing_speed = 18; // Faster swing
knockbackForce = 6;    // Very low knockback
attack = 7;            // Lower base damage

target = noone;

// Lunge tracking
is_lunging = false;
lunge_distance = 0;

// Narrower swing arc for stabbing motion
angleOffset = 50;      // Narrower arc (was 100)
baseAngleOffset = 50;