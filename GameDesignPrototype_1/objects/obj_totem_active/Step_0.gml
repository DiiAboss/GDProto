/// @description Totem interaction and effects

if (!instance_exists(obj_player)) exit;

var player = obj_player;
var dist = point_distance(x, y, player.x, player.y);

// Check if player is in range and totem is not active
if (dist <= interaction_range && !totem_data.active) {
    show_prompt = true;
    
    // Press E to purchase
    if (keyboard_check_pressed(ord("E"))) {
        var cost = totem_data.GetScaledCost(player.player_level);
        
        if (player.gold >= cost) {
            // Purchase successful
            player.gold -= cost;
            totem_data.active = true;
            totem_data.activation_time = current_time;
            can_interact = false;
            show_prompt = false;
            
            // Apply effect
            ApplyTotemEffect(totem_type);
            
            // Visual feedback
            repeat(20) {
                var p = instance_create_depth(x, y, depth - 1, obj_particle);
                p.direction = random(360);
                p.speed = random_range(2, 6);
                p.image_blend = totem_data.color;
            }
            
            show_debug_message("Purchased: " + totem_data.name);
        } else {
            show_debug_message("Not enough gold!");
        }
    }
} else {
    show_prompt = false;
}

// Glow effect when active
if (totem_data.active) {
    glow_timer += 0.1;
    pulse_scale = 1.0 + sin(glow_timer) * 0.1;
}

// Chaos totem spawning
if (totem_data.active && totem_type == TotemType.CHAOS) {
    if (!variable_instance_exists(self, "chaos_spawn_timer")) {
        chaos_spawn_timer = 180; // 3 seconds
    }
    
    chaos_spawn_timer--;
    
    if (chaos_spawn_timer <= 0) {
        // Spawn ball at totem location
        var ball = instance_create_depth(x, y, 0, obj_rolling_ball);
        ball.myDir = irandom(359);
        
        chaos_spawn_timer = 180; // Reset
        show_debug_message("Chaos ball spawned!");
    }
}