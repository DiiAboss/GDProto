// Set drawing color to black
draw_set_color(c_black);
draw_set_alpha(1);

// Define play area boundaries
var playLeft = 280;
var playTop = 88;
var playRight = 1064; // 1088
var playBottom = 648;

// Make sure we cover beyond the room boundaries
var padding = 1000; // Extra coverage

// TOP BAR
draw_rectangle(-padding, -padding, room_width + padding, playTop, false);

// BOTTOM BAR
draw_rectangle(-padding, playBottom, room_width + padding, room_height + padding, false);

// LEFT BAR
draw_rectangle(-padding, playTop, playLeft, playBottom, false);

// RIGHT BAR
draw_rectangle(playRight, playTop, room_width + padding, playBottom, false);

// Reset color
draw_set_color(c_white);