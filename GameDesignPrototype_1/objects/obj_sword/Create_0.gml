/// @description obj_sword - Create Event
event_inherited(); // Call parent create

// Override/customize sword-specific properties
swordSprite = spr_sword;
sprite_index = spr_sword;
attack = 10;
knockbackForce = 4;
angleOffset = 100;
swingSpeed = 8;
swordLength = 8;