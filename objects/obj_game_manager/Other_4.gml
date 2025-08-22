with(CAMERA) { room_start_event(); }	// Ensures the viewport is enabled and visible.

// 
var _floorMaterials = layer_get_id("Tiles_Floor_Materials");
if (_floorMaterials != -1) { layer_set_visible(_floorMaterials, false); }

// 
with(PLAYER) { floorMaterials = layer_tilemap_get_id(_floorMaterials); }