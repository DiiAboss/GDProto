/// @description
/// @desc Draw totem with effects

// Outer glow
draw_sprite_ext(sprite_index, 0, x, y, glow_scale, glow_scale, 0, totem_color, 0.4);

// Main totem
draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

// Inner bright core
var pulse = 0.5 + sin(glow_timer * 2) * 0.5;
draw_sprite_ext(sprite_index, 0, x, y, 0.6, 0.6, 0, totem_color, pulse);

// Totem name above (optional)
if (totem_data != undefined) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_font(fnt_default);
    draw_set_color(totem_color);
    draw_text(x, y - sprite_height - 8, totem_data.name);
    draw_set_color(c_white);
}