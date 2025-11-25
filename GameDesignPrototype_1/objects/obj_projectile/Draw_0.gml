// DRAW EVENT - Better shadow for lob projectiles
draw_sprite_ext(sprite, img, x, y, image_xscale, image_yscale, direction, c_white, 1);

var shadowX, shadowY;

// DRAW EVENT - Use stored target values
if (projectileType == PROJECTILE_TYPE.LOB) {
    shadowX = lerp(xStart, targetX, lobStep);
    shadowY = lerp(yStart, targetY, lobStep); // or use groundShadowY for fixed ground
} else {
    shadowX = x;
    shadowY = y + 16;
}

draw_sprite_shadow(self, sprite, img, shadowX, shadowY, direction);



