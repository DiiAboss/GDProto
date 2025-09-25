// Script Created By DiiAboss AKA Dillon Abotossaway
function draw_sprite_shadow(_self, _sprite, _img, _xPos, _yPos, _rot, _size = 1, _alpha = 0.5)
{
	var _x = _xPos;
	var _y = _yPos;
	var _xScale =  _size;
	var _yScale =  _size;
	
	draw_sprite_ext(_sprite, _img, _x, _y, _xScale, _yScale, _rot, c_black, _alpha);
}