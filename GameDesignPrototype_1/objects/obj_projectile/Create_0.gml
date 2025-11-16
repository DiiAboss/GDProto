// === CORE PROPERTIES ===
projectileType = PROJECTILE_TYPE.NORMAL;
myDir = 0;
img_xscale = 1;
speed = 0;
life = 100;
active = true;
damage = 10;
owner = noone;
can_trigger_modifiers = true;

// === MOVEMENT PROPERTIES ===
// Standard movement
moveX = 0;
moveY = 0;
acceleration = 0;
max_speed = 20;
min_speed = 0;

// Physics
friction_amount = 1.0;  // 1.0 = no friction
gravity_strength = 0;
bounce_dampening = 0.8;
can_bounce = false;
bounces_remaining = 0;
max_bounces = 0;

// === PIERCING PROPERTIES ===
piercing = false;
pierce_count = 0;
pierced_enemies = ds_list_create();  // Track who we've hit
pierce_damage_falloff = 1.0;  // Multiplier per pierce

// === HOMING PROPERTIES ===
is_homing = false;
homing_target = noone;
homing_strength = 0.05;  // How aggressively it turns
homing_range = 200;
homing_delay = 0;  // Frames before homing activates

// === CHAIN PROPERTIES ===
can_chain = false;
chain_range = 100;
chains_remaining = 0;
chain_damage_falloff = 0.8;
chained_enemies = ds_list_create();

// === SPLIT PROPERTIES ===
can_split = false;
split_count = 0;
split_on_hit = false;
split_on_death = false;
split_angle_spread = 30;
split_damage_mult = 0.5;

// === ORBIT PROPERTIES ===
is_orbiting = false;
orbit_center_x = x;
orbit_center_y = y;
orbit_radius = 50;
orbit_speed = 5;
orbit_angle = 0;
orbit_duration = 0;

// === BOOMERANG PROPERTIES ===
is_boomerang = false;
boomerang_returning = false;
boomerang_max_distance = 200;
boomerang_catch_radius = 20;
distance_traveled = 0;

// === ELEMENTAL PROPERTIES ===
element_type = ELEMENT.PHYSICAL;
burn_chance = 0;
freeze_chance = 0;
shock_chance = 0;
poison_chance = 0;

// Status effect strengths
burn_duration = 0;
burn_damage = 0;
freeze_duration = 0;
slow_multiplier = 0;
shock_duration = 0;
poison_duration = 0;
poison_damage = 0;

// === EXPLOSION PROPERTIES ===
explode_on_death = false;
explode_on_hit = false;
explosion_radius = 50;
explosion_damage = 0;
explosion_knockback = 5;
create_shrapnel = false;
shrapnel_count = 4;

// === SPECIAL BEHAVIORS ===
// Trail
leaves_trail = false;
trail_type = noone;  // Fire, ice, poison trails
trail_duration = 60;
trail_damage = 1;
trail_interval = 5;
trail_timer = 0;

// Vacuum effect (pulls enemies)
has_vacuum = false;
vacuum_range = 80;
vacuum_strength = 0.1;

// Pinball mode
pinball_mode = false;
screen_bounce_damage_bonus = 0.1;  // +10% damage per screen bounce
screen_bounces = 0;

// Time manipulation
causes_slowdown = false;
slowdown_radius = 100;
slowdown_strength = 0.5;
slowdown_duration = 30;

// === VISUAL PROPERTIES ===
sprite = sprite_index;
img = -1;
color = c_white;
has_afterimage = false;
afterimage_interval = 2;
afterimage_timer = 0;
rotation_speed = 0;
pulse_scale = false;
pulse_speed = 0.1;
pulse_amount = 0.2;

// === LOB SPECIFIC ===
lobbed = false;
startTime = current_time;
xStart = x;
yStart = y;
progress = 0;
targetDistance = 0;
lobStep = 0;
targetX = 0;
targetY = 0;
groundShadowY = 0;
shadowSprite = spr_orb;
drawDirection = direction;

