/// @function ScoreDisplayManager()
/// @description Manages visual display of score combos and events
function ScoreDisplayManager() constructor {
    
    // Display position
    display_x = display_get_gui_width() / 2;
    display_y = 150;//display_get_gui_height() - 150;
    
    // Active combo display
    active_combo = {
        event_stacks: {},
        events_order: [],
        total_base: 0,
        total_multiplied: 0,
        display_timer: 0,
        display_duration: 120,
        fade_duration: 30,
        state: "building",
        add_animation: 0,
        color: c_white
    };
    
    // Visual settings
    combo_scale = 1.0;
    combo_alpha = 1.0;
    bounce_effect = 0;
    
    // Score animation
    display_score = 0;
    score_actual = 0;
    score_flash = 0;
    
    // ==========================================
    // COMBO BUILDING
    // ==========================================
    
    /// @function AddComboEvent(_name, _points, _multiplier)
    static AddComboEvent = function(_name, _points, _multiplier = 1) {
        // Start new combo if needed
        if (active_combo.state == "adding" || active_combo.state == "idle") {
            StartNewCombo();
        }
        
        // Check if this event type already exists in the stack
        if (variable_struct_exists(active_combo.event_stacks, _name)) {
            // Stack it! Increment count and add points
            var stack = active_combo.event_stacks[$ _name];
            stack.count++;
            stack.total_points += _points * _multiplier;
            stack.last_multiplier = _multiplier;
            
            // Update animation for emphasis
            stack.scale = 1.3;
            stack.flash = 1.0;
        } else {
            // New event type - create stack
            var new_stack = {
                name: _name,
                base_points: _points,
                count: 1,
                total_points: _points * _multiplier,
                last_multiplier: _multiplier,
                scale: 1.5,
                alpha: 0,
                offset_y: -20,
                flash: 0
            };
            
            active_combo.event_stacks[$ _name] = new_stack;
            array_push(active_combo.events_order, _name);
        }
        
        // Recalculate totals
        RecalculateTotals();
        
        // Reset display timer
        active_combo.display_timer = active_combo.display_duration;
        active_combo.state = "building";
        
        // Juice!
        bounce_effect = 10;
    }
    
    /// @function RecalculateTotals()
    static RecalculateTotals = function() {
        active_combo.total_base = 0;
        active_combo.total_multiplied = 0;
        
        var keys = variable_struct_get_names(active_combo.event_stacks);
        for (var i = 0; i < array_length(keys); i++) {
            var stack = active_combo.event_stacks[$ keys[i]];
            active_combo.total_multiplied += stack.total_points;
            active_combo.total_base += stack.base_points * stack.count;
        }
    }
    
    /// @function StartNewCombo()
    static StartNewCombo = function() {
        active_combo.event_stacks = {};
        active_combo.events_order = [];
        active_combo.total_base = 0;
        active_combo.total_multiplied = 0;
        active_combo.display_timer = 0;
        active_combo.state = "building";
        active_combo.add_animation = 0;
        combo_scale = 1.0;
        combo_alpha = 1.0;
    }
    
    /// @function FinishCombo()
    static FinishCombo = function() {
        if (variable_struct_names_count(active_combo.event_stacks) > 0) {
            active_combo.state = "displaying";
        }
    }
    
    // ==========================================
    // UPDATE LOOP
    // ==========================================
    
   static Update = function(_delta) {
        // Update stack animations
        var keys = variable_struct_get_names(active_combo.event_stacks);
        for (var i = 0; i < array_length(keys); i++) {
            var stack = active_combo.event_stacks[$ keys[i]];
            stack.scale = lerp(stack.scale, 1.0, 0.2 * _delta);
            stack.alpha = lerp(stack.alpha, 1.0, 0.3 * _delta);
            stack.offset_y = lerp(stack.offset_y, 0, 0.25 * _delta);
            stack.flash = lerp(stack.flash, 0, 0.15 * _delta);
        }
        
        // Handle states with delta time
        switch (active_combo.state) {
            case "building":
                active_combo.display_timer -= _delta;
                if (active_combo.display_timer <= 0) {
                    FinishCombo();
                }
                break;
                
            case "displaying":
                active_combo.display_timer = active_combo.fade_duration;
                active_combo.state = "fading";
                break;
                
            case "fading":
                active_combo.display_timer -= _delta;
                combo_alpha = active_combo.display_timer / active_combo.fade_duration;
                combo_scale = 1.0 + (1.0 - combo_alpha) * 0.3;
                
                if (active_combo.display_timer <= 0) {
                    active_combo.state = "adding";
                    active_combo.add_animation = 1.0;
                    score_actual += active_combo.total_multiplied;
                    score_flash = 1.0;
                }
                break;
                
            case "adding":
                active_combo.add_animation -= 0.05 * _delta;
                if (active_combo.add_animation <= 0) {
                    StartNewCombo();
                    active_combo.state = "idle";
                }
                break;
        }
        
        display_score = lerp(display_score, score_actual, 0.15 * _delta);
        bounce_effect = lerp(bounce_effect, 0, 0.2 * _delta);
        score_flash = lerp(score_flash, 0, 0.1 * _delta);
    }
    
    // ==========================================
    // DRAWING
    // ==========================================
    
    /// @function Draw()
    static Draw = function() {
        if (combo_alpha > 0) {
            DrawCombo();
        }
        //DrawScoreTotal();
    }
    
    static DrawCombo = function() {
    if (array_length(active_combo.events_order) == 0) return;
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(combo_alpha);
    
    var y_base = display_y + bounce_effect;
    
    // Build display from stacks
    var display_parts = [];
    
    for (var i = 0; i < array_length(active_combo.events_order); i++) {
        var key = active_combo.events_order[i];
        var stack = active_combo.event_stacks[$ key];
        
        var text = stack.name;
        if (stack.count > 1) {
            text += " x" + string(stack.count);
        }
        
        array_push(display_parts, {
            text: text,
            points: stack.total_points,
            stack: stack
        });
    }
    
    // Calculate total width
    var total_width = 0;
    for (var i = 0; i < array_length(display_parts); i++) {
        total_width += string_width(display_parts[i].text) * 1.2;
        if (i < array_length(display_parts) - 1) {
            total_width += 40;
        }
    }
    
    // DRAW ONE BACKGROUND FOR ENTIRE COMBO
    draw_set_alpha(combo_alpha * 0.3);
    draw_set_color(c_black);
    draw_rectangle(
        display_x - total_width/2 - 100,  // Left edge with padding
        y_base - 15,                      // Top
        display_x + total_width/2,   // Right edge with padding
        y_base + 45,                      // Bottom
        false
    );
    draw_set_alpha(combo_alpha);
    
    var start_x = display_x - total_width / 2;
    var x_offset = 0;
    
    // Draw each part
    for (var i = 0; i < array_length(display_parts); i++) {
        var part = display_parts[i];
        var stack = part.stack;
        
        draw_set_alpha(combo_alpha * stack.alpha);
        
        // Color by count
        var col = c_white;
        if (stack.count >= 10) col = c_fuchsia;
        else if (stack.count >= 5) col = c_yellow;
        else if (stack.count >= 3) col = c_orange;
        else if (stack.count >= 2) col = c_lime;
        
        if (stack.flash > 0) {
            col = merge_color(col, c_white, stack.flash);
        }
        
        draw_set_color(col);
        draw_text_transformed(
            start_x + x_offset,
            y_base + stack.offset_y,
            part.text,
            combo_scale * stack.scale * 1.2,
            combo_scale * stack.scale * 1.2,
            0
        );
        
        // Points below
        draw_set_color(c_white);
        draw_set_alpha(combo_alpha * stack.alpha);
        draw_text_transformed(
            start_x + x_offset,
            y_base + 20 + stack.offset_y,
            string(part.points),
            combo_scale * stack.scale * 1,
            combo_scale * stack.scale * 1,
            0
        );
        
        x_offset += string_width(part.text) * 1.2;
        
        // "+" between
        if (i < array_length(display_parts) - 1) {
            draw_set_alpha(combo_alpha * 0.5);
            draw_set_color(c_gray);
            draw_text(start_x + x_offset + 20, y_base, "+");
            x_offset += 40;
        }
    }
    
    draw_set_alpha(1);
}
    
    static DrawScoreTotal = function() {
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        
        var flash_scale = 1.0 + score_flash * 0.3;
        var flash_color = merge_color(c_white, c_yellow, score_flash);
        draw_set_font(fnt_large); // Use your large font!
        // Main score
        draw_set_alpha(0.7);
        draw_set_color(c_gray);
        draw_text(display_x, 20, "SCORE");
        
        draw_set_alpha(1);
        draw_set_color(flash_color);
        draw_text_transformed(
            display_x, 40,
            string(floor(obj_game_manager.score_manager.GetScore())),
            flash_scale, flash_scale, 0
        );
        
        // Addition animation (moves upward to score)
        if (active_combo.state == "adding" && active_combo.add_animation > 0) {
            draw_set_alpha(active_combo.add_animation);
            draw_set_color(c_lime);
            var add_y = display_y + 50 + (1.0 - active_combo.add_animation) * -30;
            draw_text_transformed(
                display_x, add_y,
                "+" + string(active_combo.total_multiplied),
                1.2, 1.2, 0
            );
        }
        draw_set_font(fnt_default);
        draw_set_alpha(1);
    }
    
    /// @function DrawComboMeter()
    static DrawComboMeter = function() {

    }
}



/// @function AwardStylePoints(_name, _points, _mult)
function AwardStylePoints(_name, _points, _mult = 1) {
    if (instance_exists(obj_game_manager)) {
        obj_game_manager.score_display.AddComboEvent(_name, _points, _mult);
        obj_game_manager.score_manager.AddScore(_points * _mult);
    }
}