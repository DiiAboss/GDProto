timer += game_speed_delta();

// Apply friction
speed *= friction_amount;

// Apply gravity (if any)
if (gravity_strength > 0) {
    vspeed += gravity_strength * game_speed_delta();
}

// Destroy when lifetime ends
if (timer >= lifetime) {
    instance_destroy();
}