/// @description Totem interaction and effects

if (!instance_exists(obj_player)) exit;

var player = obj_player;
var dist = point_distance(x, y, player.x, player.y);

// Check if player is in range and totem is not active
if (dist <= interaction_range && !active) {
    show_prompt = true;
    
    // Press E to purchase
    if (keyboard_check_pressed(ord("E"))) {
        var cost = totem_data.GetScaledCost(player.player_level);
        
        if (player.gold >= cost) {
            player.gold -= cost;
            active = true;
            can_interact = false;
            show_prompt = false;
            
            ApplyTotemEffect(totem_type);
            
            repeat(20) {
                var p = instance_create_depth(x, y-32, depth - 1, obj_particle);
                p.direction = random(360);
                p.speed = random_range(2, 6);
                p.image_blend = totem_data.color;
            }
        }
    }
} else {
    show_prompt = false;
}

// Glow effect when active
if (active) {
    glow_timer += 0.1;
    pulse_scale = 1.0 + sin(glow_timer) * 0.1;
}

// Chaos totem spawning - ONLY THIS INSTANCE
if (active && totem_type == TotemType.CHAOS) {
    chaos_spawn_timer--;
    
    if (chaos_spawn_timer <= 0) {
        var ball = instance_create_depth(x, y-32, 0, obj_rolling_ball);
        ball.myDir = irandom(359);
        chaos_spawn_timer = 180;
    }
}