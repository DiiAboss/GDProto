
// DRAW EVENT (simplified)


// Draw chest with glow
if (glow_intensity > 0) {
    draw_sprite_ext(
        sprite_index, img, x, y,
        current_scale * 1.2, current_scale * 1.2, 0,
        c_white, glow_intensity * 0.5
    );
}

draw_sprite_ext(
    sprite_index, img, x, y,
    current_scale, current_scale, 0,
    c_white, image_alpha
);

// Interact prompt
if (state == ChestState.IDLE && instance_exists(obj_player)) {
    var dist = point_distance(x, y, obj_player.x, obj_player.y);
    if (dist <= interact_range) {
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        draw_set_font(fnt_default);
        draw_set_color(c_white);
        draw_text(x, y - sprite_height - 8, "Press E");
    }
}

// Choice prompt
if (state == ChestState.CHOICE_PROMPT) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_font(fnt_default);
    draw_set_color(c_yellow);
    draw_text(x, y - sprite_height - 20, "[1] Open Chest");
    draw_text(x, y - sprite_height - 5, "[2] Convert to Bomb");
}