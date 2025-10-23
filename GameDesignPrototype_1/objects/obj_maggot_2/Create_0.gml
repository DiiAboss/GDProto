/// @description
event_inherited();



damage_sys = new DamageComponent(self, 100); // 100 base HP
knockback = new KnockbackComponent(0.85, 0.1);

// Legacy compatibility
hp = damage_sys.hp;
maxHp = damage_sys.max_hp;
// Burst movement pattern (more maggot-like)
state = "idle";
burst_timer = 0;
burst_duration = 20; // Short burst
burst_progress = 0;

// Speed
base_speed = 0.75;
burst_speed = 5.0; // Fast burst
current_movement_speed = 0;

// Timing
idle_min = 20;
idle_max = 40;
idle_duration = irandom_range(idle_min, idle_max);

moveSpeed = 0;

// Squash and stretch for visual
squash_scale_x = 1.0;
squash_scale_y = 1.0;
