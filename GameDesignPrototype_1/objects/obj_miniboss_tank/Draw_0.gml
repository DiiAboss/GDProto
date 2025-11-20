/// @desc Miniboss Draw Event - Enhanced Visuals

// Calculate visual effects
var breathScale = baseScale + sin(breathTimer + breathOffset) * breathScaleAmount;
var wobbleAngle = sin(wobbleTimer + wobbleOffset) * wobbleAmount;

// Apply hit flash
var drawColor = image_blend;
if (hitFlashTimer > 0) {
    drawColor = c_white;
}

// Apply burning effect
if (is_burning) {
    drawColor = merge_color(drawColor, c_orange, 0.5);
}

// Charging effect - add pulsing glow
if (isCharging && chargeProgress > 0) {
    var glowAlpha = 0.3 + (sin(current_time * 0.01) * 0.2);
    var glowScale = chargeScale * 1.2;
    
    gpu_set_blendmode(bm_add);
	
	 draw_sprite_ext(
        spr_mini_boss_1,
        image_index,
        x,
        y,
        glowScale * breathScale,
        glowScale * breathScale,
        image_angle + wobbleAngle,
        c_red,
        glowAlpha * chargeProgress
    );
	
	
    draw_sprite_ext(
        currentSprite,
        image_index,
        x,
        y,
        glowScale * breathScale,
        glowScale * breathScale,
        image_angle + wobbleAngle,
        c_red,
        glowAlpha * chargeProgress
    );
    gpu_set_blendmode(bm_normal);
}

// Draw main sprite
draw_sprite_ext(
    currentSprite,
    image_index,
    x,
    y,
    chargeScale * breathScale,
    chargeScale * breathScale,
    image_angle + wobbleAngle,
    drawColor,
    image_alpha
);

// Draw health bar (miniboss only)
if (!marked_for_death && hp < maxHp) {
    var barWidth = 64;
    var barHeight = 6;
    var barX = x - barWidth / 2;
    var barY = y - size - 12;
    
    // Background
    draw_set_color(c_black);
    draw_rectangle(barX - 1, barY - 1, barX + barWidth + 1, barY + barHeight + 1, false);
    
    // Health fill
    var healthPercent = hp / maxHp;
    var fillWidth = barWidth * healthPercent;
    
    var healthColor = c_lime;
    if (healthPercent < 0.3) {
        healthColor = c_red;
    } else if (healthPercent < 0.6) {
        healthColor = c_yellow;
    }
    
    draw_set_color(healthColor);
    draw_rectangle(barX, barY, barX + fillWidth, barY + barHeight, false);
    
    // Border
    draw_set_color(c_white);
    draw_rectangle(barX, barY, barX + barWidth, barY + barHeight, true);
    
    draw_set_color(c_white);
}

// Draw attack telegraph
if (isCharging && attackTimer > 0 && attackTimer < attackWindupTime * 0.8) {
    var telegraphLength = 120;
    var telegraphAlpha = chargeProgress * 0.5;
    
    var endX = x + lengthdir_x(telegraphLength, myDir);
    var endY = y + lengthdir_y(telegraphLength, myDir);
    
    draw_set_alpha(telegraphAlpha);
    draw_set_color(c_red);
    draw_line_width(x, y, endX, endY, 2);
    
    // Draw target indicator
    draw_circle(endX, endY, 8 * chargeProgress, true);
    
    draw_set_alpha(1);
    draw_set_color(c_white);
}

