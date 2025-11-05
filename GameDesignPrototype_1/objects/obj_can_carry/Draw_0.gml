

/// @description Draw object with shadow and hit effects

// Apply shake effect
var draw_x = x;
var draw_y = y;
if (shake > 0) {
    draw_x += random_range(-shake, shake);
    draw_y += random_range(-shake, shake);
}

/// @description Draw with custom shadow function

var _sprite = sprite_index;
var _img = image_index;
var _dir = image_angle;


// Draw shadow using your custom function
draw_sprite_shadow(self, _sprite, _img, shadowX, shadowY, _dir, shadow_scale, shadow_alpha);


// Draw the object with hit flash
if (hitFlashTimer > 0) {
    // Flash white when hit
    gpu_set_fog(true, c_white, 0, 1);
    draw_sprite_ext(
        sprite_index,
        image_index,
        draw_x,
        draw_y,
        image_xscale,
        image_yscale,
        image_angle,
        c_white,
        image_alpha
    );
    gpu_set_fog(false, c_white, 0, 1);
} else {
    // Normal draw
    draw_sprite_ext(
        sprite_index,
        image_index,
        draw_x,
        draw_y,
        image_xscale,
        image_yscale,
        image_angle,
        image_blend,
        image_alpha
    );
}

// Charge indicator (if being carried and charging)
if (is_being_carried && instance_exists(carrier) && carrier.is_charging) {
    var charge = carrier.charge_amount;
    var bar_width = 32;
    var bar_height = 4;
    var bar_x = x - bar_width / 2;
    var bar_y = y - sprite_height - 8;
    
    draw_set_color(c_black);
    draw_rectangle(bar_x - 1, bar_y - 1, bar_x + bar_width + 1, bar_y + bar_height + 1, false);
    
    var charge_color = charge > 0.7 ? c_red : (charge > 0.4 ? c_yellow : c_white);
    draw_set_color(charge_color);
    draw_rectangle(bar_x, bar_y, bar_x + (bar_width * charge), bar_y + bar_height, false);
    
    draw_set_color(c_white);
}

// Debug: Draw knockback velocity (optional)
/*
if (knockback.IsActive()) {
    draw_set_color(c_lime);
    draw_arrow(x, y, x + knockback.x_velocity * 5, y + knockback.y_velocity * 5, 10);
    draw_set_color(c_white);
}
*/