/// @description
// Apply squash/stretch to sprite

var dir_to_player = point_direction(x, y, obj_player.x, obj_player.y);

var spr_dir = dir_to_player > 270 || dir_to_player < 90 ? 1 : -1;


var draw_scale_x = image_xscale * squash_scale_x * spr_dir;
var draw_scale_y = image_yscale * squash_scale_y;

// Draw shadow
draw_sprite_shadow(self, spr_shadow, image_index, x, y, 0, 1, 0.2);

// Draw maggot with squash/stretch
draw_sprite_ext(
    sprite_index,
    image_index,
    x,
    y,
    draw_scale_x,
    draw_scale_y,
    image_angle,
    image_blend,
    image_alpha
);

// Hit flash
if (hitFlashTimer > 0) {
    gpu_set_fog(true, c_white, 0, 1);
    draw_sprite_ext(
        sprite_index,
        image_index,
        x,
        y,
        draw_scale_x,
        draw_scale_y,
        image_angle,
        c_white,
        0.7
    );
    gpu_set_fog(false, c_white, 0, 1);
}