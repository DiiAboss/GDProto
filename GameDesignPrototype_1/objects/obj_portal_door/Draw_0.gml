/// @description Insert description here
// You can write your code in this editor
var dist = point_distance(x, y, obj_player.x, obj_player.y);
if (dist < 64) {
    // Show prompt
    var prompt = is_unlocked ? unlock_text : locked_text;
    
   draw_text(x, y-48, prompt);
}

draw_self();