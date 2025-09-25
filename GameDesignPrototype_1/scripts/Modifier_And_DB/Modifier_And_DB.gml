

function get_mod_by_id(_id) {
    for (var i = 0; i < array_length(obj_game_manager.allMods); i++) {
        if (obj_game_manager.allMods[i].id == _id) {
            return obj_game_manager.allMods[i];
        }
    }
    return undefined;
}


function mod_third_strike(player, _mod) {
    if (player.attack_counter mod 3 == 0) {
        player.attack *= 2;
    }
}

function mod_heal_on_kill(player, _mod, enemy) {
    player.hp = clamp(player.hp + 5, 0, player.maxHp);
}


