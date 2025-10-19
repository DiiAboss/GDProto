/// @description obj_chain_knife  
/// DRAW EVENT

// Draw chain links from owner to knife
if (instance_exists(owner)) {
    var dist = point_distance(owner.x, owner.y, x, y);
    var chain_dir = point_direction(owner.x, owner.y, x, y);
    var num_links = max(1, floor(dist / chain_link_size));
    
    for (var i = 0; i < num_links; i++) {
        var link_progress = i / num_links;
        
        // Position along chain
        var link_x = lerp(owner.x, x, link_progress);
        var link_y = lerp(owner.y, y, link_progress);
        
        // Draw link
        draw_sprite_ext(
            chain_link_sprite,
            0,
            link_x,
            link_y,
            1,
            1,
            chain_dir,
            c_white,
            0.7
        );
    }
}

// Draw knife
draw_sprite_ext(
    sprite_index,
    image_index,
    x,
    y,
    image_xscale,
    image_yscale,
    chain_dir,
    is_returning ? c_aqua : c_white,
    image_alpha
);