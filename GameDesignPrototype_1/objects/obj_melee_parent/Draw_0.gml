/// @description Melee Parent - Draw Event

if (active) {
    sprite_index = swordSprite;
    

    // Draw weapon
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
    
}