/// @description Insert description here
// You can write your code in this editor
/// @desc Draw soul with glow

// Shadow
draw_set_alpha(0.3);
draw_set_color(c_black);
draw_circle(x, y, 6, false);
draw_set_alpha(1);

// Glow effect
draw_set_alpha(alpha * 0.3);
draw_set_color(c_aqua);
draw_circle(x, y - z, 16, false);

// Soul sprite
draw_set_alpha(alpha);
draw_sprite_ext(sprite_index, 0, x, y - z, image_xscale, image_yscale, current_time * 0.1, image_blend, alpha);

draw_set_alpha(1);
draw_set_color(c_white);