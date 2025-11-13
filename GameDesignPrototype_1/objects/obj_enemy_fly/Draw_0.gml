/// @description Enemy Fly Draw
// Shadow
// Ground Y for shadow

if (!is_falling)
{
var _shadow_y = lerp(jumpStartY, jumpTargetY, jumpProgress);
var _arc = -4 * jumpHeight * (jumpProgress - 0.5) * (jumpProgress - 0.5) + jumpHeight;
var _shadow_scale = clamp(1 - (_arc / jumpHeight), 0.4, 1);


draw_set_alpha(0.4);
draw_ellipse_color(x - (8 * _shadow_scale), _shadow_y, x + (8 * _shadow_scale), _shadow_y + 2, c_black, c_black, false);
draw_set_alpha(1);

// Main sprite (draw only once)
if (!canBeHit) draw_set_color(c_red); else draw_set_color(c_white);
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, draw_get_color(), 1);
draw_set_color(c_white);
}