/// @description Insert description here
// You can write your code in this editor
if (instance_exists(obj_player_spawn))
{
    var _x_spawn = obj_player_spawn.x;
    var _y_spawn = obj_player_spawn.y;
    var _player = instance_create_layer(_x_spawn, _y_spawn, "Instances", obj_player);
	ApplyLoadoutToPlayer(_player);
	ApplyWeaponsToPlayer(_player, menu_system.selected_character_class);
    _player.input = player_input;
    input_caller = _player;
}

