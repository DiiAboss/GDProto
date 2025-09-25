function returnToPool() {
    isActive = false;
    isMagnetized = false;
    age = 0;
    currentSpeed = 0;
    checkTimer = 0;
    
    // Move off screen
    x = -100;
    y = -100;
    
    // Add back to pool
    with (obj_exp_manager) {
        ds_queue_enqueue(expPool, other.id);
    }
}


