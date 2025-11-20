/// @function TextboxSystem()
/// @description Handles dialogue textboxes with typewriter effect
function TextboxSystem() constructor {
    
	
    // STATE
    active = false;
    message_queue = [];
    current_message = undefined;
    
    // TYPEWRITER
    text_progress = 0;
    typewriter_speed = 1; // Characters per frame
    typewriter_active = true;
    finished_typing = false;
    
    // DISPLAY
    speaker_name = "";
    full_text = "";
    visible_text = "";
    
    // POSITIONING (GUI coordinates)
    box_width = 0;
    box_height = 120;
    box_x = 0;
    box_y = 0;
    padding = 20;
    
    // COLORS
    bg_color = make_color_rgb(20, 20, 35);
    bg_alpha = 0.95;
    border_color = make_color_rgb(102, 102, 102);
    text_color = make_color_rgb(224, 224, 224);
    name_bg_color = make_color_rgb(58, 58, 90);
    name_text_color = make_color_rgb(255, 215, 0);
    
    // METHODS
    
    /// @function Show(_name, _text, _use_typewriter)
    /// @param {string} _name Speaker name
    /// @param {string} _text Message text
    /// @param {bool} _use_typewriter Enable typewriter effect (default: true)
    static Show = function(_name, _text, _use_typewriter = true) {
        speaker_name = _name;
        full_text = _text;
        visible_text = "";
        text_progress = 0;
        typewriter_active = _use_typewriter;
        finished_typing = !_use_typewriter;
        
        if (!typewriter_active) {
            visible_text = full_text;
        }
        
        active = true;
        
        // Pause game for dialogue
        if (instance_exists(obj_game_manager)) {
            obj_game_manager.pause_manager.Pause(PAUSE_REASON.DIALOGUE, 0);
        }
    }
    
    /// @function QueueMessage(_name, _text, _use_typewriter)
    /// @param {string} _name Speaker name
    /// @param {string} _text Message text
    /// @param {bool} _use_typewriter Enable typewriter (default: true)
    static QueueMessage = function(_name, _text, _use_typewriter = true) {
        array_push(message_queue, {
            name: _name,
            text: _text,
            use_typewriter: _use_typewriter
        });
        
        // If not currently active, show first message
        if (!active && array_length(message_queue) > 0) {
            var msg = array_shift(message_queue);
            Show(msg.name, msg.text, msg.use_typewriter);
        }
    }
    
    /// @function Close()
    static Close = function() {
        active = false;
        speaker_name = "";
        full_text = "";
        visible_text = "";
        text_progress = 0;
        finished_typing = false;
        
        // Resume game
        if (instance_exists(obj_game_manager)) {
            obj_game_manager.pause_manager.Resume(PAUSE_REASON.DIALOGUE);
        }
        
        // Check for queued messages
        if (array_length(message_queue) > 0) {
            var msg = array_shift(message_queue);
            Show(msg.name, msg.text, msg.use_typewriter);
        }
    }
    
    /// @function Update(_input)
    /// @param {struct} _input Input system reference
    static Update = function(_input) {
        if (!active) return;
        
        // Update typewriter
        if (typewriter_active && !finished_typing) {
            text_progress += typewriter_speed;
            var char_count = floor(text_progress);
            
            if (char_count >= string_length(full_text)) {
                visible_text = full_text;
                finished_typing = true;
            } else {
                visible_text = string_copy(full_text, 1, char_count);
            }
        }
        
        // Input handling
        var continue_pressed = _input.Action || 
                              _input.FirePress || 
                              keyboard_check_pressed(vk_enter);
        
        if (continue_pressed) {
            if (!finished_typing) {
                // Skip typewriter
                visible_text = full_text;
                finished_typing = true;
                text_progress = string_length(full_text);
            } else {
                // Close or advance to next message
                Close();
            }
        }
    }
    
    /// @function Draw(_gui_width, _gui_height)
	/// @param {real} _input player_input
    /// @param {real} _gui_width GUI width
    /// @param {real} _gui_height GUI height
    static Draw = function(_input, _gui_width, _gui_height) {
        if (!active) return;
        
        // Calculate positions
        box_width = _gui_width * 0.9;
        if (box_width > 900) box_width = 900;
        
        box_x = (_gui_width - box_width) / 2;
        box_y = _gui_height - box_height - 40;
        
        // Draw main textbox
        draw_set_alpha(bg_alpha);
        draw_set_color(bg_color);
        draw_rectangle(box_x, box_y, box_x + box_width, box_y + box_height, false);
        draw_set_alpha(1);
        
        // Border
        draw_set_color(border_color);
        draw_rectangle(box_x, box_y, box_x + box_width, box_y + box_height, true);
        draw_rectangle(box_x + 1, box_y + 1, box_x + box_width - 1, box_y + box_height - 1, true);
        
        // Speaker name label
        if (speaker_name != "") {
            var name_width = string_width(speaker_name) + 40;
            var name_height = 24;
            var name_x = box_x + 20;
            var name_y = box_y - 14;
            
            draw_set_color(name_bg_color);
            draw_rectangle(name_x, name_y, name_x + name_width, name_y + name_height, false);
            
            draw_set_color(border_color);
            draw_rectangle(name_x, name_y, name_x + name_width, name_y + name_height, true);
            
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_font(fnt_default);
            draw_set_color(name_text_color);
            draw_text(name_x + name_width/2, name_y + name_height/2, string_upper(speaker_name));
        }
        
        // Message text
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_font(fnt_default);
        draw_set_color(text_color);
        
        var text_x = box_x + padding;
        var text_y = box_y + padding;
        var text_width = box_width - (padding * 2);
        
        draw_text_ext(text_x, text_y, visible_text, -1, text_width);
        
        // Continue prompt (only when finished typing)
        if (finished_typing) {
            draw_set_halign(fa_right);
            draw_set_valign(fa_bottom);
            draw_set_color(make_color_rgb(170, 170, 170));
            
            var prompt_text = "Press to continue  ";
            var prompt_x = box_x + box_width - padding;
            var prompt_y = box_y + box_height - padding;
            
            // Pulsing alpha effect
            var pulse = 0.5 + (sin(current_time / 200) * 0.5);
            draw_set_alpha(pulse);
            
            draw_text(prompt_x, prompt_y, prompt_text);
            
            // Draw button prompts
            var button_x = prompt_x - 64;
            var button_y = prompt_y + 8;
            
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(68, 68, 68));
            
            // [SPACE] or (A) button
            var button_text = (_input.InputType == INPUT.KEYBOARD) ? "[SPACE]" : "(A)";
            var btn_w = string_width(button_text) + 20;
            var btn_h = 20;
            
            draw_rectangle(button_x, button_y, button_x + btn_w, button_y + btn_h, false);
            draw_set_color(border_color);
            draw_rectangle(button_x, button_y, button_x + btn_w, button_y + btn_h, true);
            
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(button_x + btn_w/2, button_y + btn_h/2, button_text);
        }
        
        // Reset draw state
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}