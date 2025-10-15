/// @description
/// @desc Animate totem

glow_timer += pulse_speed * game_speed_delta();
glow_scale = 1.0 + sin(glow_timer) * 0.2;

// Particle effect
particle_timer = timer_tick(particle_timer);
if (particle_timer <= 0) {
    particle_timer = particle_interval;
    
    // Spawn visual particle
    // TODO: Add particle system when ready
}

depth = -y;