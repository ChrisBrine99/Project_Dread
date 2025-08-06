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