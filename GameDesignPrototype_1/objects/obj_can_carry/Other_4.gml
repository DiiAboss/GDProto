/// @description
/// @desc Carriable Object Base

// Carrying state
can_be_carried = true;
is_being_carried = false;
carrier = noone;

// Carry properties
carry_offset_x = 0;
carry_offset_y = -16; // Above head by default
carry_depth_offset = -1;

// Physics when not carried
moveX = 0;
moveY = 0;
friction_amount = 0.92;
speed_threshold = 0.5;
bounce_dampening = 0.5;

// Throw properties
throw_force = 10;
can_be_thrown = true;

// Interaction
interaction_range = 32;
interaction_key = ord("E");
interaction_text = "[E]";

// Weight (affects throw distance and player speed)
weight = 1.0; // 1.0 = normal, 2.0 = heavy, 0.5 = light

depth = -y;

// Projectile state (when thrown)
is_projectile = false;
is_lob_shot = false;
is_charged_throw = false;
projectile_speed = 0;
damage = 100; // Base damage when thrown
destroy_on_impact = true;
thrown_direction = 0;

// Lob arc variables
lob_direction = 0;
targetDistance = 0;
xStart = x;
yStart = y;
lobHeight = 32;
lobProgress = 0;

// Visual effects
has_trail = false;
trail_color = c_white;

// Store what this object was before being thrown
original_object = object_index;


// Shadow variables
shadowX = x;
shadowY = y;
shadow_offset = 4; // Distance below object
shadow_alpha = 0.3;
shadow_scale = 1.0;

// Lob arc shadow tracking
targetX = x;
targetY = y;
lobStep = 0; // 0.0 to 1.0 progress
loaded = false;

// Knockback component (like enemies have)
knockback = new KnockbackComponent(0.85, 0.1);

// Hit tracking for melee weapons
hit_cooldown = 0;
hit_cooldown_max = 10; // Frames before can be hit again
last_hit_by = noone;

// Physics properties when hit
can_be_knocked = true; // Can this object be knocked around?
hit_resistance = 1.0; // 1.0 = normal, 2.0 = heavy/less knockback, 0.5 = light/more knockback

// Visual feedback
hitFlashTimer = 0;
shake = 0;

// Pit fall system
is_falling = false;
fall_timer = 0;
fall_duration = 20;
fall_entry_x = 0;
fall_entry_y = 0;
fall_start_depth = 0;

tile_layer = "Tiles_2";
tile_layer_id = layer_get_id(tile_layer);
tilemap_id = layer_tilemap_get_id(tile_layer_id);
damage_cooldown = 0;