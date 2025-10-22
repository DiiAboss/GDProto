/// @description Summoner Demon - Spawns demons and dashers
event_inherited();

// HP and damage system
damage_sys = new DamageComponent(self, 300);
hp = damage_sys.hp;
maxHp = damage_sys.max_hp;

// Damage tracking (for overkill system)
total_damage_taken = 0;
last_hit = noone;
last_damage_taken = 0;

// Spawning properties
spawner_timer = 300;
summon_timer = 60;
nextX = x;
nextY = y;
nextType = 0;

// Spawn boundaries
x_min = x - 12;
x_max = x + 12;
y_min = y;
y_max = y + 16;

// Resistance system
melee_resistance = 1.0;      // Normal damage from melee
ranged_resistance = 0.25;    // 75% reduction from ranged
thrown_resistance = 1.5;     // 50% MORE damage from thrown objects

// Visual feedback
hitFlashTimer = 0;
scored_this_death = false;
score_value = 50; // Good reward for destroying it

// What this summoner spawns
spawn_pool = [obj_enemy_bomber, obj_enemy_dasher];

activated = false;