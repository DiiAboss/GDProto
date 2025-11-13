// Script Created By DiiAboss AKA Dillon Abotossaway
///@function   DrawHighscores(_w, _h)
///
///@description
///
///@param {array} _highscore_table
///@param {real} _w
///@param {real} _h

function DrawHighscores(_highscore_table, _w, _h) {
    // Position on the right side of the screen
    var table_x = _w - 250;
    var table_y = 100;
    var row_height = 32;
    
    // Draw background panel
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(table_x - 20, table_y - 40, table_x + 220, table_y + (row_height * 10) + 20, false);
    
    // Draw title
    draw_set_alpha(1);
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(table_x + 100, table_y - 30, "HIGH SCORES");
    
    // Draw column headers
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_text(table_x, table_y - 10, "RANK");
    draw_text(table_x + 60, table_y - 10, "SCORE");
    draw_text(table_x + 140, table_y - 10, "NAME");
    
    // Get highscores (top 10)
    var num_scores = min(10, array_length(_highscore_table));
    
    for (var i = 0; i < num_scores; i++) {
        var yy = table_y + 10 + (i * row_height);
        
        // Check if this is the last score added
        var is_latest = (i == global.last_highscore_index);
        
        // Draw arrow for latest score
        if (is_latest) {
            draw_set_color(c_lime);
            draw_text(table_x - 15, yy, ">");
        }
        
        // Set color based on rank
        if (i == 0) draw_set_color(c_yellow);      // 1st place
        else if (i == 1) draw_set_color(c_silver); // 2nd place
        else if (i == 2) draw_set_color(c_orange); // 3rd place
        else if (is_latest) draw_set_color(c_lime); // Latest score
        else draw_set_color(c_white);
        
        // Draw rank, score, and name
        draw_text(table_x + 10, yy, string(i + 1));
        draw_text(table_x + 60, yy, string(_highscore_table[i].score));
        draw_text(table_x + 140, yy, _highscore_table[i].name);
    }
    
    // Reset drawing settings
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}



/// @function AddHighscore(_score, _name)
function AddHighscore(_highscore_table, _score, _name) {
    // Create new score entry
    var new_entry = {score: _score, name: _name};
    
    // Add to table
    array_push(_highscore_table, new_entry);
    
    // Sort by score (highest first)
    array_sort(_highscore_table, function(a, b) {
        return b.score - a.score;
    });
    
    // Keep only top 10
    if (array_length(_highscore_table) > 10) {
        array_resize(_highscore_table, 10);
    }
    
    // Find the index of the score we just added
    global.last_highscore_index = -1;
    for (var i = 0; i < array_length(_highscore_table); i++) {
        if (_highscore_table[i].score == _score && _highscore_table[i].name == _name) {
            global.last_highscore_index = i;
            break;
        }
    }
}


