/// @description obj_sword - Create Event
event_inherited(); // Call parent create

// Override/customize sword-specific properties
swordSprite = spr_sword;
sprite_index = spr_sword;
attack = 15;
knockbackForce = 3;
angleOffset = 100;
swingSpeed = 6;
swordLength = 8;