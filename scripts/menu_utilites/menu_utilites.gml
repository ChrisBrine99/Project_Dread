#region Menu Specific Global Variable Initializations

// A list of references to existing menu structs so they can be updated and rendered when active. This is needed since the standard struct 
// data structure doesn't require a struct to update or draw itself, but menus will always need that to be the case.
global.menus = ds_list_create();

#endregion Menu Specific Global Variable Initializations

#region Menu Struct Creation/Destruction Function Declarations

/// @description 
///	Attempts to create an instance of the provided struct function. It will fail this attempt should the struct provided not be a valid menu 
/// struct, or the struct itself be what is considered a *special* menu struct that shouldn't be created during runtime.
/// @returns 	{Struct.str_menu_base}
/// @param 		{Function}						 structFunc		The menu struct to create an instance of.
function instance_create_menu_struct(_structFunc){
	var _type = global.structType[? _structFunc];
	if (is_undefined(_type) || _type != STRUCT_TYPE_MENU)
		return undefined; // Don't even attempt creation if the provided struct isn't a valid menu struct function.
	
	// Attempt to create the struct using a "two chance" system. If the initial creation fails, it might mean the menu struct is a singleton.
	// In that case, the singleton struct instance creation function is called, and this function returns undefined if that call also fails.
	var _structRef = instance_create_struct(_structFunc);
	if (is_undefined(_structRef)){
		instance_create_struct_singleton(_structFunc);
		with(global.singletons)
			_structRef = variable_instance_get(self, structSingletons[? _structFunc]);
	}
	
	// Set the flag that is responsible for letting the other objects in the game know that a menu is currently open so they can relinquish 
	// control until this flag is cleared.
	global.flags = global.flags | GAME_FLAG_MENU_OPEN;
	
	// Finally, add the menu instance to a global management list that will handle updating and rendering all existing menus to the screen in
	// the order of their creation (Oldest drawn first; newest drawn last).
	ds_list_add(global.menus, _structRef);
	return _structRef;
}

/// @description 
///	Attempts to destroy an existing instance of menu struct. It simply calls *instance_destroy_struct* which handles to deletion logic, but 
/// also removes the struct's reference to the global menu instance list so a non-existent menu isn't being accessed for updates and rendering.
/// If the supplied instance isn't found within that list, this function does nothing.
/// @param {Struct._structRef}	structRef		Reference to the menu struct that will be deleted.
function instance_destroy_menu_struct(_structRef){
	var _index = ds_list_find_index(global.menus, _structRef);
	if (_index == -1)
		return;
		
	if (!instance_destroy_struct(_structRef))
		instance_destroy_struct_singleton(_structRef);
	ds_list_delete(global.menus, _index);
}

#endregion Menu Struct Creation/Destruction Function Declarations

#region Menu Instance Retrieval Function Declarations

/// @description 
///	Wrapper function for getting the instance of an existing menu, but treated as if it was the base menu struct (*str_base_menu*).
/// @returns 	{Struct.str_base_menu}
/// @param		{Real}	index	The position the menu instance occupies within *global.menus*.
function menu_get(_index){
	if (_index < 0 || _index >= ds_list_size(global.menus))
		return undefined;
	return ds_list_find_value(global.menus, _index);
}

#endregion Menu Instance Retrieval Function Declarations