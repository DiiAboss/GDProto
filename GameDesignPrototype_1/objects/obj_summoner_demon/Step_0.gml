var _dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);
if (_dist_to_player) < 400
{
	activated = true;
}

if !activated exit;

/// @description Summoner behavior
event_inherited();

// Hit flash effect
if (hitFlashTimer > 0) hitFlashTimer--;

// Death check
if (hp <= 0 && !scored_this_death) {
    scored_this_death = true;
    
    // Award score
    if (instance_exists(obj_game_manager) && obj_game_manager.score_manager) {
        obj_game_manager.score_manager.AddScore(score_value);
    }
    
    // Death effects
    repeat(15) {
        var p = instance_create_depth(x, y, depth - 1, obj_particle);
        p.direction = random(360);
        p.speed = random_range(2, 6);
        p.image_blend = choose(c_red, c_orange, c_purple);
    }
    
    instance_destroy();
    exit;
}

// Spawning logic
if (spawner_timer > 0) {
    spawner_timer--;
    nextX = irandom_range(x_min, x_max);
    nextY = irandom_range(y_min, y_max);
    summon_timer = 60;
} else {
    if (summon_timer > 0) {
        summon_timer--;
    } else {
        // Spawn random enemy from pool
        var spawn_type = spawn_pool[irandom(array_length(spawn_pool) - 1)];
        var enemy = instance_create_depth(nextX, nextY, depth, spawn_type);
		obj_enemy_controller.ApplyDifficultyToEnemy(enemy);
        spawner_timer = 300;
    }
}