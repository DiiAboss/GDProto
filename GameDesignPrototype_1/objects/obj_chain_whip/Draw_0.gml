/// @description obj_chain_whip - DRAW EVENT

if (!instance_exists(owner)) exit;

// Calculate weapon tip position
var baseAngle = owner.mouseDirection;
var weaponAngle = baseAngle + currentAngleOffset;
var tipX = owner.x + lengthdir_x(current_range, weaponAngle);
var tipY = owner.y + lengthdir_y(current_range, weaponAngle);

// Draw chain links from owner to tip
var dist = point_distance(owner.x, owner.y, tipX, tipY);
var chain_dir = point_direction(owner.x, owner.y, tipX, tipY);
var num_links = max(1, floor(dist / chain_link_size));

for (var i = 0; i < num_links; i++) {
    var link_progress = i / num_links;
    
    // Base position
    var link_x = lerp(owner.x, tipX, link_progress);
    var link_y = lerp(owner.y, tipY, link_progress);
    
    // Undulation effect (only during swing)
    if (swinging) {
        var wave_offset = sin((current_time * chain_wave_speed) + (i * 0.5)) * chain_wave_amplitude;
        var perpendicular_angle = chain_dir + 90;
        
        link_x += lengthdir_x(wave_offset, perpendicular_angle);
        link_y += lengthdir_y(wave_offset, perpendicular_angle);
    }
    
    // Draw chain link
    draw_sprite_ext(
        chain_link_sprite,
        0,
        link_x,
        link_y,
        1,
        1,
        chain_dir,
        c_white,
        0.8
    );
}

// Draw knife head at tip
draw_sprite_ext(
    knife_sprite,
    0,
    tipX,
    tipY,
    1,
    1,
    weaponAngle,
    c_white,
    1.0
);