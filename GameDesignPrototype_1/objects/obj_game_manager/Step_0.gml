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