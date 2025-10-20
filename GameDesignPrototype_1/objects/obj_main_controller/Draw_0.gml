/// @description
/// obj_menu_controller - Draw Event
var cx = room_width/2;
var cy = room_height/2;

if (room == rm_main_menu)
{
	// Background
draw_set_color(c_black);
draw_set_alpha(0.8);
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1);

// Logo
draw_set_halign(fa_center);
draw_set_valign(fa_center);
draw_set_font(fnt_large); // Create large font

var logo_y = cy - 200 + logo_bounce;
draw_text_transformed_color(cx, logo_y, "TARLHS GAME", 
    logo_scale * 2, logo_scale * 2, 0,
    c_red, c_orange, c_yellow, c_red, menu_alpha);
    
draw_set_font(fnt_default);
draw_text_color(cx, logo_y + 50, "DEMO v0.1", 
    c_gray, c_gray, c_white, c_white, menu_alpha * 0.7);

// Draw based on state
draw_set_alpha(menu_alpha);
	
	
}

