/// @description
if (alarm[0] > 0) {
    image_xscale = lerp(image_xscale, 1.5, 0.1);
    image_yscale = image_xscale;
    image_angle += 10;
    
    //// Particle effects
    //if (alarm[0] % 3 == 0) {
        //var p = instance_create_depth(x + random_range(-5, 5), y + random_range(-5, 5), depth + 1, obj_particle);
        //p.image_blend = c_orange;
    //}
}