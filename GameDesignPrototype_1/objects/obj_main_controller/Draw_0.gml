/// @description
/// obj_menu_controller - Draw Event
var cx = room_width/2;
var cy = room_height/2;

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
draw_text_transformed_color(cx, logo_y, "TARLHS", 
    logo_scale * 2, logo_scale * 2, 0,
    c_red, c_orange, c_yellow, c_red, menu_alpha);
    
draw_set_font(fnt_default);
draw_text_color(cx, logo_y + 50, "DEMO v0.1", 
    c_gray, c_gray, c_white, c_white, menu_alpha * 0.7);

// Draw based on state
draw_set_alpha(menu_alpha);

switch(menu_state) {
    case MENU_STATE.MAIN:
        for (var i = 0; i < array_length(menu_options); i++) {
            var yy = cy + i * 60;
            var selected = (i == selected_option);
            
            if (selected) {
                // Highlight box
                draw_set_alpha(menu_alpha * 0.3);
                draw_rectangle_color(cx - 100, yy - 25, cx + 100, yy + 25,
                    c_yellow, c_orange, c_orange, c_yellow, false);
                draw_set_alpha(menu_alpha);
            }
            
            draw_set_font(selected ? fnt_large : fnt_default);
            var col = selected ? c_yellow : c_white;
            draw_text_color(cx, yy, menu_options[i], col, col, col, col, menu_alpha);
        }
        break;
        
    case MENU_STATE.CHARACTER_SELECT:
        draw_text(cx, cy - 100, "SELECT CHARACTER");
        
        for (var i = 0; i < array_length(class_options); i++) {
            var xx = cx + (i - 1) * 250;
            var yy = cy + 50;
            var selected = (i == selected_class);
            var scale = selected ? 1.2 : 1;
            
            // Character box
            draw_set_alpha(menu_alpha * (selected ? 0.8 : 0.4));
            draw_rectangle_color(xx - 100*scale, yy - 80*scale, 
                xx + 100*scale, yy + 80*scale,
                class_options[i].color, class_options[i].color,
                c_black, c_black, false);
            
            draw_set_alpha(menu_alpha);
            draw_set_font(fnt_large);
            draw_text(xx, yy - 20, class_options[i].name);
            
            draw_set_font(fnt_default);
            draw_text(xx, yy + 20, class_options[i].desc);
        }
        
        draw_set_font(fnt_default);
        draw_text(cx, cy + 200, "Press SPACE to Start - ESC to Back");
        break;
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);