// Go through all singleton instances that require their destroy event in order to free any memory they've
// allocated through the application's runtime. Then, the sInstance management map is destroyed.
with(CAMERA)				{ destroy_event(); }	delete CAMERA;
with(TEXTBOX)				{ destroy_event(); }	delete TEXTBOX;
with(TEXTBOX_LOG)			{ destroy_event(); }	delete TEXTBOX_LOG;
with(CONTROL_UI_MANAGER)	{ destroy_event(); }	delete CONTROL_UI_MANAGER;
													delete SCREEN_FADE;
ds_map_destroy(global.sInstances);

var _length = 0; // Used by all array/data structure-based cleanup code, so it's initialized at the start.

// Freeing any surfaces that might exist currently.
if (surface_exists(global.worldSurface))	{ surface_free(global.worldSurface); }
if (surface_exists(global.lightSurface))	{ surface_free(global.lightSurface); }
if (surface_exists(global.shadowSurface))	{ surface_free(global.shadowSurface); }

// Removes all item inventory structs as they aren't the standard structs that are automatically maintained by
// the global.struct data structure. In very rare cases, the item inventory will not have been initialized 
// before this event executes. In that case, this entire chunk of code is skipped since no cleanup is needed.
if (is_array(global.curItems)){
	_length = array_length(global.curItems);
	for (var i = 0; i < _length; i++){
		if (is_struct(global.curItems[i]))
			delete global.curItems[i];
	}
	array_resize(global.curItems, 0);
}

// Since the item references are also stored in an array based on their given ID values, the array is resized
// to zero so all those references are removed before they are cleaned up below.
array_resize(global.itemIDs, 0);

// Remove all item data from the game, and any data within a given item struct depending on its type. It will
// also handle removing any internal containers within the main item struct itself (Ex. combo data is stored
// within structs so they have to be removed as well as required).
var _structRef	= undefined;
var _itemName	= ds_map_find_first(global.itemData);
while(!is_undefined(_itemName)){
	_structRef = global.itemData[? _itemName];
	show_debug_message("Deleted item {0} (structRef: {1})", _itemName, _structRef);
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
	
	global.itemData[? _itemName] = undefined; // Remove reference to the struct within the map.
	_itemName					 = ds_map_find_next(global.itemData, _itemName);
	delete _structRef;
}
ds_map_clear(global.itemData);
ds_map_destroy(global.itemData);

// Loop through all world item structs that may currently exist. Then, clear and destroy the data structure
// that was managing all those world items.
var _key = ds_map_find_first(global.worldItems);
while(!is_undefined(_key)){
	delete global.worldItems[? _key];
	_key = ds_map_find_next(global.worldItems, _key);
}
ds_map_clear(global.worldItems);
ds_map_destroy(global.worldItems);

// Remove the list that stores references to each dynamically created instance of obj_world_item.
ds_list_clear(global.dynamicItemKeys);
ds_list_destroy(global.dynamicItemKeys);

// Clear and destroy the list that contains information about items that player has collected.
ds_list_clear(global.collectedItems);
ds_list_destroy(global.collectedItems);

// Clear out the references to structs found within these struct-specific lists. They will remain alive until
// all structs have been destroyed. Once that occurs, these lists will be destroyed.
ds_list_clear(global.lights);
ds_list_clear(global.menus);

// Remove all existing struct instances from memory by deleting their references stores within the global 
// struct management list. Then, that list itself is destroyed to clear it from memory as well.
_length	= ds_list_size(global.structs);
for (var i = 0; i < _length; i++)
	instance_destroy_struct(global.structs[| i]);
ds_list_clear(global.structs);
ds_list_destroy(global.structs);

// After structs have been cleaned up, the lists that store specific struct instances will finaly be 
// destroyed to avoid issues with clean up of various different objects.
ds_list_destroy(global.menus);
ds_list_destroy(global.lights);

// Make sure the map that stores the type of struct is correctly cleared and deleted from memory as well.
ds_map_clear(global.structType);
ds_map_destroy(global.structType);

// Clear the event flag buffer from memory.
buffer_delete(global.eventFlags);

// Delete the grid that stores entities and their current y position so they can be drawn from the top of 
// the screen to the bottom in order.
ds_grid_destroy(global.sortOrder);

// Clean up the list that is a temporary storage for the states of entities prior to being paused whenever
// they are paused. Primarily used during cutscenes so states can be used for things like moving entities.
_length = ds_list_size(global.pausedEntities);
for (var i = 0; i < _length; i++)
	delete global.pausedEntities[| i];
ds_list_destroy(global.pausedEntities);

// Delete any structs that exist globally as the game manager bares responsibility for cleaning them up.
delete global.settings;
delete global.colorFadeShader;

// Finally, remove and clear out any data structures or dynamic memory that was allocated by the game manager
// itself for handling various logic that occurs on a global scale within the game.
_key = ds_map_find_first(instancesToWarp);
while(!is_undefined(_key)){
	delete instancesToWarp[? _key];
	_key = ds_map_find_next(instancesToWarp, _key);
}
ds_map_clear(instancesToWarp);
ds_map_destroy(instancesToWarp);