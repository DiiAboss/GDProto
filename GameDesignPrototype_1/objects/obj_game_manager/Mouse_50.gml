/// @description

var tile_layer = "Tiles_2";
var tile_layer_id = layer_get_id(tile_layer);
var tilemap_id = layer_tilemap_get_id(tile_layer_id);
var tile_ahead = tilemap_get_at_pixel(tilemap_id, mouse_x, mouse_y);
show_debug_message(tile_ahead);