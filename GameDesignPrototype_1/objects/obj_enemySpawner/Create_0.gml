/// @description Enemy Spawner with progressive difficulty
spawner_timer = 300;
summon_timer = 60;

nextX = 0;
nextY = 0;

enum ENEMY_TYPE {
    CIRCLE = 0,
    TRIANGLE = 1,
    JUMPER = 2,
    DASHER = 3,
    BOMBER = 4,
}

nextType = 0;

x_min = 350;
y_min = 180;
x_max = 990;
y_max = 570;

spawn_rate_multiplier = 1.0;

// Progressive spawn pool
current_spawn_pool = [obj_maggot, obj_enemy_2]; // Start with just basic enemy
spawn_pool_updated = false;