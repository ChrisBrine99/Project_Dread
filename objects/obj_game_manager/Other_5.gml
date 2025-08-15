var _startTime = get_timer();

// Before all structs are looped through and managed, the light management struct will remove any values that
// point to non-persistent light sources. Persistent instances are skipped over.
var _length = ds_list_size(global.lights) - 1;
for (var i = _length; i >= 0; i--){ // Has to loop backwards since elements will be removed throughout the loop.
	if ((global.lights[| i].flags & STR_FLAG_PERSISTENT) != 0)
		continue;
	ds_list_delete(global.lights, i);
}

// Loop through all structs still alive within the room; destroying them if they aren't persistent.
_length = ds_list_size(global.structs) - 1;
for (var i = _length; i >= 0; i--){ // Has to loop backwards since elements will be removed throughout the loop.
	if ((global.structs[| i].flags & STR_FLAG_PERSISTENT) != 0)
		continue;

	with(global.structs[| i])
		destroy_event();
	delete global.structs[| i];
	
	ds_list_delete(global.structs, i);
}

// Skip over the code below if there aren't any entities within the sorting grid yet.
/*_length	= ds_grid_height(global.sortOrder);
if (_length == 0) { return; }

// Update the sort order grid to ensure only persistent entity IDs remain within it. This will start by copying
// all persistent instances from the sort order grid into a temporary list which are then place back into the
// grid after it is resized to match the new of persistent instances that are carried into the next room.
var _sortOrder	= ds_list_create();
var _instance	= noone;
for (var i = 0; i < _length; i++){
	with(global.sortOrder[# 0, i]){
		if (persistent) { ds_list_add(_sortOrder, id); }
	}
}
_length = ds_list_size(_sortOrder);	// Get the size of the list so we know what the height of grid should be.
ds_grid_resize(global.sortOrder, 2, _length);
for (var i = 0; i < _length; i++)
	ds_grid_set(global.sortOrder, 0, i, _sortOrder[| i]);
ds_list_destroy(_sortOrder);		// Remove the temporary list from memory.*/

show_debug_message("Room Transition took {0} microseconds to execute.", get_timer() - _startTime);