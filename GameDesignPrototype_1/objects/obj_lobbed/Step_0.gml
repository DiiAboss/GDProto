/// @description
lobStep = lobShot(self, 0.02, direction, xStart, yStart, targetDistance);//arcHeight, oval_height, oval_width);

if (lobStep >= 1)
{
	instance_create_depth(x,y,depth,obj_knockback);
	instance_destroy();
}

depth = -(bbox_bottom + 32 + (point_distance(x, y, x, yStart)));