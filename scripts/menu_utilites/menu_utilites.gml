// 
global.menus = ds_list_create();

/// @description 
///	
///	
/// @param {Function}	structFunc		The menu struct to create an instance of.
function instance_create_menu_struct(_structFunc){
	var _structRef = instance_create_struct(_structFunc);
	ds_list_add(global.menus, _structRef);
	return _structRef;
}

/// @description 
///	
///	
/// @param {Struct._structRef}	structRef		Reference to the menu struct that will be deleted.
function instance_destroy_menu_struct(_structRef){
	var _index = ds_list_find_index(global.menus, _structRef);
	if (_index == -1)
		return;
		
	instance_destroy_struct(_structRef);
	ds_list_delete(global.menus, _index);
}