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

// Check for player in range
var player = instance_nearest(x, y, obj_player);
if (player != noone && distance_to_object(player) < pickup_range) {
    show_prompt = true;
    
    if (keyboard_check_pressed(ord("E"))) {
        show_debug_message("=== PICKUP ATTEMPT ===");
        show_debug_message("Picking up: " + weapon_data.name);
        
        // FIRST: Try to find an empty slot
        var slot = -1;
        for (var i = 0; i < player.weapon_slots; i++) {
            show_debug_message("Checking slot " + string(i) + ": " + 
                (player.weapons[i] == noone ? "EMPTY" : "FULL"));
            
            if (player.weapons[i] == noone || player.weapons[i] == undefined) {
                slot = i;
                show_debug_message("Found empty slot: " + string(slot));
                break;
            }
        }
        
        // If no empty slot found, we need to replace something
        if (slot == -1) {
            show_debug_message("No empty slots - replacing current weapon");
            slot = player.current_weapon_index;
            
            // Drop the old weapon
            var old_weapon = player.weapons[slot];
            if (old_weapon != noone && old_weapon != undefined) {
                show_debug_message("Dropping: " + old_weapon.name);
                SpawnWeaponPickup(player.x, player.y - 32, old_weapon);
            }
        }
        
        // Place the new weapon in the slot
        show_debug_message("Placing " + weapon_data.name + " in slot " + string(slot));
        player.weapons[slot] = weapon_data;
        
        // Switch to the new weapon
        player.current_weapon_index = slot;
        player.weaponCurrent = weapon_data;
        
        // Update synergy tags
        UpdateWeaponTags(player, slot);
        
        // Handle melee weapon if needed
        if (weapon_data.type == WeaponType.Melee) {
            if (instance_exists(player.melee_weapon)) {
                instance_destroy(player.melee_weapon);
            }
            
            if (variable_struct_exists(weapon_data, "melee_object_type")) {
                player.melee_weapon = instance_create_depth(
                    player.x, player.y, player.depth - 1,
                    weapon_data.melee_object_type
                );
                player.melee_weapon.owner = player;
                player.melee_weapon.weapon_id = weapon_data.id;
            }
        } else {
            if (instance_exists(player.melee_weapon)) {
                instance_destroy(player.melee_weapon);
                player.melee_weapon = noone;
            }
        }
        
        // Visual feedback
        var popup = instance_create_depth(x, y - 40, -9999, obj_floating_text);
        popup.text = "PICKED UP: " + weapon_data.name + " [SLOT " + string(slot + 1) + "]";
        popup.color = c_yellow;
        
        // Debug final state
        show_debug_message("=== AFTER PICKUP ===");
        for (var i = 0; i < player.weapon_slots; i++) {
            show_debug_message("Slot " + string(i) + ": " + 
                (player.weapons[i] != noone ? player.weapons[i].name : "EMPTY"));
        }
        
        instance_destroy();
    }
} else {
    show_prompt = false;
}

depth = -y;