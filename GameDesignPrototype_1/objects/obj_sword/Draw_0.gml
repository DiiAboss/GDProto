// --- Draw Event ---
if (active) {
    sprite_index = swordSprite;
    
    // Draw with combo effect
    if (comboCount > 1) {
        // Add glow effect for combos
        gpu_set_blendmode(bm_add);
        draw_sprite_ext(swordSprite, 0, x, y, 1.1, 1.1, image_angle, 
                       make_color_rgb(255, 200, 100), 0.3 * (comboCount / 5));
        gpu_set_blendmode(bm_normal);
    }
    
    // Draw sword
    draw_self();
    
    // Draw motion trail during swing
    if (swinging) {
        var trailAlpha = 0.4 * swingProgress;
        var trailOffset = currentAngleOffset - (currentAngleOffset * swingProgress * 0.3);
        var trailX = owner.x + lengthdir_x(swordLength, owner.mouseDirection + trailOffset);
        var trailY = owner.y + lengthdir_y(swordLength, owner.mouseDirection + trailOffset);
        
        draw_sprite_ext(swordSprite, 0, trailX, trailY, 1, 1, 
                       owner.mouseDirection + trailOffset, c_white, trailAlpha);
    }
    
    // Show combo counter
    if (comboCount > 0 && comboTimer > 0) {
        draw_set_color(c_yellow);
        draw_set_halign(fa_center);
        draw_text(owner.x, owner.y - 40, "Combo x" + string(comboCount));
        draw_set_halign(fa_left);
        draw_set_color(c_white);
    }
}