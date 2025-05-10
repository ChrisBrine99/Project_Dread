// Remove all item data from the game, and any data within a given item struct depending on its type. It will
// also handle removing any internal containers within the main item struct itself (Ex. combo data is stored
// within structs so they have to be removed as well as required).
var _structRef	= undefined;
var _length		= 0;
var _itemID		= ds_map_find_first(global.itemData);
while(!is_undefined(_itemID)){
	_structRef = global.itemData[? _itemID];
	with(_structRef){
		// Remove the containers for the input side of the item's combination data. This block of code is
		// skipped over should there not be an array named validCombo within the current struct.
		if (variable_struct_exists(_structRef, "validCombo") && is_array(validCombo)){
			_length = array_length(validCombo);
			for (var i = 0; i < _length; i++)
				delete validCombo[i];
		}
		
		// The same process as above occurs for the item's combination result data. This next block is also
		// skipped for the same reason as above, but for the comboResult array variable.
		if (variable_struct_exists(_structRef, "comboResult") && is_array(comboResult)){
			_length = array_length(comboResult);
			for (var i = 0; i < _length; i++)
				delete comboResult[i];
		}
	}
	
	_itemID = ds_map_find_next(global.itemData, _itemID);
	show_debug_message("Deleted item {0} (structRef: {1})", _itemID, _structRef);
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