/// @description Highscore System
function HighscoreSystem() constructor {
    
    highscore_table = [];
    max_highscores = 10;
    
    /// @function AddHighscore(_score, _name)
    static AddHighscore = function(_score, _name) {
        // Create new entry
        var new_entry = {
            score: _score,
            name: _name,
            date: date_current_datetime()
        };
        
        // Add to table
        array_push(highscore_table, new_entry);
        
        // Sort by score (descending)
        array_sort(highscore_table, function(a, b) {
            return b.score - a.score;
        });
        
        // Keep only top entries
        if (array_length(highscore_table) > max_highscores) {
            array_resize(highscore_table, max_highscores);
        }
        
        return GetScoreRank(_score);
    }
    
    /// @function GetScoreRank(_score)
    /// @returns {real} Rank (1-based), or -1 if not in top 10
    static GetScoreRank = function(_score) {
        for (var i = 0; i < array_length(highscore_table); i++) {
            if (highscore_table[i].score == _score) {
                return i + 1;
            }
        }
        return -1;
    }
    
    /// @function DrawHighscores(_w, _h)
    static DrawHighscores = function(_w, _h) {
        if (array_length(highscore_table) == 0) return;
        
        var table_x = _w - 220;
        var table_y = 80;
        var row_height = 30;
        
        // Background
        draw_set_alpha(0.8);
        draw_set_color(c_black);
        draw_rectangle(table_x - 10, table_y - 10, 
                      table_x + 200, table_y + (row_height * min(5, array_length(highscore_table))) + 20, false);
        draw_set_alpha(1);
        
        // Title
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_font(fnt_default);
        draw_set_color(c_yellow);
        draw_text(table_x + 95, table_y, "TOP SCORES");
        
        // Scores
        draw_set_halign(fa_left);
        var num_scores = min(5, array_length(highscore_table));
        
        for (var i = 0; i < num_scores; i++) {
            var yy = table_y + 25 + (i * row_height);
            
            // Rank color
            if (i == 0) draw_set_color(c_yellow);
            else if (i == 1) draw_set_color(c_silver);
            else if (i == 2) draw_set_color(c_orange);
            else draw_set_color(c_white);
            
            draw_text(table_x, yy, string(i + 1) + ".");
            draw_text(table_x + 30, yy, string(highscore_table[i].score));
        }
        
        draw_set_color(c_white);
    }
    
    /// @function DrawCompactHighscores(_w, _h, _highlight_index)
    static DrawCompactHighscores = function(_w, _h, _highlight_index = -1) {
        if (array_length(highscore_table) == 0) return;
        
        var table_x = _w - 200;
        var table_y = _h / 2 - 150;
        var row_height = 25;
        
        // Background
        draw_set_alpha(0.9);
        draw_set_color(c_black);
        draw_rectangle(table_x - 10, table_y - 30, table_x + 180, table_y + (row_height * 5) + 10, false);
        
        // Title
        draw_set_alpha(1);
        draw_set_color(c_yellow);
        draw_set_halign(fa_center);
        draw_text(table_x + 85, table_y - 20, "TOP SCORES");
        
        // Show top 5 scores
        draw_set_halign(fa_left);
        var num_scores = min(5, array_length(highscore_table));
        
        for (var i = 0; i < num_scores; i++) {
            var yy = table_y + (i * row_height);
            
            // Highlight new score
            if (i == _highlight_index) {
                var pulse = 0.3 + sin(current_time * 0.01) * 0.1;
                draw_set_alpha(pulse);
                draw_set_color(c_yellow);
                draw_rectangle(table_x - 5, yy - 2, table_x + 175, yy + row_height - 2, false);
                draw_set_alpha(1);
            }
            
            // Rank colors
            if (i == 0) draw_set_color(c_yellow);
            else if (i == 1) draw_set_color(c_silver);
            else if (i == 2) draw_set_color(c_orange);
            else if (i == _highlight_index) draw_set_color(c_lime);
            else draw_set_color(c_white);
            
            draw_text(table_x, yy, string(i + 1) + ".");
            draw_text(table_x + 30, yy, string(highscore_table[i].score));
            
            // Show "YOU!" for player's score
            if (i == _highlight_index) {
                draw_set_color(c_lime);
                draw_text(table_x + 120, yy, "YOU!");
            }
        }
        
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
    
    /// @function SaveHighscores()
    static SaveHighscores = function() {
        var json_string = json_stringify(highscore_table);
        
        var file = file_text_open_write("highscores.json");
        file_text_write_string(file, json_string);
        file_text_close(file);
    }
    
    /// @function LoadHighscores()
    static LoadHighscores = function() {
        if (!file_exists("highscores.json")) return;
        
        try {
            var file = file_text_open_read("highscores.json");
            var json_string = file_text_read_string(file);
            file_text_close(file);
            
            highscore_table = json_parse(json_string);
            
        } catch(error) {
            show_debug_message("ERROR loading highscores: " + string(error));
        }
    }
}