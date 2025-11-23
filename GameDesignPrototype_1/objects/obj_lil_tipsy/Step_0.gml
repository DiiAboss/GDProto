/// @description Insert description here
// You can write your code in this editor
/// @description obj_lil_tipsy - Step Event

// Override parent damage system
if (immune_to_damage) {
    // Reset HP if somehow damaged
    if (hp < maxHp) {
        hp = maxHp;
        damage_sys.hp = maxHp;
    }
}
