/// @description Insert description here
// You can write your code in this editor
/// @desc Step Event
if (global.gameSpeed <= 0) exit;
if (!instance_exists(arena_controller)) exit;

// Only spawn when arena controller requests it
if (!arena_controller.wave_active) exit;
if (arena_controller.enemies_spawned >= arena_controller.enemies_to_spawn) exit;

// Cooldown
if (spawn_cooldown > 0) {
    spawn_cooldown--;
    return;
}

// Spawn enemy
SpawnArenaEnemy();
arena_controller.enemies_spawned++;
spawn_cooldown = spawn_cooldown_max;
