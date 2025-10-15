// Configuration (set via creation code)
chest_type = ChestType.MINI;
interactable = true;
interact_range = 64;

// State machine
state = ChestState.IDLE;

// Visual
base_scale = 1.0;
current_scale = base_scale;
target_scale = base_scale;
pulse_scale = 1.0;
image_alpha = 1.0;

// Animation timers
activation_timer = 0;
activation_duration = 30; // Frames for slowdown
move_timer = 0;
burst_timer = 0;
closing_timer = 0;

// Movement
target_x = x;
target_y = y;

// Pushback
pushback_radius = 96;
pushback_force = 12;

// Rewards
chest_rewards = [];


// Transition variables (for smooth world-to-GUI movement)
transition_start_x = 0;
transition_start_y = 0;
transition_progress = 0;
glow_intensity = 0;

// Choice prompt
choice_prompt_active = false;

// Premium chest scaling
if (chest_type == ChestType.PREMIUM) {
    var scale_mult = 1.0 + (obj_game_manager.chests_opened * 0.05);
    base_scale = clamp(scale_mult, 1.0, 2.0);
    current_scale = base_scale;
    target_scale = base_scale;
}

/// @func ShowChoicePrompt
function ShowChoicePrompt() {
    choice_prompt_active = true;
    // You can create a simple GUI prompt or use a simpler system
    // For now, let's use keyboard: 1 = Open, 2 = Bomb
}

/// @func BeginOpening
function BeginOpening() {
    var cost = 0;
    var can_afford = true;
    
    // Check cost for premium chests
    if (chest_type == ChestType.PREMIUM) {
        cost = GetChestCost(obj_game_manager.chests_opened);
        can_afford = (obj_player.gold >= cost);
        
        if (!can_afford) {
            show_debug_message("Not enough gold! Need: " + string(cost));
            state = ChestState.IDLE;
            return;
        }
        
        obj_player.gold -= cost;
    }
    
    // Generate rewards
    chest_rewards = GenerateChestRewards(chest_type, obj_game_manager.chests_opened);
    stored_cost = cost;
    
    // Start activation sequence
    state = ChestState.ACTIVATING;
    activation_timer = 0;
}

/// @func ConvertToBomb
function ConvertToBomb() {
    // Generate rewards to calculate bomb damage
    var temp_rewards = GenerateChestRewards(chest_type, obj_game_manager.chests_opened);
    var bomb_damage = CalculateBombDamage(temp_rewards);
    
    // Create bomb
    var bomb = instance_create_depth(x, y, depth, obj_chest_bomb);
    bomb.sprite_index = sprite_index;
    bomb.damage = bomb_damage;
    
    show_debug_message("Chest converted to bomb! Damage: " + string(bomb_damage));
    
    // Destroy self
    instance_destroy();
}

function ShowRewardsPopup() {
    function on_reward_select(index, reward) {
        ApplyReward(obj_player, reward);
        obj_game_manager.chests_opened++;
        
        // Set flag for chest to close itself
        with (obj_chest) {
            if (state == ChestState.SHOWING_REWARDS) {
                state = ChestState.CLOSING;
                closing_timer = 0;
            }
        }
    }
    
    function on_skip(refund_amount) {
        obj_player.gold += refund_amount;
        show_debug_message("Skipped chest, received " + string(refund_amount) + " gold");
        obj_game_manager.chests_opened++;
        
        // Set flag for chest to close itself
        with (obj_chest) {
            if (state == ChestState.SHOWING_REWARDS) {
                state = ChestState.CLOSING;
                closing_timer = 0;
            }
        }
    }
    
    global.chest_popup = new ChestPopup(
        display_get_gui_width() / 2,
        display_get_gui_height() / 2,
        chest_rewards,
        stored_cost,
        on_reward_select,  // Correct callback - receives (index, reward)
        on_skip            // Correct callback - receives (refund_amount)
    );
}

opened = false;