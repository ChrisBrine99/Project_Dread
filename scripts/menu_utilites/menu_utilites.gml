// A list of references to existing menu structs so they can be updated and rendered when active. This is needed
// since the standard struct data structure doesn't require a struct to update or draw itself, but menus will
// always need that to be the case.
global.menus = ds_list_create();

/// @description 
///	Attempts to create an instance of the provided struct function. It will fail this attempt should the struct
/// provided not be a valid menu struct, or the struct itself be what is considered a "special" menu struct 
/// that shouldn't be created during runtime.
///	
/// @param {Function}	structFunc		The menu struct to create an instance of.
function instance_create_menu_struct(_structFunc){
	var _structRef = instance_create_struct(_structFunc);
	if (_structRef == noone) // Invalid menu type was trying to be created; return noone to prevent creation.
		return noone;
	
	// Set the flag that is responsible for letting the other objects in the game know that a menu is currently
	// open so they can relinquish control until this flag is cleared.
	global.flags |= GAME_FLAG_MENU_OPEN;
	
	// Finally, add the menu instance to a global management list that will handle updating and rendering all
	// existing menus to the screen in the order of their creation (Oldest drawn first; newest drawn last).
	ds_list_add(global.menus, _structRef);
	return _structRef;
}

/// @description 
///	Attempts to destroy an existing instance of menu struct. It simply calls "instance_destroy_struct" which
/// handles to deletion logic, but also removes the struct's reference to the global menu instance list so a
/// non-existent menu isn't being accessed for updates and rendering. If the supplied instance isn't found
/// within that list, this function does nothing.
///	
/// @param {Struct._structRef}	structRef		Reference to the menu struct that will be deleted.
function instance_destroy_menu_struct(_structRef){
	var _index = ds_list_find_index(global.menus, _structRef);
	if (_index == -1)
		return;
		
	instance_destroy_struct(_structRef);
	ds_list_delete(global.menus, _index);
}