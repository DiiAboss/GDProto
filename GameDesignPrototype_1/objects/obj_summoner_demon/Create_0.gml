/// @description Insert description here
// You can write your code in this editor
event_inherited();

spawner_timer = 300;
summon_timer = 60;

nextX = 0;
nextY = 0;


nextType =  0;

var dist = 64;

x_min = x - dist;
y_min = y + dist;
x_max = x + dist;
y_max = y + dist * 2;

spawn_rate_multiplier = 1.0;

depth = -y;