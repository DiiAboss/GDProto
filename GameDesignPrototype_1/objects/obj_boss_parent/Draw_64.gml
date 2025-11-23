/// @description obj_boss_parent - Draw Boss Health Bar

if (!healthbar_visible || healthbar_alpha <= 0) exit;

var gui_w = display_get_gui_width();
var bar_width = 400;
var bar_height = 20;
var bar_x = (gui_w - bar_width) / 2;
var bar_y = healthbar_y;

// Background
draw_set_alpha(healthbar_alpha * 0.8);
draw_set_color(c_black);
draw_rectangle(bar_x - 2, bar_y - 2, bar_x + bar_width + 2, bar_y + bar_height + 2, false);

// Red background
draw_set_alpha(healthbar_alpha);
draw_set_color(c_red);
draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);

// Health fill
var hp_percent = damage_sys.GetHealthPercent();
var fill_width = bar_width * hp_percent;

// Color based on health
var fill_color = c_lime;
if (hp_percent < 0.3) fill_color = c_red;
else if (hp_percent < 0.6) fill_color = c_yellow;

draw_set_color(fill_color);
draw_rectangle(bar_x, bar_y, bar_x + fill_width, bar_y + bar_height, false);

// Border
draw_set_color(c_white);
draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, true);

// Boss name
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_font(fnt_default);
draw_text(bar_x + bar_width / 2, bar_y - 4, boss_name);

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);