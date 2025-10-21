// Script Created By DiiAboss AKA Dillon Abotossaway
function drawAlphaRectangle(_x, _y, _w, _h, _alpha, _color = c_black)
{
	draw_set_alpha(_alpha);
    draw_set_color(_color);
    draw_rectangle(_x, _y, _w, _h, false);
    draw_set_alpha(1);
}