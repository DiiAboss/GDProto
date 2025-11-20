/// @description Context Prompt - Follows parent and shows interaction prompt
depth = -y-99;

// PARENT TRACKING
parent_object = noone; // Will be set when created
if (variable_instance_exists(id, "parent_id")) {
    parent_object = parent_id;
}

activation_break = false;

// POSITIONING
offset_x = 0;
offset_y = -32; // Float above parent
follow_parent = true;

// DETECTION
activation_radius = 48; // Distance player must be within
player_in_range = false;
can_interact = true;

// VISUAL SETTINGS
prompt_text = "Press [E]";
prompt_color = c_yellow;
prompt_icon = -1; // Optional sprite for icon
show_prompt = false;

// ANIMATION
float_timer = 0;
float_speed = 0.05;
float_amplitude = 4;
alpha = 0;
target_alpha = 0;
alpha_lerp_speed = 0.15;

// ACTION STRUCT
// This will be assigned by the parent object
action = {
    type: "none",
    callback: function() {}
};

// PROMPT DISPLAY OFFSET (for floating animation)
display_offset_y = 0;


/// @function ExecuteAction()
/// @description Execute the assigned action
ExecuteAction = function() {
    if (!instance_exists(parent_object)) {
        show_debug_message("Context: Parent destroyed, cannot execute action");
        instance_destroy();
        return;
    }
    
    // Get player reference
    var player = instance_exists(obj_player) ? obj_player : noone;
    
    switch(action.type) {
        case "dialogue":
            ExecuteDialogue();
            break;
            
        case "dialogue_chain":
            ExecuteDialogueChain();
            break;
            
        case "choice":
            ExecuteChoice();
            break;
            
        case "shop":
            ExecuteShop();
            break;
            
        case "pickup":
            ExecutePickup();
            break;
            
        case "chest":
            ExecuteChest();
            break;
            
        case "custom":
            if (variable_struct_exists(action, "callback")) {
                action.callback(player, parent_object);
            }
            break;
            
        default:
            show_debug_message("Context: Unknown action type - " + string(action.type));
            break;
    }
	obj_player.can_interact = 90;
}

/// @function ExecuteDialogue()
ExecuteDialogue = function() {
    if (!instance_exists(obj_main_controller)) return;
    
    var textbox = obj_main_controller.textbox_system;
    var speaker = variable_struct_exists(action, "speaker") ? action.speaker : "";
    var text = variable_struct_exists(action, "text") ? action.text : "";
    var typewriter = variable_struct_exists(action, "use_typewriter") ? action.use_typewriter : true;
    
    textbox.Show(speaker, text, typewriter);
}

/// @function ExecuteDialogueChain()
ExecuteDialogueChain = function() {
    if (!instance_exists(obj_main_controller)) return;
    
    var textbox = obj_main_controller.textbox_system;
    
    if (variable_struct_exists(action, "messages")) {
        var messages = action.messages;
        for (var i = 0; i < array_length(messages); i++) {
            var msg = messages[i];
            var speaker = variable_struct_exists(msg, "speaker") ? msg.speaker : "";
            var text = variable_struct_exists(msg, "text") ? msg.text : "";
            var typewriter = variable_struct_exists(msg, "use_typewriter") ? msg.use_typewriter : true;
            
            textbox.QueueMessage(speaker, text, typewriter);
        }
    }
    
    // TODO: If there's a choice after dialogue, handle it
    // This would require extending the textbox system to support callbacks after closing
}

/// @function ExecuteChoice()
ExecuteChoice = function() {
    // This would open a choice menu system
    // For now, show a debug message
    show_debug_message("Context: Choice interaction - not yet implemented");
    
    // Future: Create obj_choice_menu and pass action.options and action.callbacks
}

/// @function ExecuteShop()
ExecuteShop = function() {
    show_debug_message("Context: Shop interaction - not yet implemented");
    
    // Future: Open shop UI with action.shop_inventory
}

/// @function ExecutePickup()
ExecutePickup = function() {
    var item_id = variable_struct_exists(action, "item_id") ? action.item_id : "unknown";
    var amount = variable_struct_exists(action, "amount") ? action.amount : 1;
    
    show_debug_message("Context: Picked up " + string(amount) + "x " + item_id);
    
    // Add to player inventory (future implementation)
    // GiveItemToPlayer(item_id, amount);
    
    // Destroy parent object
    if (instance_exists(parent_object)) {
        instance_destroy(parent_object);
    }
}

/// @function ExecuteChest()
ExecuteChest = function() {
    // Check if already opened
    if (variable_instance_exists(parent_object, "opened") && parent_object.opened) {
        if (instance_exists(obj_main_controller)) {
            obj_main_controller.textbox_system.Show("", "Already opened.", false);
        }
        return;
    }
    
    // Mark as opened
    if (variable_instance_exists(parent_object, "opened")) {
        parent_object.opened = false;
    }
    
    // Give rewards
    if (variable_struct_exists(action, "contents")) {
        var contents = action.contents;
        // Process rewards (future: inventory system)
        show_debug_message("Context: Chest opened, received items");
    }
    
    // Play animation, sound, etc (future)
    // Disable further interaction
    can_interact = false;
}