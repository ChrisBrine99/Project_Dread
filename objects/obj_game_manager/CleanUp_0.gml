// Remove all item data from the game, and any data within a given item struct depending on its type.
var _structRef	= undefined;
var _length		= ds_map_size(global.itemData);
var _itemID		= ds_map_find_first(global.itemData);
while(!is_undefined(_itemID)){
	_structRef = global.itemData[? _itemID];
	
	delete _structRef;
}
ds_map_clear(global.itemData);
ds_map_destroy(global.itemData);

// Remove all existing struct instances from memory by deleting their references stores within the global struct
// management list. Then, that list itself is destroyed to clear it from memory as well.
_structRef	= undefined;
_length		= ds_list_size(global.structs);
for (var i = 0; i < _length; i++){
	_structRef = global.structs[| i];
	_structRef.destroy_event();
	delete _structRef;
}
ds_list_clear(global.structs);
ds_list_destroy(global.structs);

// Go through all singleton instances that require their destroy event in order to free any memory they've
// allocated through the application's runtime. Then, the sInstance management map is destroyed.
with(CAMERA)		{ destroy_event(); }	delete CAMERA;
ds_map_destroy(global.sInstances);

// Finally, delete any structs that exist on the game manager for various aspects of the game that need managing.
delete global.settings;