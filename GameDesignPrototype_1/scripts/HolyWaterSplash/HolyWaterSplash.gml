/// @function CreateHolyWaterSplash(_x, _y, _owner, _direction)
function CreateHolyWaterSplash(_x, _y, _owner, _direction) {
    var splash_radius = 64;
    var splash_damage = 15;
    var splash_duration = 180; // 3 seconds
    var cone_angle = 90; // 90 degree cone
    
    // Visual splash (directional)
    var splash = instance_create_depth(_x, _y, -9999, obj_splash_effect);
    if (instance_exists(splash)) {
        splash.splash_radius = splash_radius;
        splash.splash_color = c_aqua;
        splash.splash_direction = _direction; // NEW: directional
        splash.cone_angle = cone_angle;
    }
    
    // Damage enemies in CONE (not circle)
    with (obj_enemy) {
        var dist = point_distance(x, y, _x, _y);
        
        if (dist <= splash_radius && !marked_for_death) {
            // Check if enemy is within the cone angle
            var angle_to_enemy = point_direction(_x, _y, x, y);
            var angle_diff = angle_difference(angle_to_enemy, _direction);
            
            // Only damage if within cone
            if (abs(angle_diff) <= cone_angle / 2) {
                // Apply immediate splash damage
                if (variable_instance_exists(id, "damage_sys")) {
                    damage_sys.TakeDamage(splash_damage, _owner);
                } else {
                    takeDamage(id, splash_damage, _owner);
                }
                
                // Apply burning effect
                is_burning = true;
                burn_timer = splash_duration;
                burn_damage_per_tick = 2;
                burn_tick_counter = 0;
                image_blend = merge_color(image_blend, c_orange, 0.5);
                
                // CHAIN REACTION: Mark this enemy for potential firework
                holy_water_splash_direction = _direction; // Store splash direction
                killed_by_holy_water = false; // Will be set to true on death
            }
        }
    }
}





/// @function CreateFireworkEffect(_x, _y)
function CreateFireworkEffect(_x, _y) {
    // Create a ring burst of particles
    var particle_count = 12;
    
    for (var i = 0; i < particle_count; i++) {
        var particle_dir = (360 / particle_count) * i;
        var particle_speed = random_range(3, 6);
        
        var particle = instance_create_depth(_x, _y, -9999, obj_firework_particle);
        if (instance_exists(particle)) {
            particle.direction = particle_dir;
            particle.speed = particle_speed;
            particle.particle_color = choose(c_aqua, c_blue, c_white, c_ltgray);
            particle.lifetime = random_range(15, 25);
        }
    }
    
    // Add some upward-shooting sparkles
    repeat(8) {
        var particle = instance_create_depth(_x, _y, -9999, obj_firework_particle);
        if (instance_exists(particle)) {
            particle.direction = random_range(60, 120); // Upward arc
            particle.speed = random_range(4, 7);
            particle.particle_color = choose(c_yellow, c_white);
            particle.lifetime = random_range(20, 30);
            particle.gravity_strength = 0.15; // Falls back down
        }
    }
}