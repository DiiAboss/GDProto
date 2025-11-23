/// @description Insert description here
// You can write your code in this editor

// Inherit the parent event
//event_inherited();

/// @description Draw lid with shadow during fall

// Draw shadow while falling
if (falling) {
    draw_sprite_ext(
        spr_shadow,
        0,
        fall_shadow_x,
        fall_shadow_y,
        1,
        1,
        0,
        c_white,
        0.5
    );
}

// Draw self
draw_self();