/// @description DEATH CHECK
if (damage_sys.hp <= 0 && !obj_main_controller.death_sequence_active) {
	// Trigger death sequence through main controller
	obj_main_controller.death_sequence.Trigger(
	obj_game_manager,
	obj_player,
	obj_main_controller.highscore_system
);
}