/// @description
// obj_fireball - Collision with enemy
if (owner != noone) {
    other.hp -= damage;
    instance_destroy();
}