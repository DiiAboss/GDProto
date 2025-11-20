/// @function CreateContextPrompt(_parent, _action, _prompt_text, _radius)
/// @param {Id.Instance} _parent Parent object to attach to
/// @param {struct} _action Action struct defining behavior
/// @param {string} _prompt_text Text to display (optional)
/// @param {real} _radius Activation radius (optional)
/// @return {Id.Instance} The created context prompt
function CreateContextPrompt(_parent, _action, _prompt_text = "Press [E]", _radius = 48) {
    if (!instance_exists(_parent)) {
        show_debug_message("CreateContextPrompt: Parent doesn't exist!");
        return noone;
    }
    
    // Create prompt at parent's position
    var prompt = instance_create_layer(_parent.x, _parent.y, "Effects", obj_context_prompt);
    
    // Setup
    prompt.parent_object = _parent;
    prompt.action = _action;
    prompt.prompt_text = _prompt_text;
    prompt.activation_radius = _radius;
    
    return prompt;
}

/// @function CreateDialogueAction(_speaker, _text, _use_typewriter)
/// @param {string} _speaker Speaker name
/// @param {string} _text Dialogue text
/// @param {bool} _use_typewriter Use typewriter effect (default true)
/// @return {struct} Action struct
function CreateDialogueAction(_speaker, _text, _use_typewriter = true) {
    return {
        type: "dialogue",
        speaker: _speaker,
        text: _text,
        use_typewriter: _use_typewriter
    };
}

/// @function CreateDialogueChainAction(_messages)
/// @param {array} _messages Array of message structs [{speaker, text}, ...]
/// @return {struct} Action struct
function CreateDialogueChainAction(_messages) {
    return {
        type: "dialogue_chain",
        messages: _messages
    };
}

/// @function CreateChoiceAction(_prompt, _options, _callbacks)
/// @param {string} _prompt Question/prompt text
/// @param {array} _options Array of choice strings
/// @param {array} _callbacks Array of functions to call for each choice
/// @return {struct} Action struct
function CreateChoiceAction(_prompt, _options, _callbacks) {
    return {
        type: "choice",
        prompt: _prompt,
        options: _options,
        callbacks: _callbacks
    };
}

/// @function CreatePickupAction(_item_id, _amount)
/// @param {string} _item_id Item identifier
/// @param {real} _amount Quantity
/// @return {struct} Action struct
function CreatePickupAction(_item_id, _amount = 1) {
    return {
        type: "pickup",
        item_id: _item_id,
        amount: _amount
    };
}

/// @function CreateChestAction(_contents)
/// @param {array} _contents Array of items in chest
/// @return {struct} Action struct
function CreateChestAction(_contents) {
    return {
        type: "chest",
        contents: _contents
    };
}

/// @function CreateCustomAction(_callback)
/// @param {function} _callback Function to execute (receives player, parent)
/// @return {struct} Action struct
function CreateCustomAction(_callback) {
    return {
        type: "custom",
        callback: _callback
    };
}