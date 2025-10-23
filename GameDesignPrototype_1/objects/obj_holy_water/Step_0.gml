/// @description
if (!variable_instance_exists(id, "lob_direction")) {
    lob_direction = direction;
}

lobStep = lobShot(self, 0.02, lob_direction, xStart, yStart, targetDistance);

if (lobStep >= 1) {
    // Get synergy data from projectile (or create empty)
    var tags = synergy_tags ?? new SynergyTags();
    var syns = active_synergies ?? [];
    
    // NEW: Synergy-aware explosion
    ApplyExplosionSynergies(x, y, owner, tags, syns, 15, 64);
    
    // Existing knockback
    instance_create_depth(x, y, depth, obj_knockback);
    
    instance_destroy();
}

depth = -(bbox_bottom + 32 + point_distance(x, y, x, yStart));