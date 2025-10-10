/// @description
// obj_camera_controller Step Event
if (instance_exists(follow_target)) {
    var target_x = follow_target.x;
    var target_y = follow_target.y;
    
    // Smooth follow
    var current_x = camera_get_view_x(camera) + current_width/2;
    var current_y = camera_get_view_y(camera) + current_height/2;
    
    var new_x = lerp(current_x, target_x, follow_speed);
    var new_y = lerp(current_y, target_y, follow_speed);
    
    // Boss mode zoom
    var target_width = boss_mode ? base_width * boss_zoom_multiplier : base_width;
    var target_height = boss_mode ? base_height * boss_zoom_multiplier : base_height;
    
    current_width = lerp(current_width, target_width, zoom_speed);
    current_height = lerp(current_height, target_height, zoom_speed);
    
    // Apply shake
    if (shake_amount > 0) {
        new_x += random_range(-shake_amount, shake_amount);
        new_y += random_range(-shake_amount, shake_amount);
        shake_amount *= shake_decay;
    }
    
    // Set camera
    camera_set_view_pos(camera, new_x - current_width/2, new_y - current_height/2);
    camera_set_view_size(camera, current_width, current_height);
}