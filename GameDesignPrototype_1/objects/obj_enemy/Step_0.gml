// ==========================================
// ENEMY - STEP EVENT (MINIMAL)
// ==========================================
// Controller handles all logic now - this just ensures depth sorting

if (is_falling) {
    // Skip all collision/damage/AI while falling
    exit;
}
depth = -y;