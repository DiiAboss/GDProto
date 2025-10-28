// ==========================================
// CREATE EVENT
// ==========================================

// Configuration
chest_type = choose(ChestType.MINI, ChestType.MINI, ChestType.MINI, ChestType.GOLD);
interactable = true;
interact_range = 32;

// State
state = ChestState.IDLE;

// Visual
base_scale = 1.0;
current_scale = base_scale;
target_scale = base_scale;
image_alpha = 1.0;
glow_intensity = 0;

// Rewards
chest_rewards = [];
stored_cost = 0;

// Premium chest scaling
if (chest_type == ChestType.PREMIUM) {
    var scale_mult = 1.0 + (obj_game_manager.chests_opened * 0.05);
    base_scale = clamp(scale_mult, 1.0, 2.0);
    current_scale = base_scale;
    target_scale = base_scale;
}

// ==========================================
// FUNCTIONS
// ==========================================

/// @func BeginOpening()
function BeginOpening() {
    var cost = 0;
    var can_afford = true;
    
    // Check cost for premium chests
    if (chest_type == ChestType.PREMIUM) {
        cost = GetChestCost(obj_game_manager.chests_opened);
        can_afford = (obj_player.gold >= cost);
        
        if (!can_afford) {
            show_debug_message("Not enough gold! Need: " + string(cost));
            return;
        }
        
        obj_player.gold -= cost;
    }
    
    // Generate rewards
    chest_rewards = GenerateChestRewards(chest_type, obj_game_manager.chests_opened);
    stored_cost = cost;
    
    // Tell game manager we're opening
    obj_game_manager.OnChestOpening(id);
    
    // Change state
    state = ChestState.OPENING;
    
    // Visual effects
    glow_intensity = 1;
    
    // Camera shake
    if (instance_exists(obj_player)) {
        obj_player.camera.add_shake(3);
    }
    
    // Pushback enemies
    PushbackEnemies(x, y, 96, 12);
    DestroyAllProjectiles();
}

/// @func ShowRewards()
function ShowRewards() {
    state = ChestState.SHOWING_REWARDS;
    
    // Create the popup
    function on_reward_select(index, reward) {
        ApplyReward(obj_player, reward);
        obj_game_manager.chests_opened++;
        
        // Tell the chest to close
        with (obj_chest) {
            if (state == ChestState.SHOWING_REWARDS) {
                CloseChest();
            }
        }
    }
    
    function on_skip(refund_amount) {
        obj_player.gold += refund_amount;
        obj_game_manager.chests_opened++;
        
        with (obj_chest) {
            if (state == ChestState.SHOWING_REWARDS) {
                CloseChest();
            }
        }
    }
    
    global.chest_popup = new ChestPopup(
        display_get_gui_width() / 2,
        display_get_gui_height() / 2,
        chest_rewards,
        stored_cost,
        on_reward_select,
        on_skip
    );
}

/// @func CloseChest()
function CloseChest() {
    state = ChestState.CLOSING;
    
    // Tell game manager we're closing
    obj_game_manager.OnChestClosing(id);
}

/// @func ConvertToBomb()
function ConvertToBomb() {
    var temp_rewards = GenerateChestRewards(chest_type, obj_game_manager.chests_opened);
    var bomb_damage = CalculateBombDamage(temp_rewards);
    
    var bomb = instance_create_depth(x, y, depth, obj_chest_bomb);
    bomb.sprite_index = sprite_index;
    bomb.damage = bomb_damage;
    
    instance_destroy();
}