/// @description
/// @description Bomb Object - Draw Event

// Apply shake effect
var draw_x = x;
var draw_y = y;
if (shake > 0) {
    draw_x += random_range(-shake, shake);
    draw_y += random_range(-shake, shake);
}

// Draw shadow using custom function
var _sprite = sprite_index;
var _img = image_index;
var _dir = image_angle;
draw_sprite_shadow(self, _sprite, _img, shadowX, shadowY, _dir, shadow_scale, shadow_alpha);

// Draw the bomb with effects
var draw_scale_x = image_xscale * pulse_scale;
var draw_scale_y = image_yscale * pulse_scale;
var draw_alpha = image_alpha;
var draw_color = bomb_color;

// Flashing white overlay in critical phase
if (is_armed && flash_timer > 0.7) {
    draw_color = c_white;
    draw_alpha = flash_timer;
}

// Draw bomb
draw_sprite_ext(
    sprite_index,
    image_index,
    draw_x,
    draw_y,
    draw_scale_x,
    draw_scale_y,
    image_angle,
    draw_color,
    draw_alpha
);

// === TIMER DISPLAY (when armed) ===
if (is_armed && timer > 0) {
    var seconds_left = ceil(timer / 60);
    var timer_text = string(seconds_left);
    
    // Position above bomb
    var text_x = draw_x;
    var text_y = draw_y - sprite_height - 12;
    
    // Color based on urgency
    var text_color = c_white;
    if (timer <= timer_critical_threshold) {
        text_color = c_red;
    } else if (timer <= timer_warning_threshold) {
        text_color = c_orange;
    }
    
    // Draw with outline
    draw_set_font(-1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Outline
    draw_set_color(c_black);
    for (var dx = -1; dx <= 1; dx++) {
        for (var dy = -1; dy <= 1; dy++) {
            if (dx != 0 || dy != 0) {
                draw_text(text_x + dx, text_y + dy, timer_text);
            }
        }
    }
    
    // Main text
    draw_set_color(text_color);
    draw_text(text_x, text_y, timer_text);
    
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
	
	if (timer < timer_max * 0.5)
{
		var _percent = (1 - (timer / timer_max)) 
	draw_set_color(c_red);
	draw_set_alpha(0.1 * _percent);
	draw_circle(x, y, explosion_radius, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

}

// Charge indicator (if being carried and charging) - from parent
if (is_being_carried && instance_exists(carrier) && carrier.is_charging) {
    var charge = carrier.charge_amount;
    var bar_width = 32;
    var bar_height = 4;
    var bar_x = x - bar_width / 2;
    var bar_y = y - sprite_height - 24; // Move up to avoid timer text
    
    draw_set_color(c_black);
    draw_rectangle(bar_x - 1, bar_y - 1, bar_x + bar_width + 1, bar_y + bar_height + 1, false);
    
    var charge_color = charge > 0.7 ? c_red : (charge > 0.4 ? c_yellow : c_white);
    draw_set_color(charge_color);
    draw_rectangle(bar_x, bar_y, bar_x + (bar_width * charge), bar_y + bar_height, false);
    
    draw_set_color(c_white);
}

// Debug: Draw explosion radius (optional - comment out for production)
/*
if (is_armed) {
    draw_set_color(c_red);
    draw_set_alpha(0.2);
    draw_circle(x, y, explosion_radius, false);
    draw_set_alpha(1.0);
    draw_set_color(c_white);
}
*/