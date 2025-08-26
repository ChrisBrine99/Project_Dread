// Call the camera's room start evernt which sets up the viewport of the newly loaded room to match the camera's
// viewport properties while also enabling said viewport in the room.
with(CAMERA) { room_start_event(); }

// Check for any dynamic items that may exist within the newly loaded room by looping through the keys stored
// within the global.dynamicItemKeys list. If any items are found they are created here.
var _key		= 0;
var _item		= -1;
var _roomIndex	= -1;
var _x			= 0;
var _y			= 0;
var _itemID		= "";
var _quantity	= 0;
var _durability	= 0;
var _worldItem	= noone;
var _length		= ds_list_size(global.dynamicItemKeys);
for (var i = 0; i < _length; i++){
	// Check if the data for the current dynamic item's key still exists. If not the key is removed from the
	// list so it won't be created again.
	_key	= global.dynamicItemKeys[| i];
	_item	= ds_map_find_value(global.worldItems, _key);
	if (is_undefined(_item)){
		ds_list_delete(global.dynamicItemKeys, i);
		_length--; // Decrement both values by one to compensate for removed element.
		i--;
		continue;
	}
	
	// Copy over the stored values about what this dynamic item is, and then check if the current room's index
	// matches the room this dynamic item should exist within. If they don't match, move onto the next element.
	with(_item){	
		_x			= xPos;
		_y			= yPos;
		_roomIndex	= roomIndex;
		_itemID		= itemID;
		_quantity	= quantity;
		_durability	= durability;
	}
	if (_roomIndex != room)
		continue;
		
	// Take the properties that were copied from the dynamic item's world data and use it to construct said
	// item as an object within the current room; storing its parameters like within the object's own room
	// start event/creation code.
	_worldItem = instance_create_object(_x, _y, obj_world_item);
	with(_worldItem){ 
		set_item_params(_key, _itemID, _quantity, _durability);
		flags = flags | WRLDITM_FLAG_DYNAMIC;
	}
}

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