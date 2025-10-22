/// @description
/// obj_enemy_attack_orb - Collision with obj_player
if (instance_exists(obj_player)) {
	obj_player.damage_sys.TakeDamage(10, self);
    //takeDamage(obj_player, 10, id); // 10 damage, pass self as source
    instance_destroy();
}