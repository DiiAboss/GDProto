/// @description Float and check for pickup
if (!instance_exists(obj_player)) exit;
var player = obj_player;
var dist = point_distance(x, y, player.x, player.y);

// Float animation
float_timer += float_speed;
y = base_y + sin(float_timer) * float_height;

// Glow pulse
glow_timer += 0.1;
glow_pulse = 0.5 + sin(glow_timer) * 0.3;

// Check if player in range
if (dist <= pickup_range && can_pickup) {
    show_prompt = true;
    
    // Press E to pickup
    if (keyboard_check_pressed(ord("E"))) {
        if (weapon_data != undefined) {
            var slot = player.current_weapon_index;
            var old_weapon = player.weapons[slot];
            
            // Check if slot 2 is empty
            var other_slot = (slot == 0) ? 1 : 0;
            
            if (player.weapons[other_slot] == undefined) {
                // Slot 2 is empty - move current weapon there
                player.weapons[other_slot] = old_weapon;
                player.weapons[slot] = weapon_data;
            } else {
                // Slot 2 is full - drop current weapon as pickup
                if (old_weapon != undefined) {
                    SpawnWeaponPickup(player.x, player.y - 32, old_weapon);
                }
                // Equip new weapon in current slot
                player.weapons[slot] = weapon_data;
            }
            
            // Update current weapon reference
            player.weaponCurrent = weapon_data;
            
            // ========== NEW: UPDATE SYNERGY TAGS ==========
            UpdateWeaponTags(player, slot);
            // ==============================================
            
            // Handle melee weapon switching
            if (weapon_data.type == WeaponType.Melee) {
                if (instance_exists(player.melee_weapon)) {
                    instance_destroy(player.melee_weapon);
                }
                
                if (variable_struct_exists(weapon_data, "melee_object_type")) {
                    player.melee_weapon = instance_create_depth(player.x, player.y, player.depth - 1, weapon_data.melee_object_type);
                    player.melee_weapon.owner = player;
                    player.melee_weapon.weapon_id = weapon_data.id;
                }
            } else {
                // Switched to ranged - destroy melee weapon
                if (instance_exists(player.melee_weapon)) {
                    instance_destroy(player.melee_weapon);
                    player.melee_weapon = noone;
                }
            }
            
            // Visual feedback
            var popup = instance_create_depth(x, y - 40, -9999, obj_floating_text);
            popup.text = "PICKED UP: " + weapon_data.name;
            popup.color = c_yellow;
            popup.lifetime = 90;
            popup.rise_speed = 1.0;
            popup.scale = 1.0;
            
            // Particles
            repeat(10) {
                var p = instance_create_depth(x, y, depth - 1, obj_particle);
                p.direction = random(360);
                p.speed = random_range(2, 5);
                p.image_blend = c_yellow;
            }
            
            // Destroy this pickup
            instance_destroy();
        }
    }
} else {
    show_prompt = false;
}

depth = -y;