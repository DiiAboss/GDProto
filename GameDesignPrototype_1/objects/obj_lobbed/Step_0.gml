// Use the stored lob_direction instead of direction
if (!variable_instance_exists(id, "lob_direction")) {
    lob_direction = direction; // Fallback
}

lobStep = lobShot(self, 4, lob_direction, xStart, yStart, targetDistance);

if (lobStep >= 1) {
    // Create splash effect for Holy Water
    if (sprite_index == spr_holy_water || object_index == obj_holy_water) {
        CreateHolyWaterSplash(x, y, owner);
    }
    
    // Create knockback area
    instance_create_depth(x, y, depth, obj_knockback);
    
    instance_destroy();
}

depth = -(bbox_bottom + 32 + point_distance(x, y, x, yStart));

if (rot < 360)
{
	rot += 5;
}
else {
	rot = 0;
}