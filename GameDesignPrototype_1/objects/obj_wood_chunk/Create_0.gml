event_inherited(); // Get base properties

// Override base properties
weight = 1.2; // Slightly heavy
throw_force = 12;
interaction_text = "[E]";

// Wood-specific properties
base_damage = 15;
velocity_damage_multiplier = 2;
knockback_multiplier = 1.5;
damage_cooldown = 0;
damage_cooldown_max = 10;

// Hit by sword
can_be_hit = true;
hit_force_multiplier = 3;

sprite_index = spr_wood_chunk;
image_angle = random(360);
rotation_speed = 0;
hit_flash = 0;

/// @func OnThrown(_thrower, _direction)
function OnThrown(_thrower, _direction) {
    rotation_speed = random_range(-15, 15);
    show_debug_message("Wood thrown!");
}

/// @func OnPickedUp(_picker)
function OnPickedUp(_picker) {
    image_angle = 0; // Reset rotation when picked up
    show_debug_message("Wood picked up!");
}