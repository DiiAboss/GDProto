function calculate_stats(self, base_attack, base_hp, base_knockback, base_spd) {
    var atk = base_attack;
    var hp  = base_hp;
    var kb  = base_knockback;
    var spd = base_spd;
	
	if !(variable_instance_exists(self, playerModsArray))
	{
		show_error("Could not find variable playerModsArray in object " + string(self.name), true);
	}
    
	var mods = self.playerModsArray;
	
    for (var i = 0; i < array_length(mods); i++) {
        var m = mods[i];
        atk += atk * m.attack;
        hp  += m.hp;
        kb  += m.knockback;
        spd += spd * m.spd;
    }
    
    return [atk, hp, kb, spd];
}


function takeDamage(_self, _damage, _damage_object = noone) {
    // Invincibility check (player only)
    if (variable_instance_exists(_self, "invincible") && _self.invincible) return false;
    
    _self.hp -= _damage;
    
    // Player-specific feedback
    if (_self.object_index == obj_player) {
        spawn_damage_number(_self.x, _self.y - 16, _damage, c_red, false);
        _self.hp_bar_visible_timer = _self.hp_bar_show_duration;
        
        // Start i-frames
        _self.invincible = true;
        _self.invincible_timer = _self.invincible_duration;
        
        // Optional: Knockback from source
        if (_damage_object != noone && instance_exists(_damage_object)) {
            var _dir = point_direction(_damage_object.x, _damage_object.y, _self.x, _self.y);
            _self.knockbackX = lengthdir_x(3, _dir);
            _self.knockbackY = lengthdir_y(3, _dir);
        }
        
        // Death check
        if (_self.hp <= 0) {
            // Add death logic or state change
            game_restart();
        }
    } else {
        // Enemy feedback
        spawn_damage_number(_self.x, _self.y - 16, _damage, c_orange, false);
    }
    
    return true;
}