/// @description Insert description here
// You can write your code in this editor
stages = 5;
amount = 2;

limit = (amount - 1) % 2 = 0 ? amount - 1 * 0.5 : amount * 0.5;

base_life = 40;
life = base_life;
speed = 2;
direction = point_direction(x, y, mouse_x, mouse_y);

