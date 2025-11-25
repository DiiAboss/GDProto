/// obj_baseball_bat Step Event
event_inherited();

if (!instance_exists(owner)) {
    instance_destroy();
    exit;
}

// Update homerun timer
if (hit_homerun_timer > 0) {
    hit_homerun_timer--;
}

// HOMERUN CHECK - Only during swing, only for Baseball Player
if (swinging && is_baseball_player && homerun_chance > 0) {
    
    // Find enemies we're about to hit
    var potential_hit = instance_place(x, y, obj_enemy);
    
    if (potential_hit != noone && ds_list_find_index(hitList, potential_hit) == -1) {
        
        // Roll for homerun
        if (random(1) < homerun_chance) {
            // HOMERUN!
            ds_list_add(hitList, potential_hit);
            hit_homerun_timer = 90;
            
            // Calculate homerun damage and knockback
            var hr_damage = attack * homerun_damage_mult;
            var hr_knockback = knockbackForce * homerun_knockback_mult;
            
            // Deal damage
            potential_hit.damage_sys.TakeDamage(hr_damage, owner);
            
            // Massive knockback
            var kb_dir = point_direction(owner.x, owner.y, potential_hit.x, potential_hit.y);
            potential_hit.knockback.Apply(kb_dir, hr_knockback);
            
            // Visual feedback
            potential_hit.hitFlashTimer = 15;
            
            // "HOME RUN!" text
            var hr_text = instance_create_depth(potential_hit.x, potential_hit.y - 20, -9999, obj_floating_text);
            hr_text.text = "HOME RUN!";
            hr_text.color = c_yellow;
            hr_text.scale = 1.5;
            
            // Camera shake
            if (instance_exists(owner) && variable_instance_exists(owner, "camera")) {
                owner.camera.add_shake(10);
            }
            
            // Award style points
            AwardStylePoints("HOME RUN", 100, 1);
            
            // Increment combo
            if (instance_exists(owner)) {
                owner.combo_count++;
                owner.combo_display_timer = 120;
            }
            
            // Particles
            repeat(20) {
                var p = instance_create_depth(potential_hit.x, potential_hit.y, -9999, obj_particle);
                p.direction = kb_dir + random_range(-45, 45);
                p.speed = random_range(4, 10);
                p.image_blend = choose(c_yellow, c_white, c_orange);
            }
        }
    }
}