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

// When dealing damage (in weapon collision)
function DealDamageToEnemy(_enemy, _damage) {
    _enemy.hp -= _damage;
    
    // Class-specific on-hit effects
    switch (character_class) {
        case CharacterClass.WARRIOR:
            // Add extra knockback with rage
            _enemy.knockbackX *= (1 + rage_damage_bonus);
            _enemy.knockbackY *= (1 + rage_damage_bonus);
            break;
            
        case CharacterClass.HOLY_MAGE:
            // Chance to purify (remove debuffs)
            if (random(1) < 0.2) {
                _enemy.on_fire = false;
                _enemy.poisoned = false;
                _enemy.slowed = false;
            }
            break;
            
        case CharacterClass.VAMPIRE:
            // Lifesteal
            var heal = _damage * lifesteal;
            hp = min(hp + heal, hp_max);
            
            // Visual effect for lifesteal
            var blood = instance_create_depth(_enemy.x, _enemy.y, depth-1, obj_blood_drain);
            blood.target = id;
            break;
    }
}