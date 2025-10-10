/// @description
camera = camera_create();
view_camera[0] = camera;

// Base settings
base_width = 640;
base_height = 360;
current_width = base_width;
current_height = base_height;
zoom_speed = 0.05;

// Shake
shake_amount = 0;
shake_decay = 0.95;

// Boss mode
boss_mode = false;
boss_zoom_multiplier = 1.5; // How much to zoom out

// Follow target
follow_target = obj_player;
follow_speed = 0.1;