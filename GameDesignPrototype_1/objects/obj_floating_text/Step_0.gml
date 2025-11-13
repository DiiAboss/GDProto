/// @description

// STEP EVENT


lifetime -= game_speed_delta();
y_offset += rise_speed * game_speed_delta();
alpha = lifetime / 60;

if (lifetime <= 0) {
    instance_destroy();
}