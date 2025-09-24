/// @description
// Flash when hit
if (hitFlashTimer > 0) {
    image_blend = c_red;
    draw_self();
} else {
    draw_self();
}