// === TRACKING ===
hits_landed = 0;
enemies_killed = 0;
distance_from_owner = 0;
time_alive = 0;
destroy = false;

// === FROM MODIFIERS ===
from_corpse_explosion = false;
modifier_source = "";  // Track which modifier created this


/// @description
/// @function HandleEnemyHit(_enemy)
function HandleEnemyHit(_enemy) {
    // Check if we've already hit this enemy (for piercing)
    if (piercing && ds_list_find_index(pierced_enemies, _enemy) != -1) {
        return;  // Already hit this enemy
    }
    
    // Apply damage with pierce falloff
    var actual_damage = damage;
    if (piercing) {
        actual_damage *= power(pierce_damage_falloff, ds_list_size(pierced_enemies));
        ds_list_add(pierced_enemies, _enemy);
    }
    
    // Deal damage
    _enemy.damage_sys.TakeDamage(actual_damage, owner);
    _enemy.last_hit_by = owner;
    hits_landed++;
    
    // Apply knockback
    if (_enemy.knockback.cooldown <= 0) {
        var kb_dir = point_direction(x, y, _enemy.x, _enemy.y);
        var kb_force = 5 * (1 + screen_bounces * 0.2);  // Bonus for pinball
        _enemy.knockback.Apply(kb_dir, kb_force);
    }
    
    // Trigger modifiers
    if (owner != noone && instance_exists(owner) && can_trigger_modifiers) {
        var hit_event = CreateProjectileHitEvent(owner, id, _enemy, actual_damage);
        TriggerModifiers(owner, MOD_TRIGGER.ON_HIT, hit_event);
    }
    
    // Check for special behaviors
    if (explode_on_hit) {
        CreateExplosion();
    }
    
    if (can_split && split_on_hit) {
        CreateSplitProjectiles();
    }
    
    if (causes_slowdown) {
        CreateSlowdownZone();
    }
    
    // Destroy if not piercing
    if (!piercing || pierce_count <= 0) {
        HandleProjectileDeath();
    } else {
        pierce_count--;
    }
}

/// @function HandleProjectileDeath()
function HandleProjectileDeath() {
    // Special death behaviors
    if (explode_on_death) {
        CreateExplosion();
    }
    
    if (can_split && split_on_death) {
        CreateSplitProjectiles();
    }
    
    // Clean up
    if (ds_exists(pierced_enemies, ds_type_list)) {
        ds_list_destroy(pierced_enemies);
    }
    if (ds_exists(chained_enemies, ds_type_list)) {
        ds_list_destroy(chained_enemies);
    }
    
    instance_destroy();
}

/// @function CreateExplosion()
function CreateExplosion() {
    var expl = instance_create_depth(x, y, depth - 10, obj_explosion);
    expl.radius = explosion_radius;
    expl.damage = explosion_damage;
    expl.knockback_force = explosion_knockback;
    expl.owner = owner;
    
    if (create_shrapnel) {
        for (var i = 0; i < shrapnel_count; i++) {
            var shrap = instance_create_depth(x, y, depth, object_index);
            shrap.direction = (360 / shrapnel_count) * i;
            shrap.speed = 8;
            shrap.damage = damage * 0.3;
            shrap.life = 30;
            shrap.can_trigger_modifiers = false;
        }
    }
}

/// @function CreateSplitProjectiles()  
function CreateSplitProjectiles() {
    for (var i = 0; i < split_count; i++) {
        var split = instance_create_depth(x, y, depth, object_index);
        var angle_offset = (i - split_count/2) * split_angle_spread;
        split.direction = direction + angle_offset;
        split.speed = speed * 0.8;
        split.damage = damage * split_damage_mult;
        split.life = life * 0.5;
        split.can_split = false;  // Prevent infinite splitting
        split.can_trigger_modifiers = false;
    }
}





alarm[0] = 1;

