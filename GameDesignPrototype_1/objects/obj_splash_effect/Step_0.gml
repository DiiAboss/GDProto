timer += game_speed_delta();

scale = lerp(0.1, 1.5, timer / lifetime);
alpha = lerp(1.0, 0, timer / lifetime);

// Spawn firework particles along the cone
if (timer < lifetime * 0.8) { // Only spawn during first 80% of lifetime
    particle_spawn_counter += game_speed_delta();
    
    if (particle_spawn_counter >= particle_spawn_rate) {
        particle_spawn_counter = 0;
        
        // Spawn 1-2 particles randomly in cone
        repeat(irandom_range(1, 2)) {
            SpawnConeFirework();
        }
    }
}

if (timer >= lifetime) {
    instance_destroy();
}

/// @func SpawnConeFirework()
function SpawnConeFirework() {
    var cone_half_angle = cone_angle / 2;
    
    // Random position within cone
    var random_angle = splash_direction + random_range(-cone_half_angle, cone_half_angle);
    var random_distance = random_range(splash_radius * 0.3, splash_radius * scale);
    
    var spawn_x = x + lengthdir_x(random_distance, random_angle);
    var spawn_y = y + lengthdir_y(random_distance, random_angle);
    
    // Create firework particle
    var particle = instance_create_depth(spawn_x, spawn_y, depth - 1, obj_firework_particle);
    if (instance_exists(particle)) {
        particle.particle_color = splash_color;
        particle.direction = random_angle + random_range(-30, 30); // Slight spread
        particle.speed = random_range(1, 3);
    }
}