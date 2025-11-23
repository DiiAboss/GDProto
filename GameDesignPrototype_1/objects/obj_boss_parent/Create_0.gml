/// @description obj_boss_parent - Create Event
// Universal boss object that all bosses inherit from

// COMPONENT SYSTEMS
damage_sys = new DamageComponent(self, 1000); // Default, override in child
stats = new StatsComponent(10, 1000, 2, 5);
knockback = new KnockbackComponent(0.85, 0.1);
timers = new TimerComponent();
intro_dialogue = ""; // Add near top of Create event
// Boss-specific variables
is_boss = true;
boss_name = "Boss";
boss_intro_played = false;
boss_defeated = false;

// Health tracking
hp = damage_sys.hp;
maxHp = damage_sys.max_hp;

// Damage multipliers (can be overridden in children)
damage_multiplier_rock = 2.0;      // Thrown rocks
damage_multiplier_baseball = 2.0;  // Thrown baseballs
damage_multiplier_standard = 1.0;  // Everything else

// Visual effects
hitFlashTimer = 0;
shake = 0;
marked_for_death = false;

// Boss health bar settings
healthbar_visible = false;
healthbar_y = 60; // Top center, above modifiers
healthbar_alpha = 0;
healthbar_target_alpha = 0;

depth = -y;