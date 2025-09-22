/// @description Insert description here
// You can write your code in this editor

var nextX = x + lengthdir_x(mySpeed, myDir);
var nextY = y + lengthdir_y(mySpeed, myDir);

if place_meeting(nextX, nextY, obj_wall)
{
    myDir +=  point_direction(nextX, nextY, x, y) + irandom_range(-12, 12);
}
else {
    x = nextX;
    y = nextY;
}