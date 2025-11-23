// Draw shadow during jump
if (state == TIPSY_STATE.JUMPING && jump_height > 0) {
    var shadow_alpha = 0.5 * (1 - jump_height / jump_target_height);
    draw_sprite_ext(
        spr_tipsy_shadow,
        0,
        shadow_x,
        shadow_y,
        shadow_scale,
        shadow_scale,
        0,
        c_white,
        shadow_alpha
    );
}

// Draw crash warning shadow during sky attack
if (show_crash_shadow) { // This should be TRUE when in SKY_ATTACK state
    var warning_color = shadow_locked ? c_red : c_yellow;
    var pulse = sin(current_time * 0.01) * 0.2 + 0.8;
    
    draw_sprite_ext(
        spr_tipsy_shadow,
        0,
        shadow_x,
        shadow_y,
        shadow_scale * pulse,
        shadow_scale * pulse,
        0,
        warning_color,
        0.6
    );
}

// Draw main body (elevated if jumping)
var draw_y = y - jump_height;

if (hitFlashTimer > 0) {
    gpu_set_blendmode(bm_add);
    draw_sprite(sprite_index, image_index, x + random_range(-shake, shake), draw_y + random_range(-shake, shake));
    gpu_set_blendmode(bm_normal);
}

draw_sprite(sprite_index, image_index, x, draw_y);

// Draw lid on top (if not removed)
if (draw_lid && !lid_is_open) {
    draw_sprite(lid_sprite, 0, x, draw_y);
}