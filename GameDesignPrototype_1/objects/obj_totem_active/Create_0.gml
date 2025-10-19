/// @description Totem in world - now handles purchase interaction
totem_type = TotemType.CHAOS; // Set by spawner
totem_data = undefined; // Will be set

// Interaction
can_interact = true;
interaction_range = 64;
show_prompt = false;

// Visual
glow_timer = 0;
pulse_scale = 1.0;

// Set data based on type
totem_data = GetTotemByType(totem_type);