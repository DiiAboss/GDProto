/// obj_baseball_bat Step Event
event_inherited(); // Call parent step

if (!instance_exists(owner)) {
    instance_destroy();
    exit;
}

if (hit_sweet_spot_timer > 0)
{
	hit_sweet_spot_timer--;
}
else {
	hit_sweet_spot = false;
}

// Calculate sweet spot position during swing
if (isSwinging) {
	swing_direction = owner.mouseDirection;
    var sweet_spot_angle = swing_direction + (swing_arc * (swing_progress / 100 - 0.5));
    sweet_spot_x = owner.x + lengthdir_x(sweet_spot_distance, sweet_spot_angle);
    sweet_spot_y = owner.y + lengthdir_y(sweet_spot_distance, sweet_spot_angle);
    
    // Check if we're in the sweet spot timing window
    var sweet_spot_timing = (swing_progress >= sweet_spot_active_start * 100 && 
                             swing_progress <= sweet_spot_active_end * 100);
    
    if (sweet_spot_timing) {
        // Check for enemies in sweet spot radius
        var sweet_spot_hit = collision_circle(sweet_spot_x, sweet_spot_y, 
                                               sweet_spot_radius, obj_enemy, false, true);
        
        if (sweet_spot_hit != noone && ds_list_find_index(hit_enemies, sweet_spot_hit) == -1) {
            // HOME RUN!
            hit_sweet_spot = true;
			hit_sweet_spot_timer = 90;
            ds_list_add(hit_enemies, sweet_spot_hit);
            
            // Deal massive damage
            var homerun_damage = attack * homerun_damage_mult;
            takeDamage(sweet_spot_hit, homerun_damage);
            
            // Massive knockback
            var kb_dir = point_direction(owner.x, owner.y, sweet_spot_hit.x, sweet_spot_hit.y);
            sweet_spot_hit.knockbackX = lengthdir_x(knockbackForce * homerun_knockback_mult, kb_dir);
            sweet_spot_hit.knockbackY = lengthdir_y(knockbackForce * homerun_knockback_mult, kb_dir);
            
            // Visual/audio feedback
            // screen_shake(10);
            // audio_play_sound(snd_homerun, 1, false);
            
            // Spawn "HOME RUN!" text
   			//instance_create_depth(sweet_spot_hit.x, sweet_spot_hit.y - 20, depth - 10, obj_homerun_text);
            
            // Trigger ON_HIT with homerun flag
            var hit_event = CreateHitEvent(owner, sweet_spot_hit, homerun_damage, AttackType.MELEE);
            hit_event.combo_hit = current_combo_hit;
            hit_event.is_homerun = true;
            
            TriggerModifiers(owner, MOD_TRIGGER.ON_HIT, hit_event);
            
            // Flash effect
            sweet_spot_hit.flash_timer = 15;
            sweet_spot_hit.flash_color = c_yellow;
        }
    }
}