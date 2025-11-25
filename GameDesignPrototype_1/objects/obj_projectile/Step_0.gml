/// @desc Enhanced Projectile Step with modifier support


// UPDATE TIMERS

time_alive++;
if (instance_exists(owner)) {
    distance_from_owner = point_distance(x, y, owner.x, owner.y);
}


// HOMING BEHAVIOR

if (is_homing && homing_delay <= 0) {
    // Find or validate target
    if (!instance_exists(homing_target) ||  homing_target.marked_for_death) {
        // Find new target
        homing_target = instance_nearest(x, y, obj_enemy);
        if (point_distance(x, y, homing_target.x, homing_target.y) > homing_range) {
            homing_target = noone;
        }
    }
    
    // Apply homing
    if (instance_exists(homing_target)) {
        var target_dir = point_direction(x, y, homing_target.x, homing_target.y);
        var current_dir = direction;
        var angle_diff = angle_difference(target_dir, current_dir);
        
        // Smooth turn toward target
        direction += angle_diff * homing_strength;
        speed = max(speed, min_speed);  // Maintain minimum speed
    }
} else if (homing_delay > 0) {
    homing_delay--;
}


// BOOMERANG BEHAVIOR

if (is_boomerang) {
    distance_traveled += speed;
    
    if (!boomerang_returning) {
        // Check if should return
        if (distance_traveled >= boomerang_max_distance) {
            boomerang_returning = true;
            speed *= -1;  // Reverse direction initially
        }
    } else {
        // Return to owner
        if (instance_exists(owner)) {
            var return_dir = point_direction(x, y, owner.x, owner.y);
            direction = return_dir;
            speed = abs(speed);  // Ensure positive speed
            
            // Check if caught
            if (point_distance(x, y, owner.x, owner.y) < boomerang_catch_radius) {
                // Trigger catch event
                if (variable_instance_exists(owner, "OnProjectileCaught")) {
                    owner.OnProjectileCaught(id);
                }
                instance_destroy();
            }
        }
    }
}


// ORBIT BEHAVIOR

if (is_orbiting) {
    orbit_angle += orbit_speed;
    x = orbit_center_x + lengthdir_x(orbit_radius, orbit_angle);
    y = orbit_center_y + lengthdir_y(orbit_radius, orbit_angle);
    
    orbit_duration--;
    if (orbit_duration <= 0) {
        // Fire out from orbit
        is_orbiting = false;
        direction = orbit_angle;
        speed = max_speed;
    }
}


// PINBALL MODE (Screen Edge Bouncing)

if (pinball_mode) {
    var bounced = false;
    
    // Check screen edges
    if (x <= 0 || x >= room_width) {
        hspeed *= -1;
        x = clamp(x, 1, room_width - 1);
        bounced = true;
    }
    if (y <= 0 || y >= room_height) {
        vspeed *= -1;
        y = clamp(y, 1, room_height - 1);
        bounced = true;
    }
    
    if (bounced) {
        screen_bounces++;
        damage *= (1 + screen_bounce_damage_bonus);
        
        // Visual effect
        var spark = instance_create_depth(x, y, depth - 1, obj_particle);
        spark.image_blend = c_yellow;
        spark.direction = random(360);
        spark.speed = random_range(2, 5);
    }
}


// VACUUM EFFECT

if (has_vacuum) {
    var vacuum_list = ds_list_create();
    collision_circle_list(x, y, vacuum_range, obj_enemy, false, true, vacuum_list, false);
    
    for (var i = 0; i < ds_list_size(vacuum_list); i++) {
        var enemy = vacuum_list[| i];
        if (!enemy.marked_for_death) {
            var pull_dir = point_direction(enemy.x, enemy.y, x, y);
			enemy.knockback.Apply(pull_dir, vacuum_strength);
        }
    }
    
    ds_list_destroy(vacuum_list);
}


// TRAIL CREATION

if (leaves_trail) {
    trail_timer++;
    if (trail_timer >= trail_interval) {
        trail_timer = 0;
        
        var trail = instance_create_depth(x, y, depth + 1, obj_projectile_trail);
        trail.trail_type = trail_type;
        trail.duration = trail_duration;
        trail.damage = trail_damage;
        trail.owner = owner;
        trail.element_type = element_type;
    }
}


// STANDARD PROJECTILE LOGIC

if (projectileType == PROJECTILE_TYPE.NORMAL) {
    // Life countdown
    if (life > 0) {
        life -= 1;
    } else {
        HandleProjectileDeath();
        exit;
    }
    
    // Apply physics
    if (gravity_strength != 0) {
        vspeed += gravity_strength;
    }
    
    if (friction_amount != 1.0) {
        speed *= friction_amount;
    }
    
    // Wall bouncing
    if (can_bounce && bounces_remaining > 0) {
        if (place_meeting(x + hspeed, y, obj_wall)) {
            hspeed *= -bounce_dampening;
            bounces_remaining--;
        }
        if (place_meeting(x, y + vspeed, obj_wall)) {
            vspeed *= -bounce_dampening;
            bounces_remaining--;
        }
    }
}


// ENEMY COLLISION

var enemy = instance_place(x, y, obj_enemy);
if (enemy != noone && !enemy.marked_for_death) {
    HandleEnemyHit(enemy);
}


// ROTATION AND VISUALS

if (rotation_speed != 0) {
    image_angle += rotation_speed;
}

if (pulse_scale) {
    var pulse = 1 + sin(time_alive * pulse_speed) * pulse_amount;
    image_xscale = img_xscale * pulse;
    image_yscale = img_xscale * pulse;
}

if (has_afterimage && afterimage_timer++ >= afterimage_interval) {
    afterimage_timer = 0;
    var after = instance_create_depth(x, y, depth + 1, obj_afterimage);
    after.sprite_index = sprite_index;
    after.image_angle = image_angle;
    after.image_xscale = image_xscale;
    after.image_yscale = image_yscale;
    after.image_alpha = 0.5;
}


if (has_fire_effect)
{
	scr_spawn_element_particles(
    self,
    spr_fire_particle,
    [c_red, c_orange, c_yellow],
    3,
    [1.5, 3],
    [0.5, 1],
    [15, 30]
);
}
if (has_ice_effect)
{
	scr_spawn_element_particles(
    self,
    spr_ice_particle,
    [c_red, c_orange, c_yellow],
    3,
    [1.5, 3],
    [0.5, 1],
    [15, 30]
);
}
if (has_poison_effect)
{
	scr_spawn_element_particles(
    self,
    spr_poison_particle,
    [make_color_rgb(100,255,100), make_color_rgb(180,255,150)],
    3,
    [1, 2],
    [0.2, 0.6],
    [20, 40]
);
}

if (has_lightning_effect)
{
	scr_spawn_element_particles(
    self,
    spr_lightning_particle,
    [c_red, c_orange, c_yellow],
    3,
    [1.5, 3],
    [0.5, 1],
    [15, 30]
);
}