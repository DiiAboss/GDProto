/// @description Insert description here
// You can write your code in this editor
/// @description Pan camera back to player after intro

if (instance_exists(obj_player)) {
    obj_player.camera.unlock();
}