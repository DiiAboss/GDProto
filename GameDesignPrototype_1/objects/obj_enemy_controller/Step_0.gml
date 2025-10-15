/// @description
// obj_enemy_controller - Step Event
with (obj_enemy) {
    // Basic movement behavior
    if (!marked_for_death && knockbackCooldown <= 0) {
        scr_enemy_behavior_basic();
    }

    // Optional: Group separation
    scr_enemy_separation();
}