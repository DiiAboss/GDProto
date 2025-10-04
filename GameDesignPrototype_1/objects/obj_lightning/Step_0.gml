/// @description
// obj_lightning: Step Event
life -= 1;
alpha = life / 8; // fade out over time
if (life <= 0) instance_destroy();
