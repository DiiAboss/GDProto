draw_sprite_ext(sprite, img, x, y, image_xscale, image_yscale, direction, c_white, 1);

var shadowX = x;
var shadowY = y + 16;

if (projectileType == PROJECTILE_TYPE.LOB)
{
	var outlineX = xStart + oval_width * cos(radDirection);
	var outlineY = yStart - oval_height * sin(radDirection); // Note the minus sign to adjust for GameMaker's coordinate system
	var shadowX = lerp(xStart, outlineX, lobStep);
	var shadowY = lerp(yStart, outlineY + 16, lobStep); // If shadowY should be constant, set it to outlineY or a fixed ground level
}



draw_sprite_shadow(self, sprite, img, shadowX, shadowY, direction);