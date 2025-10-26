/// Projectile authoring + helpers
/// ------------------------------------------------------------
/// Role in the larger game:
///  - `global.Projectile_` is a lightweight catalog of projectile archetypes
///    (name/description/object) used by weapons to spawn instances.
///  - Helpers (`Shoot_Projectile`, `Create_Projectile`, `Lob_Projectile`, `lob`)
///    centralize spawn math and common fields so weapon code stays clean.
/// Integration notes:
///  - Catalog entries are data-only; objects (obj_arrow/obj_projectile/…) own
///    movement/collision/damage logic.
///  - `Shoot_Projectile` currently ignores `_object` and `_range`; it relies
///    on `_projectile_struct.object` for the instance type and doesn’t apply
///    range here (expected to be handled by the projectile itself). Leaving as-is.
///  - `img_xscale` vs `image_xscale`: bullets set `img_xscale`; if your
///    projectile sprite expects `image_xscale`, ensure your projectile object
///    mirrors/consumes the field accordingly.
///  - `lob()` uses external vars (`Accuracy`, `_owner.maxAccuracy`) by design;
///    treat it as a legacy/example lob spawner unless those fields exist.
/// ------------------------------------------------------------

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
    },
    Knife: {
        name: "knife",
        description: "Thrown dagger",
        object: obj_knife  // or obj_projectile if you don't have obj_knife yet
    },
    Holy_Water: {
        name: "Holy Water",
        description: "Lobbed Bottle Of Holy Water",
        object: obj_holy_water  // or obj_projectile if you don't have obj_holy_water yet
    },
    ChainKnife: {
        name: "Chain Knife",
        object: obj_chain_knife,
        speed: 12,   // Example defaults consumed by obj_chain_knife if desired
        damage: 10
    }
}

/// Catalog tag for downstream behavior selection in projectile objects.
enum PROJECTILE_TYPE
{
    NONE,
    NORMAL,
    LOB,
    CHAIN
}

/// Shoot_Projectile()
/// Spawns a projectile forward of the owner using an offset so bolts originate
/// near a weapon muzzle, not the owner’s center. Returns the instance.
/// Params:
///  _self: owner instance
///  _direction: fire angle (degrees)
///  _object: (unused here) legacy param
///  _range: (unused here) projectiles should enforce their own max range
///  _projectile_struct: entry from global.Projectile_ (must have .object)
///  _offset_x/_offset_y: muzzle offset in local space
function Shoot_Projectile(_self, _direction, _object, _range, _projectile_struct, _offset_x = 20, _offset_y = 20)
{
    // Used to project from the tip of a weapon instead of from the player center
    var _x_offset = lengthdir_x(_offset_x, _direction);
    var _y_offset = lengthdir_y(_offset_y, _direction);
    
    var _depth = _self.depth - 1;

    var _bullet          = Create_Projectile(_self.x + _x_offset, _self.y + _y_offset, _depth, _projectile_struct);
    _bullet.myDir        = _direction;       // Convenience copy for projectile
    _bullet.img_xscale   = _self.image_xscale; // See note above re: image_xscale
    _bullet.image_angle  = _direction;       // Face flight path
    _bullet.direction    = _direction;       // GM built-in used by motion code
    
    return _bullet;
}

/// Create_Projectile()
/// Thin factory over instance_create_depth that accepts a data struct.
function Create_Projectile(_x, _y, _depth, _projectile_struct)
{
    var _projectile = instance_create_depth(_x, _y, _depth, _projectile_struct.object);
    
    return _projectile;
}

/// @function Lob_Projectile(_self, _direction, _range, _projectile_object)
/// Spawns a lobbed projectile and seeds fields commonly read by a lob flight
/// controller (start pos, target distance, owner, base damage).
function Lob_Projectile(_self, _direction, _range, _projectile_object) {
    var proj = instance_create_depth(_self.x, _self.y, _self.depth - 1, _projectile_object);
    
    proj.direction = _direction;   // Initial heading
    proj.xStart = _self.x;         // Origin for arc/return calcs
    proj.yStart = _self.y;
    proj.targetDistance = _range;  // How far to travel before landing/return
    proj.owner = _self;            // Back-reference for damage credit
    proj.damage = _self.attack;    // Base damage seed
    
    // Store the direction for lobShot to use (explicit copy)
    proj.lob_direction = _direction;
    
    return proj;
}

/// lob()
/// Example/legacy single-shot lob spawner that introduces inaccuracy.
/// Uses external Accuracy/maxAccuracy fields; keep only if those exist in
/// your actor schema. Otherwise prefer `Lob_Projectile` above.
function lob(_owner, _direction, _distance, _projectile)
{
    #region Single Shot
    var _totalAcc     = 1;//abs((Accuracy * _owner.maxAccuracy) - (Accuracy * _owner.accuracy));
    var _acc          = clamp(_totalAcc, 0, _totalAcc);
            
    var _dir          = _direction + irandom_range(-_acc, _acc);
    var _bullet       = instance_create_depth(_owner.x, _owner.y, _owner.depth, _projectile);
    _bullet.owner     = _owner;
    _bullet.direction = _direction; // Note: _dir could be used for spread
    _bullet.speed     = 4;
    _bullet.targetDistance = _distance;
    _bullet.color     = c_white;
    #endregion Single Shot
}