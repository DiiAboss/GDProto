if (!instance_exists(owner)) {
    instance_destroy();
    exit;
}
 // Calculate sword angle based on player's aim direction
    var baseAngle = owner.mouseDirection;
    image_angle = baseAngle + currentAngleOffset;
	x = owner.x;
	y = owner.y;
	depth = owner.depth - 1;

if (startSwing && !isSwinging) {
    isSwinging = true;
    swing_progress = 0;
    swing_direction = point_direction(owner.x, owner.y, mouse_x, mouse_y);
    ds_list_clear(hit_enemies);
    startSwing = false;
}

if (isSwinging) {
    swing_progress += swing_speed;
    
    // Optional dynamic tracking
    if (dynamic_tracking) {
        var target_dir = point_direction(owner.x, owner.y, mouse_x, mouse_y);
        var angle_diff = angle_difference(target_dir, swing_direction);
        swing_direction += angle_diff * 0.2;
    }
    
    // Position weapon
    var swing_offset = swing_arc * (swing_progress / 100 - 0.5);
    var current_angle = swing_direction + swing_offset;
    
    var dist = 32;
    x = owner.x + lengthdir_x(dist, current_angle);
    y = owner.y + lengthdir_y(dist, current_angle);
    image_angle = current_angle;
    
    // Regular hit detection (child objects like baseball bat override this)
    var hit_list = ds_list_create();
    var hit_count = instance_place_list(x, y, obj_enemy, hit_list, false);
    
    for (var i = 0; i < hit_count; i++) {
        var enemy = hit_list[| i];
        
        if (ds_list_find_index(hit_enemies, enemy) == -1) {
            ds_list_add(hit_enemies, enemy);
            
            takeDamage(enemy, attack);
            
            var kb_dir = point_direction(owner.x, owner.y, enemy.x, enemy.y);
            enemy.knockbackX = lengthdir_x(knockbackForce, kb_dir);
            enemy.knockbackY = lengthdir_y(knockbackForce, kb_dir);
            
            var hit_event = CreateHitEvent(owner, enemy, attack, AttackType.MELEE);
            hit_event.combo_hit = current_combo_hit;
            TriggerModifiers(owner, MOD_TRIGGER.ON_HIT, hit_event);
        }
    }
    
    ds_list_destroy(hit_list);
    
    if (swing_progress >= 100) {
        isSwinging = false;
        swing_progress = 0;
    }
}