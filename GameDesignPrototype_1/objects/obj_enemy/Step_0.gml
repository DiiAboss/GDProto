// ==========================================
// ENEMY - STEP EVENT (MINIMAL)
// ==========================================
// Controller handles all logic now - this just ensures depth sorting
depth = -y;
if (is_falling) {
    // Skip all collision/damage/AI while falling
    exit;
}
