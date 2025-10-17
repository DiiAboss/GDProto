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
        var is_player = (object_index == obj_player);
        
        // Players have invincibility
        if (is_player && invincibility.active) {
            return hp; // Still invincible
        }
        	

        // Apply damage
		_self.total_damage_taken += _damage;
        damage_sys.TakeDamage(_damage, _source);
        hp = damage_sys.hp;
        
        // Player-specific
        if (is_player) {
            invincibility.Activate();
            timers.Set("hp_bar", 120);
        }
        
        // Everyone can flash
        hitFlashTimer = 10;
        
        // Track damage
        last_hit_by = _source;
        took_damage = _damage;
        
        return hp;
    }
}