/// @description Draw interaction prompt

if (alpha <= 0) exit;

// Calculate draw position with float offset
var draw_x = x;
var draw_y = y + display_offset_y;

// Get button prompt based on input type
var button_text = "[E]";
if (instance_exists(obj_player)) {
    var input = obj_player.input;
    button_text = (input.InputType == INPUT.KEYBOARD) ? "[E]" : "(A)";
}

// Draw prompt background
var text_width = string_width(prompt_text + " " + button_text) + 24;
var text_height = 28;
var bg_x1 = draw_x - text_width / 2;
var bg_y1 = draw_y - text_height / 2;
var bg_x2 = draw_x + text_width / 2;
var bg_y2 = draw_y + text_height / 2;

draw_set_alpha(alpha * 0.9);
draw_set_color(make_color_rgb(30, 30, 45));
draw_rectangle(bg_x1, bg_y1, bg_x2, bg_y2, false);

// Border
draw_set_alpha(alpha);
draw_set_color(prompt_color);
draw_rectangle(bg_x1, bg_y1, bg_x2, bg_y2, true);
draw_rectangle(bg_x1 + 1, bg_y1 + 1, bg_x2 - 1, bg_y2 - 1, true);

// Icon (if provided)
var text_start_x = draw_x;
if (sprite_exists(prompt_icon)) {
    var icon_x = bg_x1 + 10;
    var icon_y = draw_y;
    draw_sprite_ext(prompt_icon, 0, icon_x, icon_y, 0.5, 0.5, 0, c_white, alpha);
    text_start_x += 12;
}

// Text
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_default_1);
draw_set_color(c_white);
draw_text(text_start_x, draw_y, prompt_text);

// Button prompt
draw_set_color(prompt_color);
var button_x = text_start_x + string_width(prompt_text) / 2 + 8;
draw_text(button_x, draw_y, button_text);

// Reset draw settings
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);