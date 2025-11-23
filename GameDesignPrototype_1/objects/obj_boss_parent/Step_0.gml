/// @description obj_boss_parent - Step Event

if (global.gameSpeed == 0) exit;

// Update components
damage_sys.Update();
knockback.Update(self);
timers.Update();

// Sync legacy variables
hp = damage_sys.hp;
maxHp = damage_sys.max_hp;

// Visual timers
if (hitFlashTimer > 0) hitFlashTimer--;
if (shake > 0) shake *= 0.9;

// Health bar fade in/out
healthbar_alpha = lerp(healthbar_alpha, healthbar_target_alpha, 0.1);

// Check death
if (damage_sys.IsDead() && !boss_defeated) {
    boss_defeated = true;
    OnBossDefeated();
}

depth = -y;