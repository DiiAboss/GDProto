/// @description
/// @desc Draw totem shop menu

if (!show_menu) exit;

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

// Background overlay
draw_set_alpha(0.7);
draw_set_color(c_black);
draw_rectangle(0, 0, gui_w, gui_h, false);
draw_set_alpha(1);

// Menu panel
var panel_w = 500;
var panel_h = 400;
var panel_x = gui_w / 2 - panel_w / 2;
var panel_y = gui_h / 2 - panel_h / 2;

draw_set_color(c_dkgray);
draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);

draw_set_color(c_white);
draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, true);

// Title
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_font(fnt_large);
draw_set_color(c_yellow);
draw_text(gui_w / 2, panel_y + 20, "TOTEM SHOP");

// Totem list
draw_set_font(fnt_default);
var list_y = panel_y + 70;
var item_height = 60;

for (var i = 0; i < array_length(available_totems); i++) {
    var totem_type = available_totems[i];
    var totem_data = GetTotemByType(totem_type);
    
    if (totem_data == undefined) continue;
    
    var item_y = list_y + (i * item_height);
    var cost = totem_data.GetScaledCost(obj_player.player_level);
    var can_afford = (obj_player.gold >= cost);
    
    // Highlight selected
    if (i == selected_index) {
        draw_set_alpha(0.3);
        draw_set_color(c_yellow);
        draw_rectangle(panel_x + 10, item_y - 5, panel_x + panel_w - 10, item_y + item_height - 10, false);
        draw_set_alpha(1);
    }
    
    // Totem name
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    var name_color = totem_data.active ? c_green : (can_afford ? c_white : c_gray);
    draw_set_color(name_color);
    draw_text(panel_x + 20, item_y, totem_data.name);
    
    // Status
    if (totem_data.active) {
        draw_set_color(c_lime);
        draw_text(panel_x + 250, item_y, "[ACTIVE]");
    } else {
        // Cost
        draw_set_color(can_afford ? c_yellow : c_red);
        draw_text(panel_x + 250, item_y, string(cost) + " gold");
    }
    
    // Description
    draw_set_color(c_ltgray);
    draw_set_font(fnt_default);
    draw_text_ext(panel_x + 20, item_y + 20, totem_data.description, 14, panel_w - 40);
}

// Instructions
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(c_white);
draw_set_font(fnt_default);
draw_text(gui_w / 2, panel_y + panel_h - 20, "W/S: Navigate | Enter/Space: Purchase | ESC: Close");

// Player gold display
draw_set_halign(fa_right);
draw_set_valign(fa_top);
draw_set_color(c_yellow);
draw_text(panel_x + panel_w - 20, panel_y + 20, "Gold: " + string(obj_player.gold));