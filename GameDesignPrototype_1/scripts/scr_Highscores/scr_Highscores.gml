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