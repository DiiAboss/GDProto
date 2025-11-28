/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
event_inherited();

// Bob animation when idle
if (!is_being_carried && !is_projectile) {
    bob_offset += 0.05;
    y += sin(bob_offset) * 0.5;
}

// Check door collision when thrown
if (is_projectile) {
    var door = instance_place(x, y, obj_portal_door);
    if (door != noone && !door.is_unlocked) {
        UnlockDoor(door);
    }
}