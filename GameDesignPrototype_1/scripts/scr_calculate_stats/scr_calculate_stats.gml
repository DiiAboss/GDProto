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


function takeDamage(_self, _damage, _damage_object = noone)
{
	_self.hp -= _damage;
	spawn_damage_number(_self.x, _self.y - 16, _damage, c_orange, false);
	
}