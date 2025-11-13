function spawn_damage_number(_x, _y, _damage, _color = c_white, _isCrit = false) {
    var dmgNum = instance_create_depth(_x, _y, -1000, obj_damage_number); // High depth to draw on top
    var _range = random_range(0.8, 1.2);
    var _floatSpeed = _range;
	
	
	if !(is_string(_damage))
	{
		dmgNum.damage = _damage;
		 // Different colors for different damage amounts
	    if (_damage >= 50) {
	        dmgNum.scale = 1;
	        dmgNum.floatSpeed = _floatSpeed * 2.5;
	    } else if (_damage >= 20) {
	        dmgNum.scale = 1.1;
	    }
	}
	
    
    // Set damage value
    dmgNum.damageString = string(_damage);
    
    // Add some position randomness so multiple numbers don't stack
    dmgNum.x += random_range(-10, 10);
    dmgNum.y += random_range(-10, 10);
    
    // Set color based on damage type
    dmgNum.textColor = _color;
    
    // Critical hit settings
    if (_isCrit) {
        dmgNum.isCrit = true;
        dmgNum.damageString = string(_damage) + "!";
        dmgNum.scale = 1.3;
        dmgNum.floatSpeed = _floatSpeed * 3;
        dmgNum.lifetime = 80;
    }
    
   
    
    return dmgNum;
}


enum SPAWN_TEXT_TYPE
{
    NONE = 0,
    DAMAGE,
    CRIT,
    MISS,
    POSION,
    COMBO,
    HEAL,
    EXP
}

// More comprehensive version with damage types

function spawn_damage_text(_x, _y, _text, _type = SPAWN_TEXT_TYPE.DAMAGE) {
    var dmgNum = instance_create_depth(_x, _y, -1000, obj_damage_number);
    
    dmgNum.damageString = string(_text);
    dmgNum.x += random_range(-8, 8);
    dmgNum.y += random_range(-8, 8);
    
    // Configure based on type
    switch(_type) {
        case SPAWN_TEXT_TYPE.DAMAGE:
            dmgNum.textColor = c_white;
            dmgNum.outlineColor = c_red;
            break;
            
        case SPAWN_TEXT_TYPE.HEAL:
            dmgNum.textColor = c_lime;
            dmgNum.outlineColor = c_green;
            dmgNum.damageString = "+" + dmgNum.damageString;
            dmgNum.floatSpeed = 1.5;
            break;
            
        case SPAWN_TEXT_TYPE.CRIT:
            dmgNum.textColor = c_yellow;
            dmgNum.outlineColor = c_orange;
            dmgNum.isCrit = true;
            dmgNum.scale = 1.5;
            dmgNum.damageString = dmgNum.damageString + "!";
            break;
            
        case SPAWN_TEXT_TYPE.POSION:
            dmgNum.textColor = c_lime;
            dmgNum.outlineColor = c_purple;
            dmgNum.floatSpeed = 1;
            dmgNum.driftX = random_range(-1, 1);
            break;
            
        case "miss":
            dmgNum.textColor = c_gray;
            dmgNum.outlineColor = c_dkgray;
            dmgNum.damageString = "MISS";
            dmgNum.scale = 0.8;
            break;
            
        case SPAWN_TEXT_TYPE.COMBO:
            dmgNum.textColor = c_aqua;
            dmgNum.outlineColor = c_blue;
            dmgNum.scale = 1.2;
            dmgNum.lifetime = 90;
            break;
            
        case SPAWN_TEXT_TYPE.EXP:
            dmgNum.textColor = c_yellow;
            dmgNum.outlineColor = c_orange;
            dmgNum.damageString = "+" + dmgNum.damageString + " EXP";
            dmgNum.floatSpeed = 1;
            dmgNum.driftX = 0;
            break;
    }
    
    return dmgNum;
}