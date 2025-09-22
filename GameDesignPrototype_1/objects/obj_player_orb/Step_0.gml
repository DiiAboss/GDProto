/// @description Insert description here
// You can write your code in this editor

if (owner != noone)
{
    var _centerX = owner.x;
    var _centerY = owner.y;
    var _radius  = radius;
    
    if ((currentRotation + mySpeed) < 360)
    {
        currentRotation += mySpeed;   
    }
    else {
        currentRotation = (currentRotation + mySpeed) - 360;
    }
    
    x = _centerX + lengthdir_x(_radius, currentRotation);
    y = _centerY + lengthdir_y(_radius, currentRotation);
    
}
else {
	instance_destroy();
}