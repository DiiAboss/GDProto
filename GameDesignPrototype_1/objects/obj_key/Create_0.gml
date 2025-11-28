/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();

// Simple master key - unlocks any door
sprite_index = spr_key; // Single sprite
weight = 0.5;
throw_force = 8;
destroy_on_impact = false;

// Visual bob
bob_offset = 0

/// @function UnlockDoor(_door)
function UnlockDoor(_door) {
    _door.is_unlocked = true;
    
    // Save permanently
    obj_main_controller.UnlockDoor(_door.target_zone, _door.door_type);
    
    // VFX
    repeat(20) {
        var p = instance_create_depth(_door.x, _door.y, -y-1, obj_particle);
        p.direction = random(360);
        p.speed = random_range(2, 5);
        p.particle_color = c_yellow;
    }
    
    // Reward
    AddSouls(50);
    spawn_damage_text(x, y - 32, "DOOR UNLOCKED!");
    
    instance_destroy();
};