/// @description Melee Parent - Create Event

owner = noone;
active = true;
baseRange = 32;

// Swing properties (YOUR ORIGINAL SYSTEM)
swinging = false;
isSwinging = false; // Alias for compatibility
startSwing = false;
swingSpeed = 8; // How fast the sword swings
swingProgress = 0; // 0 to 1, tracks swing completion


// Current position state (starts at down position)
currentPosition = SwingPosition.Down;
targetPosition = SwingPosition.Up;

// Position offsets from player direction
baseAngleOffset = 100;
angleOffsetMod = 1;
angleOffset = baseAngleOffset * angleOffsetMod;
downAngleOffset = angleOffset;
upAngleOffset = -angleOffset;
currentAngleOffset = downAngleOffset; // Start at down position

// Combat properties
attack = 10;
knockbackForce = 64;

// Combo tracking
comboCount = 0;
comboTimer = 0;
comboWindow = 30; // Steps to chain attacks

// Visual properties
swordLength = 12; // Distance from player center
swordSprite = sprite_index;

// Hit tracking
hasHitThisSwing = false;
hitList = ds_list_create();
hit_enemies = hitList; // Alias for compatibility

// Weapon type
weapon_id = Weapon.None;
current_combo_hit = 0;


/// @desc Spawn projectiles based on synergy config
function SpawnSynergyProjectiles(_synergy, _owner) {
    var count = _synergy.projectile_count ?? 1;
    var spread = _synergy.projectile_spread ?? 0;
    var base_dir = point_direction(_owner.x, _owner.y, mouse_x, mouse_y);
    
    var start_angle = base_dir - (spread * (count - 1)) / 2;
    
    for (var i = 0; i < count; i++) {
        var proj_dir = start_angle + (spread * i);
        
        var proj = instance_create_depth(
            _owner.x, 
            _owner.y, 
            _owner.depth - 1, 
            _synergy.projectile
        );
        
        proj.direction = proj_dir;
        proj.image_angle = proj_dir;
        proj.speed = 8;
        proj.owner = _owner;
        
        if (variable_instance_exists(proj, "damage")) {
            proj.damage = _owner.attack * 0.7;
        }
    }
}