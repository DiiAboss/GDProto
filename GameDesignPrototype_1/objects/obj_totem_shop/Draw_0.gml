/// @description
/// @desc Draw totem shop

// Draw shop sprite with glow
draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);

// Glow effect
draw_sprite_ext(sprite_index, 0, x, y, 1.2, 1.2, 0, c_purple, glow_alpha * 0.5);

// Interact prompt
if (!show_menu && instance_exists(obj_player)) {
    var dist = point_distance(x, y, obj_player.x, obj_player.y);
    if (dist <= interact_range) {
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(fnt_default);
        draw_set_color(c_white);
        draw_text(x, y - sprite_height - 16, "Press E - Totem Shop");
    }
}