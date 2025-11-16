// scr_player_functions - Add this function
function PlayerTakeDamage(_damage) {
    var actual_damage = _damage;
    
    // Class-specific damage modifications
    switch (character_class) {
        case CharacterClass.WARRIOR:
            // Armor reduction
            actual_damage = max(1, _damage - armor);
            
            // Build rage
            rage_damage_bonus = min(rage_damage_bonus + 0.1, class_stats.rage_max);
            break;
            
        case CharacterClass.HOLY_MAGE:
            // Use mana as shield if available
            if (mana > 10) {
                mana -= 10;
                actual_damage *= 0.5;  // Half damage
            }
            break;
            
        case CharacterClass.VAMPIRE:
            // Trigger blood frenzy when hurt
            blood_frenzy_timer = class_stats.blood_frenzy_duration;
            break;
    }
    
    hp -= actual_damage;
    
    // Damage number
    spawn_damage_number(x, y - 16, actual_damage, c_red, false);
}
