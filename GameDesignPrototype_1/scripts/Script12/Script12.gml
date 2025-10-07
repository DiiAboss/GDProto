global.Projectile_ = 
{
    Arrow: {
        name: "arrow",
        description: "Basic Arrow",
        object: obj_arrow
    },
    
    Cannonball: {
        name: "cannonball",
        description: "Heavy cannonball projectile",
        object: obj_projectile  // or obj_cannonball if you have a specific one
    },
    
    Boomerang: {
        name: "boomerang",
        description: "Returning projectile",
        object: obj_boomerang
    }
}



enum PROJECTILE_TYPE
{
	NONE,
	NORMAL,
	LOB,
	CHAIN
}


function Shoot_Projectile(_self, _direction, _object, _range, _projectile_struct, _offset_x = 20, _offset_y = 20)
{
	//var _angle_rad	= degtorad(_direction);
	
	// Used to project from the tip of a weapon instead of from the player center
	var _x_offset	= lengthdir_x(_offset_x, _direction);
	var _y_offset	= lengthdir_y(_offset_y, _direction);
	
	var _depth = _self.depth - 1;


	var _bullet		 	 = Create_Projectile(_self.x + _x_offset, _self.y + _y_offset, _depth, _projectile_struct);
	_bullet.myDir		 = _direction;
	_bullet.img_xscale	 = _self.image_xscale;
	_bullet.image_angle	 = _direction;
	_bullet.direction	 = _direction;
	
	return _bullet;
}


function Create_Projectile(_x, _y, _depth, _projectile_struct)
{
	var _projectile = instance_create_depth(_x, _y, _depth, _projectile_struct.object);
	
	return _projectile;
}

function Lob_Projectile(_self, _direction, _distance, _projectile)
{
	#region Single Shot
	var _totalAcc     = 1;//abs((Accuracy * _owner.maxAccuracy) - (Accuracy * _owner.accuracy));
	var _acc		  = clamp(_totalAcc, 0, _totalAcc);
			
	var _dir		  =	_direction + irandom_range(-_acc, _acc);
	var _bullet		  = instance_create_depth(_self.x, _self.y, _self.depth, _projectile);
	_bullet.projectileType = PROJECTILE_TYPE.LOB;
	_bullet.owner	  = _self;
	_bullet.direction = _direction;
	_bullet.speed     = 4;
	_bullet.targetDistance = _distance;
	_bullet.color     = c_white;
	#endregion Single Shot
	
	return _bullet;
}


function lob(_owner, _direction, _distance, _projectile)
{
	#region Single Shot
	var _totalAcc     = 1;//abs((Accuracy * _owner.maxAccuracy) - (Accuracy * _owner.accuracy));
	var _acc		  = clamp(_totalAcc, 0, _totalAcc);
			
	var _dir		  =	_direction + irandom_range(-_acc, _acc);
	var _bullet		  = instance_create_depth(_owner.x, _owner.y, _owner.depth, _projectile);
	_bullet.owner	  = _owner;
	_bullet.direction = _direction;
	_bullet.speed	  = 4;
	_bullet.targetDistance = _distance;
	_bullet.color     = c_white;
	#endregion Single Shot
}