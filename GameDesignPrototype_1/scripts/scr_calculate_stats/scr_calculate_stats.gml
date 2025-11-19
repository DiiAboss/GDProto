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


/// @function takeDamage(_self, _damage, _source)
function takeDamage(_self, _damage, _source) {
    with (_self) {
        // Fast: check object type once
        var is_player = (_self == obj_player);
        
        // Players have invincibility
        if (is_player && _self.invincibility.active) {
            return _self.hp; // Still invincible
        }
        	

        // Apply damage
		//_self.total_damage_taken += _damage;
        _self.damage_sys.TakeDamage(_damage, _source);
        var _hp = damage_sys.hp;
		_self.hp = _hp;
        
        // Player-specific
        if (is_player) {
            _self.invincibility.Activate();
            _self.timers.Set("hp_bar", 120);
        }
        
        // Everyone can flash
        _self.hitFlashTimer = 10;
        
        // Track damage
        _self.last_hit_by = _source;
        _self.took_damage = _damage;
        
        return _hp;
    }
}