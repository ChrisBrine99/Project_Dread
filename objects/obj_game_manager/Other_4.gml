// Call the camera's room start evernt which sets up the viewport of the newly loaded room to match the camera's
// viewport properties while also enabling said viewport in the room.
with(CAMERA) { room_start_event(); }

// Get the room's collision object layer so its visibility can be set to false as it is kept true within the
// editor so collision bounds are known at all times.
var _layerCollision = layer_get_id("Collision");
if (_layerCollision != -1)
	layer_set_visible(_layerCollision, false);

// Much like the collision object layer, the floor materials tile layer will be set to invisible since it will
// remain visible in the editor so material tiles are known while editing the given area.
var _layerFloorMaterials = layer_get_id("Tiles_Floor_Materials");
if (_layerFloorMaterials != -1)
	layer_set_visible(_layerFloorMaterials, false);

// Finally, get the ID for the floor material tile layer if the room has one, and assign the ID so the player
// can utilize it to handle their step sound effect logiic when required.
with(PLAYER){
	floorMaterials = -1; // Always reset the value to -1 at first.
	if (_layerFloorMaterials != -1)
		floorMaterials = layer_tilemap_get_id(_layerFloorMaterials);
}