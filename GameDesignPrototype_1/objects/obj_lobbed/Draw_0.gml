/// @description

draw_sprite_ext(sprite, img, x, y, image_xscale, image_yscale, direction + rot, c_white, 1);

if (lobbed)
{
	var shadowX = lerp(xStart, outlineX, lobStep);
	var shadowY = lerp(yStart, outlineY + 16, lobStep); // If shadowY should be constant, set it to outlineY or a fixed ground level
}
else
{
	var shadowX = x;
	var shadowY = y + 16;
}

draw_sprite_shadow(self, sprite, img, shadowX, shadowY, 0);