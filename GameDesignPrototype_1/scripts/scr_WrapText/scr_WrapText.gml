/// @function WrapText(_text, _max_width, _font)
/// @description Wraps text to fit within a specified width
/// @returns {array} Array of text lines
function WrapText(_text, _max_width, _font) {
    draw_set_font(_font);
    
    var words = string_split(_text, " ");
    var lines = [];
    var current_line = "";
    
    for (var i = 0; i < array_length(words); i++) {
        var test_line = current_line == "" ? words[i] : current_line + " " + words[i];
        var test_width = string_width(test_line);
        
        if (test_width > _max_width && current_line != "") {
            // Line is too long, save current line and start new one
            array_push(lines, current_line);
            current_line = words[i];
        } else {
            current_line = test_line;
        }
    }
    
    // Add the last line
    if (current_line != "") {
        array_push(lines, current_line);
    }
    
    return lines;
}