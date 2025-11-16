/// @description Baseball Bat - Step Event
event_inherited(); // Call parent step

if (!instance_exists(owner)) {
    instance_destroy();
    exit;
}

// Update sweet spot timer
if (hit_sweet_spot_timer > 0) {
    hit_sweet_spot_timer--;
} else {
    hit_sweet_spot = false;
}

// Calculate sweet spot position during swing
if (swinging) { // Use 'swinging' not 'isSwinging'
    
    // Calculate the current angle of the bat during swing
    var current_bat_angle = owner.mouseDirection + currentAngleOffset;
    
    // The sweet spot is at the tip of the bat during mid-swing
    // Interpolate between start and end position
    var swing_t = swingProgress; // 0 to 1
    
    // Calculate sweet spot position
    sweet_spot_x = owner.x + lengthdir_x(sweet_spot_distance, current_bat_angle);
    sweet_spot_y = owner.y + lengthdir_y(sweet_spot_distance, current_bat_angle);
    
    // Check if we're in the sweet spot timing window
    var sweet_spot_timing = (swingProgress >= sweet_spot_active_start && 
                             swingProgress <= sweet_spot_active_end);
    
    if (sweet_spot_timing) {
        // Check for enemies in sweet spot radius
        var sweet_spot_hit = collision_circle(sweet_spot_x, sweet_spot_y, 
                                               sweet_spot_radius, obj_enemy, false, true);
        
        if (sweet_spot_hit != noone && ds_list_find_index(hitList, sweet_spot_hit) == -1) {
            // HOME RUN!
            hit_sweet_spot = true;
            hit_sweet_spot_timer = 90;
            ds_list_add(hitList, sweet_spot_hit);
            
            // Increment combo
            if (comboTimer > 0) {
                comboCount++;
            } else {
                comboCount = 1;
            }
            
            // Deal massive damage
            var homerun_damage = attack * homerun_damage_mult * (1 + comboCount * 0.25);
            //takeDamage(sweet_spot_hit, homerun_damage, owner);
            sweet_spot_hit.damage_sys.TakeDamage(homerun_damage, owner);
            // Massive knockback
            var kb_dir = point_direction(owner.x, owner.y, sweet_spot_hit.x, sweet_spot_hit.y);
            var homerun_kb = (knockbackForce * homerun_knockback_mult) + (comboCount * 1);
            
            sweet_spot_hit.knockback.Apply(kb_dir, homerun_kb);
            // Visual feedback
            sweet_spot_hit.hitFlashTimer = 15;
            if (variable_instance_exists(sweet_spot_hit, "flash_color")) {
                sweet_spot_hit.flash_color = c_yellow;
            }
            
            
            // Spawn "HOME RUN!" text effect
            var homerun_text = instance_create_depth(sweet_spot_hit.x, sweet_spot_hit.y - 20, -999, obj_damage_number);
            if (instance_exists(homerun_text)) {
                homerun_text.damage_text = "HOME RUN!";
                homerun_text.text_color = c_yellow;
                homerun_text.is_crit = true;
            }
            
            // Trigger ON_HIT with homerun flag
            var hit_event = CreateHitEvent(owner, sweet_spot_hit, homerun_damage, AttackType.MELEE);
            hit_event.combo_hit = current_combo_hit;
            hit_event.is_homerun = true;
            
            TriggerModifiers(owner, MOD_TRIGGER.ON_HIT, hit_event);
            
            show_debug_message("HOME RUN! Damage: " + string(homerun_damage) + " Knockback: " + string(homerun_kb));
        }
        
        // Also check for carriable objects in sweet spot
        var sweet_spot_obj = collision_circle(sweet_spot_x, sweet_spot_y, 
                                               sweet_spot_radius, obj_can_carry, false, true);
        
        if (sweet_spot_obj != noone && !sweet_spot_obj.is_being_carried && 
            ds_list_find_index(hitList, sweet_spot_obj) == -1) {
            
            // HOME RUN ON OBJECT!
            ds_list_add(hitList, sweet_spot_obj);
            
            var kb_dir = point_direction(owner.x, owner.y, sweet_spot_obj.x, sweet_spot_obj.y);
            var resistance = variable_instance_exists(sweet_spot_obj, "hit_resistance") ? sweet_spot_obj.hit_resistance : 1.0;
            var homerun_kb = (knockbackForce * homerun_knockback_mult) / resistance;
            
            if (variable_instance_exists(sweet_spot_obj, "knockback")) {
                sweet_spot_obj.knockback.Apply(kb_dir, homerun_kb);
            }
            
            // Visual feedback
            if (variable_instance_exists(sweet_spot_obj, "hitFlashTimer")) {
                sweet_spot_obj.hitFlashTimer = 8;
            }
            if (variable_instance_exists(sweet_spot_obj, "shake")) {
                sweet_spot_obj.shake = 5;
            }
            
            // Particles
            repeat(10) {
                var p = instance_create_depth(sweet_spot_obj.x, sweet_spot_obj.y, sweet_spot_obj.depth - 1, obj_particle);
                p.direction = kb_dir + random_range(-30, 30);
                p.speed = random_range(4, 10);
                p.image_blend = c_yellow;
            }
            
            show_debug_message("HOME RUN on object! Force: " + string(homerun_kb));
        }
    }
}