if (instance_exists(obj_exp))
{
	with (obj_exp)
	{
		if (settled)
		{
			var _dist_to_player = point_distance(x, y, obj_player.x, obj_player.y);
			if (_dist_to_player <= 128)
			{
				direction = point_direction(x, y, obj_player.x, obj_player.y);
				speed += 0.1;
				
				if (_dist_to_player <= 4)
				{
					instance_destroy();
				}
			}
			else
			{
				speed = 0;
			}
		}
	}
}


// obj_game_controller : Step Event

// debug open with P
if (keyboard_check_pressed(ord("P"))) {
    // create if not present or was cleared
    if (!variable_global_exists("selection_popup") || global.selection_popup == undefined) {
        var opts = [
            { name: "Fireball",   desc: "Shoots a blazing orb.", sprite: modifier_bg },
            { name: "Lightning",  desc: "Strikes nearby foes.", sprite: modifier_bg },
            { name: "Healing",    desc: "Regains some HP.", sprite: modifier_bg }
        ];

        function _on_pick(index, option) {
            show_debug_message("Picked: " + option.name);
            // your pick logic (give item, apply mod, etc)
        }

        global.selection_popup = new SelectionPopup(display_get_gui_width()/2, display_get_gui_height()/2 - 40, opts, _on_pick);
    }
}


var popup = global.selection_popup;

if (popup != undefined) {
    popup.step();

    if (popup.finished) {
        global.selection_popup = undefined;
    }
}


/// @function gm_trigger_event(trigger, player, extra)
/// @desc Calls all mod effects for a given trigger
function gm_trigger_event(trigger, player, extra) {
    var mods = playerModsArray;

    for (var i = 0; i < array_length(mods); i++) {
        var m = mods[i];

        if (m.trigger == trigger && is_callable(m.effect)) {
            // Call effect with player and optional data
            m.effect(player, m, extra);
        }
    }
}


/// @function gm_calculate_player_stats(base_attack, base_hp, base_knockback, base_spd)
/// @returns [attack, hp, knockback, spd]
function gm_calculate_player_stats(base_attack, base_hp, base_knockback, base_spd) {
    var atk = base_attack;
    var hp  = base_hp;
    var kb  = base_knockback;
    var spd = base_spd;

    var mods = playerModsArray;

    for (var i = 0; i < array_length(mods); i++) {
        var m = mods[i];
        atk *= (1 + m.attack);
        hp  = round(hp + (1 + m.hp));
        kb  *= 1 + m.knockback;
        spd *= 1 + m.spd;
    }

    return [atk, hp, kb, spd];
}