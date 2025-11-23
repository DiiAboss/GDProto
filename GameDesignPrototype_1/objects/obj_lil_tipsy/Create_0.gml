/// @description obj_lil_tipsy - Create Event
event_inherited();


// OVERRIDE ENEMY SETTINGS
sprite_index = spr_lil_tipsy; // You'll need to create this
maxHp = 25;
hp = 25;
damage_sys.max_hp = 25;
damage_sys.hp = 25;

moveSpeed = 1.5;
baseSpeed = 1.5;

// IMMUNITY TO DAMAGE
immune_to_damage = true;

// Only dies from wall collision
death_from_wall = false;
min_shatter_speed = 2; // Must be moving at least this fast to shatter